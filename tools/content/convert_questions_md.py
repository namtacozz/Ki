from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "data" / "questions.md"
TARGET = ROOT / "data" / "questions.generated.json"
CARDS = ROOT / "data" / "tarot_major_arcana.json"
POSITIONS = {"past", "present", "future"}
QUESTION_RE = re.compile(r"^(\d+)\.\s+(.*)$")
CHOICE_RE = re.compile(r"^-\s+([^|]+)\|([^|]+)\|\s*tags:\s*(.+)$")
CARD_RE = re.compile(r"^##\s+([a-z0-9_]+)\s+—\s+(.+)$")


def fail(message: str) -> None:
    raise SystemExit(f"convert_questions_md.py: {message}")


def slugify(name: str) -> str:
    return re.sub(r"[^a-z0-9]+", "_", name.lower()).strip("_")


def load_card_slugs() -> list[str]:
    cards = json.loads(CARDS.read_text(encoding="utf-8"))
    return [card.get("slug") or slugify(card["name"]) for card in cards]


def parse_choice(line: str) -> dict:
    match = CHOICE_RE.match(line)
    if not match:
        fail(f"invalid choice line: {line}")
    label = match.group(1).strip()
    text = match.group(2).strip()
    tags = [tag.strip() for tag in match.group(3).split(",") if tag.strip()]
    if not label or not text or not tags:
        fail(f"choice missing label/text/tags: {line}")
    return {"label": label, "text": text, "tags": tags}


def parse_question(lines: list[str], index: int, slug: str, position: str) -> dict:
    match = QUESTION_RE.match(lines[0])
    if not match:
        fail(f"invalid question in {slug}/{position}: {lines[0]}")
    number = int(match.group(1))
    prompt = match.group(2).strip()
    if number != index:
        fail(f"question order mismatch in {slug}/{position}: expected {index}, got {number}")
    qid = f"{slug}_{position}_{number}"
    if number == 5:
        if not prompt.startswith("Free:"):
            fail(f"question 5 must start with Free: in {slug}/{position}")
        if len(lines) > 1:
            fail(f"question 5 must not have extra lines in {slug}/{position}")
        return {"id": qid, "prompt": prompt.removeprefix("Free:").strip(), "free_text": True}
    choices = [parse_choice(line) for line in lines[1:] if line.startswith("-")]
    if len(choices) < 2:
        fail(f"question {number} in {slug}/{position} needs at least 2 choices")
    return {"id": qid, "prompt": prompt, "choices": choices}


def parse_question_block(block: list[str], slug: str, position: str) -> list[dict]:
    groups: list[list[str]] = []
    current: list[str] = []
    for line in block:
        if QUESTION_RE.match(line):
            if current:
                groups.append(current)
            current = [line]
        elif current:
            if not line.startswith("-"):
                fail(f"malformed line in question block {slug}/{position}: {line}")
            current.append(line)
        else:
            fail(f"malformed line before first question in {slug}/{position}: {line}")
    if current:
        groups.append(current)
    questions = [parse_question(group, index, slug, position) for index, group in enumerate(groups, start=1)]
    numbers = [int(q["id"].rsplit("_", 1)[1]) for q in questions]
    required_numbers = [1, 2, 3] if slug == "onboarding" else [1, 2, 3, 4, 5]
    if numbers != required_numbers:
        fail(f"{slug}/{position} must have questions {required_numbers}")
    return questions


def parse_markdown(text: str) -> dict:
    lines = [line.rstrip() for line in text.splitlines()]
    data = {"onboarding": [], "cards": {}}
    current_slug = ""
    current_position = ""
    story = ""
    block: list[str] = []
    onboarding_block: list[str] = []
    in_onboarding = False

    def flush_position() -> None:
        nonlocal story, block
        if current_slug and current_position:
            if not story:
                fail(f"missing story for {current_slug}/{current_position}")
            data["cards"].setdefault(current_slug, {})[current_position] = {
                "story": story,
                "questions": parse_question_block(block, current_slug, current_position),
            }
        story = ""
        block = []

    for line in lines:
        if line == "## onboarding":
            flush_position()
            current_slug = ""
            current_position = ""
            in_onboarding = True
            onboarding_block = []
            continue
        card_match = CARD_RE.match(line)
        if card_match:
            if in_onboarding:
                data["onboarding"] = parse_question_block(onboarding_block, "onboarding", "start")
                in_onboarding = False
            flush_position()
            current_slug = card_match.group(1)
            current_position = ""
            data["cards"].setdefault(current_slug, {})
            continue
        if line.startswith("### "):
            flush_position()
            current_position = line.removeprefix("### ").strip()
            if current_position not in POSITIONS:
                fail(f"invalid position {current_position}")
            continue
        if in_onboarding:
            if line:
                onboarding_block.append(line)
            continue
        if line.startswith("Story:"):
            story = line.removeprefix("Story:").strip()
            continue
        if current_slug and current_position and line:
            block.append(line)
            continue
        if line and not line.startswith("#"):
            fail(f"malformed line outside question section: {line}")
    if in_onboarding:
        data["onboarding"] = parse_question_block(onboarding_block, "onboarding", "start")
    flush_position()
    return data


def validate(data: dict, slugs: list[str]) -> None:
    if len(data.get("onboarding", [])) != 3:
        fail("onboarding must have exactly 3 questions")
    cards = data.get("cards", {})
    missing_cards = [slug for slug in slugs if slug not in cards]
    if missing_cards:
        fail("missing card sections: " + ", ".join(missing_cards))
    unknown_cards = [slug for slug in cards if slug not in slugs]
    if unknown_cards:
        fail("unknown card sections: " + ", ".join(unknown_cards))
    for slug in slugs:
        positions = cards[slug]
        missing_positions = sorted(POSITIONS - set(positions.keys()))
        if missing_positions:
            fail(f"{slug} missing positions: {', '.join(missing_positions)}")
        for position in POSITIONS:
            questions = positions[position]["questions"]
            if len(questions) != 5:
                fail(f"{slug}/{position} must have 5 questions")
            for question in questions[:4]:
                choices = question.get("choices", [])
                if len(choices) < 2:
                    fail(f"{question['id']} needs at least 2 choices")
                for choice in choices:
                    if not choice.get("tags"):
                        fail(f"{question['id']} has choice without tags")
            if not questions[4].get("free_text", False):
                fail(f"{slug}/{position} question 5 must be free text")


def main() -> int:
    data = parse_markdown(SOURCE.read_text(encoding="utf-8"))
    validate(data, load_card_slugs())
    temp_file = TARGET.with_stem(TARGET.stem + ".tmp")
    temp_file.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    temp_file.replace(TARGET)
    print(f"wrote {TARGET.relative_to(ROOT).as_posix()}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
