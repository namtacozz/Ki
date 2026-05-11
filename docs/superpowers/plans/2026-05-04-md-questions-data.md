# MD Questions Data Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build an editable Markdown → generated JSON content pipeline for tarot questions, with per-card/per-position question sets and hybrid 64/36 card drawing.

**Architecture:** Godot keeps reading JSON at runtime. Python converter owns Markdown parsing and validation. QuestionManager provides one interface for onboarding and card-position questions; TarotManager owns weighted draw and card display helpers.

**Tech Stack:** Godot 4.x, GDScript, Python standard library, JSON, Markdown-like source file.

---

## File structure

- Create: `data/questions.md` — editable source for onboarding plus 22 card sections.
- Create: `data/questions.generated.json` — generated runtime JSON committed with current content.
- Create: `tools/content/convert_questions_md.py` — parser/validator/generator.
- Modify: `data/tarot_major_arcana.json` — add `slug`, `display_name_vi`, `subtitle`, `affinity_tags`.
- Modify: `scripts/questions/question_manager.gd` — load generated JSON, normalize choice dictionaries, expose card-position lookup and stories.
- Modify: `scripts/tarot/tarot_manager.gd` — use slugs/display names and hybrid 64/36 draw.
- Modify: `scripts/ui/screens/onboarding_screen.gd` — render choice dictionaries.
- Modify: `scripts/ui/screens/inner_space_screen.gd` — render choice dictionaries and story text if scene node exists; no scene rewrite required for first pass.
- Modify: `scripts/ui/screens/card_reveal_screen.gd` — show Vietnamese card name and subtitle.
- Modify: `scripts/ui/main_controller.gd` — fetch questions by card slug + position, include story in reflection context, show content error when no questions.
- Modify: `Takanote/🗺️_CẤU_TRÚC_DỰ_ÁN_KÌ.md` — document new content pipeline.

## Task 1: Add converter and minimal Markdown source

**Files:**
- Create: `tools/content/convert_questions_md.py`
- Create: `data/questions.md`
- Create: `data/questions.generated.json`

- [ ] **Step 1: Create minimal Markdown source with all required structure**

Write `data/questions.md` with all 22 slugs and three positions each. Use concise seed content first; improve prose later without code changes. Include this exact skeleton style for each card:

```md
# KÌ Questions

## onboarding

1. Điều gì đang kéo Ngài bước vào căn phòng của KÌ?
- A | Một câu hỏi chưa có lời | tags: seeking,truth
- B | Một thay đổi đang đến | tags: change,threshold
- C | Một phần bản thân bị bỏ quên | tags: memory,shadow

2. Bên trong Ngài lúc này giống điều gì nhất?
- A | Sương mù | tags: uncertainty,moon
- B | Ngọn lửa | tags: desire,action
- C | Mặt nước | tags: feeling,reflection
- D | Cánh cửa | tags: threshold,choice

3. Ngài muốn lá bài nói thật về điều gì?
- A | Điều cần buông | tags: release,death
- B | Điều cần giữ | tags: care,strength
- C | Điều cần đối diện | tags: truth,justice

## the_fool — Kẻ Khờ (The Fool)

### past
Story: Kẻ Khờ trong Quá khứ từng bước qua một ngưỡng cửa khi chưa biết mình sẽ mất gì.

1. Khi Kẻ Khờ rời nơi cũ, điều gì dẫn bước chân đầu tiên?
- A | Một niềm tin chưa bị chứng minh sai | tags: trust,beginning
- B | Một cơn mệt mỏi với điều quen thuộc | tags: release,threshold
- C | Một tiếng gọi không giải thích được | tags: intuition,unknown

2. Trên đường cũ, Kẻ Khờ đã xem nhẹ điều gì?
- A | Dấu hiệu nguy hiểm nhỏ | tags: risk,blindness
- B | Lời khuyên của người thương | tags: counsel,relationship
- C | Sức nặng của tự do | tags: freedom,burden

3. Điều nào còn vang lại sau cú bước hụt đầu tiên?
- A | Nỗi xấu hổ vì từng quá ngây thơ | tags: shame,innocence
- B | Lòng biết ơn vì đã dám đi | tags: gratitude,courage
- C | Câu hỏi về con đường chưa chọn | tags: doubt,path

4. Nếu Quá khứ trao lại một món đồ, đó là gì?
- A | Chiếc túi nhẹ hơn sau khi mất mát | tags: loss,lightness
- B | Vết trầy nhắc mình nhìn xuống | tags: lesson,body
- C | Bản đồ không có điểm đến | tags: wandering,possibility

5. Free: Khi Kẻ Khờ chọn bước tiếp dù chưa hiểu hậu quả, Ngài thấy đó là lựa chọn tốt không? Nếu là Ngài lúc ấy, Ngài sẽ làm gì khác?

### present
Story: Kẻ Khờ trong Hiện tại đứng trước mép đường mới, một phần muốn nhảy, một phần muốn hỏi thêm.

1. Điều gì làm bước chân hiện tại của Kẻ Khờ run lên?
- A | Sợ bị xem là ngốc | tags: shame,visibility
- B | Sợ bỏ lỡ cơ hội | tags: urgency,possibility
- C | Sợ không còn đường quay lại | tags: fear,threshold

2. Kẻ Khờ đang cần nghe tiếng nào rõ hơn?
- A | Tiếng cơ thể | tags: body,instinct
- B | Tiếng trực giác | tags: intuition,moon
- C | Tiếng thực tế | tags: grounding,emperor

3. Món quà của hiện tại là gì?
- A | Khoảnh khắc chưa bị định nghĩa | tags: openness,beginning
- B | Quyền thử sai | tags: learning,freedom
- C | Một người bạn đồng hành | tags: support,relationship

4. Cái bẫy gần nhất là gì?
- A | Nhầm liều lĩnh với can đảm | tags: risk,courage
- B | Chờ chắc chắn tuyệt đối | tags: hesitation,control
- C | Cười để né sợ hãi | tags: mask,avoidance

5. Free: Khi Kẻ Khờ ở hiện tại chọn tin vào bước nhỏ tiếp theo, Ngài thấy lựa chọn đó có khôn ngoan không? Nếu là Ngài, Ngài sẽ bước ra sao?

### future
Story: Kẻ Khờ trong Tương lai nhìn thấy con đường mở ra sau lần dám bắt đầu.

1. Tương lai nào đang gọi Kẻ Khờ?
- A | Một đời sống rộng hơn | tags: expansion,world
- B | Một phiên bản nhẹ hơn | tags: lightness,healing
- C | Một sai lầm đáng học | tags: learning,risk

2. Điều gì cần bỏ lại trước khi đi tiếp?
- A | Câu chuyện rằng mình luôn thất bại | tags: release,judgement
- B | Nhu cầu được mọi người đồng ý | tags: approval,freedom
- C | Thói quen đợi dấu hiệu hoàn hảo | tags: hesitation,threshold

3. Người Kẻ Khờ trở thành sẽ nhớ gì?
- A | Can đảm bắt đầu quan trọng hơn hoàn hảo | tags: courage,beginning
- B | Tự do cần trách nhiệm đi cùng | tags: freedom,responsibility
- C | Niềm vui cũng là một la bàn | tags: joy,sun

4. Cánh cửa tương lai mở bằng gì?
- A | Một câu nói thật | tags: truth,voice
- B | Một hành động nhỏ | tags: action,grounding
- C | Một lời tạm biệt | tags: goodbye,release

5. Free: Khi Kẻ Khờ tương lai chọn bắt đầu lại thay vì chứng minh mình đúng, Ngài thấy đó là lựa chọn tốt không? Nếu là Ngài, Ngài sẽ giữ điều gì khi bước qua cửa?
```

Use the same concrete five-question template for every card by substituting card display name, slug, and position in this pattern:

```text
Story: {card_vi} trong {position_vi} hiện ra như một nhân vật đang đối diện bài học {theme}.

1. Khi {card_vi} bước vào câu chuyện {position_vi}, điều gì nổi bật nhất?
- A | Một tiếng gọi cần được nghe | tags: calling,attention
- B | Một nỗi sợ muốn được che giấu | tags: fear,shadow
- C | Một lựa chọn đang đợi hình dạng rõ hơn | tags: choice,threshold

2. {card_vi} đã phản ứng với tình huống bằng cách nào?
- A | Tiến lại gần điều khó nhìn | tags: courage,truth
- B | Giữ khoảng cách để tự bảo vệ | tags: boundary,protection
- C | Đổi hướng để thử một con đường khác | tags: change,path

3. Điều gì trong câu chuyện của {card_vi} giống với Ngài nhất?
- A | Mong muốn được tự do hơn | tags: freedom,desire
- B | Gánh nặng của điều chưa nói | tags: silence,burden
- C | Nhu cầu hiểu mình trước khi đi tiếp | tags: reflection,self

4. Nếu {card_vi} trao Ngài một dấu hiệu, dấu hiệu đó nhắc điều gì?
- A | Đừng bỏ qua cảm giác đầu tiên | tags: intuition,body
- B | Đừng nhầm kiểm soát với an toàn | tags: control,safety
- C | Đừng để quá khứ viết hết câu chuyện | tags: memory,release

5. Free: Khi {card_vi} trong {position_vi} chọn hành động theo bài học {theme}, Ngài thấy đó là lựa chọn tốt không? Nếu là Ngài, Ngài sẽ làm gì khác?
```

This keeps every card playable now. Later prose polish only edits `data/questions.md` and reruns converter.

- [ ] **Step 2: Write converter**

Create `tools/content/convert_questions_md.py`:

```python
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


def load_card_slugs() -> list[str]:
    cards = json.loads(CARDS.read_text(encoding="utf-8"))
    slugs = []
    for card in cards:
        slug = card.get("slug") or slugify(card["name"])
        slugs.append(slug)
    return slugs


def slugify(name: str) -> str:
    return re.sub(r"[^a-z0-9]+", "_", name.lower()).strip("_")


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
    first = lines[0]
    match = QUESTION_RE.match(first)
    if not match:
        fail(f"invalid question in {slug}/{position}: {first}")
    number = int(match.group(1))
    prompt = match.group(2).strip()
    qid = f"{slug}_{position}_{number}"
    if number == 5:
        if not prompt.startswith("Free:"):
            fail(f"question 5 must start with Free: in {slug}/{position}")
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
        elif current and line.startswith("-"):
            current.append(line)
    if current:
        groups.append(current)
    questions = [parse_question(group, idx, slug, position) for idx, group in enumerate(groups, start=1)]
    numbers = [int(q["id"].rsplit("_", 1)[1]) for q in questions]
    if numbers != [1, 2, 3, 4, 5]:
        fail(f"{slug}/{position} must have questions 1..5")
    return questions


def parse_markdown(text: str) -> dict:
    lines = [line.rstrip() for line in text.splitlines()]
    data = {"onboarding": [], "cards": {}}
    current_slug = ""
    current_position = ""
    story = ""
    block: list[str] = []

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

    onboarding_block: list[str] = []
    in_onboarding = False
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
                for choice in question.get("choices", []):
                    if not choice.get("tags"):
                        fail(f"{question['id']} has choice without tags")
            if not questions[4].get("free_text", False):
                fail(f"{slug}/{position} question 5 must be free text")


def main() -> int:
    data = parse_markdown(SOURCE.read_text(encoding="utf-8"))
    validate(data, load_card_slugs())
    TARGET.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"wrote {TARGET.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
```

- [ ] **Step 3: Run converter and confirm expected failure**

Run:

```bash
rtk python tools/content/convert_questions_md.py
```

Expected if only `the_fool` is present:

```text
convert_questions_md.py: missing card sections: the_magician, the_high_priestess, ...
```

- [ ] **Step 4: Generate remaining Markdown card sections from template**

Use a short Python one-off script in shell or editor to append remaining card sections with the concrete template from Step 1. Input card list:

```python
cards = [
    ("the_magician", "Ma thuật sư", "The Magician", "ý chí"),
    ("the_high_priestess", "Nữ Tư Tế", "The High Priestess", "trực giác"),
    ("the_empress", "Mẹ", "The Empress", "nuôi dưỡng"),
    ("the_emperor", "Hoàng Đế", "The Emperor", "trật tự"),
    ("the_hierophant", "Linh Mục Đỏ", "The Hierophant", "niềm tin"),
    ("the_lovers", "Trái Tim", "The Lovers", "lựa chọn"),
    ("the_chariot", "Cỗ Xe", "The Chariot", "tiến bước"),
    ("strength", "Sức Mạnh", "Strength", "can đảm"),
    ("the_hermit", "Ẩn Sĩ", "The Hermit", "ẩn tu"),
    ("wheel_of_fortune", "Bánh Xe Vận Mệnh", "Wheel of Fortune", "chuyển vận"),
    ("justice", "Thẩm Phán", "Justice", "cân bằng"),
    ("the_hanged_man", "Kẻ Treo Ngược", "The Hanged Man", "đổi góc nhìn"),
    ("death", "Chuyển Hóa", "Death", "chuyển hóa"),
    ("temperance", "Tiết Độ", "Temperance", "hòa hợp"),
    ("the_devil", "Nữ Quỷ", "The Devil", "ràng buộc"),
    ("the_tower", "Tòa Tháp", "The Tower", "đổ vỡ"),
    ("the_star", "Ngôi Sao", "The Star", "hy vọng"),
    ("the_moon", "Trăng Rằm", "The Moon", "mơ hồ"),
    ("the_sun", "Mặt Trời", "The Sun", "sáng rõ"),
    ("judgement", "Phán Xét", "Judgement", "thức tỉnh"),
    ("the_world", "Thế Giới", "The World", "hoàn tất"),
]
positions = [("past", "Quá khứ"), ("present", "Hiện tại"), ("future", "Tương lai")]
```

For each tuple, write:

```md
## {slug} — {vi} ({en})

### {position}
Story: {vi} trong {position_vi} hiện ra như một nhân vật đang đối diện bài học {theme}.
...
```

Use exact question/choice template from Step 1 for each position.

- [ ] **Step 5: Run converter successfully**

Run:

```bash
rtk python tools/content/convert_questions_md.py
```

Expected:

```text
wrote data/questions.generated.json
```

- [ ] **Step 6: Commit content pipeline seed**

```bash
rtk git add data/questions.md data/questions.generated.json tools/content/convert_questions_md.py
rtk git commit -m "feat: add markdown questions content pipeline"
```

## Task 2: Add card metadata for display and affinity

**Files:**
- Modify: `data/tarot_major_arcana.json`

- [ ] **Step 1: Update each card object**

For each object, add fields. Example first object:

```json
{
  "id": 0,
  "slug": "the_fool",
  "name": "The Fool",
  "display_name_vi": "Kẻ Khờ",
  "subtitle": "The Fool",
  "theme": "khởi đầu",
  "keywords": ["ngây thơ", "bước nhảy", "niềm tin"],
  "affinity_tags": ["beginning", "trust", "threshold", "freedom", "risk"],
  "art_path": "res://assets/art/Tarot-cards/00-TheFool.png"
}
```

Use these aliases:

```text
the_fool: Kẻ Khờ / The Fool
the_magician: Ma thuật sư / The Magician
the_high_priestess: Nữ Tư Tế / The High Priestess
the_empress: Mẹ / The Empress
the_emperor: Hoàng Đế / The Emperor
the_hierophant: Linh Mục Đỏ / The Hierophant
the_lovers: Trái Tim / The Lovers
the_chariot: Cỗ Xe / The Chariot
strength: Sức Mạnh / Strength
the_hermit: Ẩn Sĩ / The Hermit
wheel_of_fortune: Bánh Xe Vận Mệnh / Wheel of Fortune
justice: Thẩm Phán / Justice
the_hanged_man: Kẻ Treo Ngược / The Hanged Man
death: Chuyển Hóa / Death
temperance: Tiết Độ / Temperance
the_devil: Nữ Quỷ / The Devil
the_tower: Tòa Tháp / The Tower
the_star: Ngôi Sao / The Star
the_moon: Trăng Rằm / The Moon
the_sun: Mặt Trời / The Sun
judgement: Phán Xét / Judgement
the_world: Thế Giới / The World
```

- [ ] **Step 2: Validate JSON syntax through converter**

Run:

```bash
rtk python tools/content/convert_questions_md.py
```

Expected:

```text
wrote data/questions.generated.json
```

- [ ] **Step 3: Commit card metadata**

```bash
rtk git add data/tarot_major_arcana.json data/questions.generated.json
rtk git commit -m "feat: add tarot display metadata and affinity tags"
```

## Task 3: Update QuestionManager for generated data and tagged choices

**Files:**
- Modify: `scripts/questions/question_manager.gd`

- [ ] **Step 1: Replace manager with generated-data aware version**

Write `scripts/questions/question_manager.gd`:

```gdscript
extends Node

const QUESTIONS_DATA_PATH := "res://data/questions.generated.json"

var _data: Dictionary = {}

func _ready() -> void:
	load_questions()

func load_questions() -> void:
	var loaded: Variant = JsonLoader.load_json(QUESTIONS_DATA_PATH, {})
	_data = loaded if loaded is Dictionary else {}

func get_onboarding_questions() -> Array[Dictionary]:
	return _to_dictionary_array(_data.get("onboarding", []))

func get_inner_space_questions() -> Array[Dictionary]:
	return get_questions_for_position("inner_space")

func get_questions_for_position(position: String) -> Array[Dictionary]:
	return get_questions(get_set_id_for_position(position))

func get_questions_for_card_position(card_slug: String, position: String) -> Array[Dictionary]:
	_ensure_loaded()
	var section := get_card_position_section(card_slug, position)
	return _to_dictionary_array(section.get("questions", []))

func get_story_for_card_position(card_slug: String, position: String) -> String:
	return String(get_card_position_section(card_slug, position).get("story", ""))

func get_card_position_section(card_slug: String, position: String) -> Dictionary:
	_ensure_loaded()
	var cards: Variant = _data.get("cards", {})
	if not cards is Dictionary:
		return {}
	var card_data: Variant = cards.get(card_slug, {})
	if not card_data is Dictionary:
		return {}
	var position_key := get_set_id_for_position(position)
	var section: Variant = card_data.get(position_key, {})
	return section.duplicate(true) if section is Dictionary else {}

func get_set_id_for_position(position: String) -> String:
	match position.to_lower():
		"quá khứ", "past":
			return "past"
		"hiện tại", "present":
			return "present"
		"tương lai", "future":
			return "future"
		_:
			return "inner_space"

func get_questions(set_id: String) -> Array[Dictionary]:
	_ensure_loaded()
	return _to_dictionary_array(_data.get(set_id, []))

func get_question(set_id: String, question_id: String) -> Dictionary:
	for question in get_questions(set_id):
		if String(question.get("id", "")) == question_id:
			return question.duplicate(true)
	return {}

func get_question_count(set_id: String) -> int:
	return get_questions(set_id).size()

func get_question_at(set_id: String, index: int) -> Dictionary:
	var questions := get_questions(set_id)
	if index < 0 or index >= questions.size():
		return {}
	return questions[index].duplicate(true)

func get_next_question(set_id: String, answered_count: int) -> Dictionary:
	return get_question_at(set_id, answered_count)

func has_next_question(set_id: String, answered_count: int) -> bool:
	return answered_count < get_question_count(set_id)

func is_free_text_question(question: Dictionary) -> bool:
	return bool(question.get("free_text", false))

func is_valid_choice(question: Dictionary, choice: String) -> bool:
	if is_free_text_question(question):
		return not choice.strip_edges().is_empty()
	var choices: Variant = question.get("choices", [])
	if choices is Array:
		for item in choices:
			if get_choice_text(item) == choice:
				return true
	return false

func build_answer(question: Dictionary, value: String) -> Dictionary:
	var key := "text" if is_free_text_question(question) else "choice"
	var answer := {
		"question_id": String(question.get("id", "")),
		key: value,
	}
	if not is_free_text_question(question):
		answer["tags"] = get_choice_tags(question, value)
	return answer

func get_choice_text(choice: Variant) -> String:
	if choice is Dictionary:
		return String(choice.get("text", ""))
	return String(choice)

func get_choice_label(choice: Variant) -> String:
	if choice is Dictionary:
		return String(choice.get("label", ""))
	return ""

func get_choice_tags(question: Dictionary, value: String) -> Array[String]:
	var result: Array[String] = []
	var choices: Variant = question.get("choices", [])
	if choices is Array:
		for item in choices:
			if item is Dictionary and String(item.get("text", "")) == value:
				var tags: Variant = item.get("tags", [])
				if tags is Array:
					for tag in tags:
						result.append(String(tag))
	return result

func _ensure_loaded() -> void:
	if _data.is_empty():
		load_questions()

func _to_dictionary_array(value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if value is Array:
		for item in value:
			if item is Dictionary:
				result.append(item.duplicate(true))
	return result
```

- [ ] **Step 2: Run Godot parse check**

Run:

```bash
rtk godot --headless --path "D:/KÌ" --quit
```

Expected: command exits without GDScript parse errors mentioning `question_manager.gd`.

- [ ] **Step 3: Commit QuestionManager update**

```bash
rtk git add scripts/questions/question_manager.gd
rtk git commit -m "feat: load generated tarot question data"
```

## Task 4: Update TarotManager hybrid draw and display helpers

**Files:**
- Modify: `scripts/tarot/tarot_manager.gd`

- [ ] **Step 1: Replace TarotManager implementation**

Write `scripts/tarot/tarot_manager.gd`:

```gdscript
extends Node

const TAROT_DATA_PATH := "res://data/tarot_major_arcana.json"
const SPREAD_POSITIONS := ["past", "present", "future"]
const AFFINITY_WEIGHT := 0.64
const RANDOM_WEIGHT := 0.36

var _cards: Array[Dictionary] = []

func _ready() -> void:
	load_cards()

func load_cards() -> void:
	_cards = _to_dictionary_array(JsonLoader.load_json(TAROT_DATA_PATH, []))
	for index in _cards.size():
		if String(_cards[index].get("slug", "")).is_empty():
			_cards[index]["slug"] = _slugify(String(_cards[index].get("name", "")))

func get_all_cards() -> Array[Dictionary]:
	return _cards.duplicate(true)

func get_card_by_id(card_id: int) -> Dictionary:
	_ensure_cards_loaded()
	for card in _cards:
		if int(card.get("id", -1)) == card_id:
			return card.duplicate(true)
	return {}

func draw_three_cards(seed_text: String = "") -> Array[Dictionary]:
	_ensure_cards_loaded()
	var deck := _cards.duplicate(true)
	if deck.size() < SPREAD_POSITIONS.size():
		return []
	_shuffle_deck(deck, seed_text)
	return _build_spread(deck)

func draw_for_answers(answers: Array[Dictionary]) -> Array[Dictionary]:
	_ensure_cards_loaded()
	var deck := _cards.duplicate(true)
	if deck.size() < SPREAD_POSITIONS.size():
		return []
	var tag_profile := _tag_profile(answers)
	if tag_profile.is_empty():
		_shuffle_deck(deck, _answers_seed(answers))
		return _build_spread(deck)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(_answers_seed(answers) + "|" + str(Time.get_unix_time_from_system()))
	deck.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return _hybrid_score(a, tag_profile, rng) > _hybrid_score(b, tag_profile, rng)
	)
	return _build_spread(deck)

func get_theme_for_card(card: Dictionary) -> String:
	return String(card.get("theme", ""))

func get_keywords_for_card(card: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var keywords: Variant = card.get("keywords", [])
	if keywords is Array:
		for keyword in keywords:
			result.append(String(keyword))
	return result

func get_art_path_for_card(card: Dictionary) -> String:
	var art_path := String(card.get("art_path", card.get("image_path", "")))
	if art_path.is_empty() or not ResourceLoader.exists(art_path):
		return ""
	return art_path

func get_slug_for_card(card: Dictionary) -> String:
	var slug := String(card.get("slug", ""))
	return slug if not slug.is_empty() else _slugify(String(card.get("name", "")))

func get_display_name_for_card(card: Dictionary) -> String:
	var display_name := String(card.get("display_name_vi", ""))
	return display_name if not display_name.is_empty() else String(card.get("name", ""))

func get_subtitle_for_card(card: Dictionary) -> String:
	return String(card.get("subtitle", card.get("name", "")))

func _ensure_cards_loaded() -> void:
	if _cards.is_empty():
		load_cards()

func _build_spread(deck: Array[Dictionary]) -> Array[Dictionary]:
	var spread: Array[Dictionary] = []
	for index in SPREAD_POSITIONS.size():
		spread.append(_make_position_card(deck[index], SPREAD_POSITIONS[index]))
	return spread

func _shuffle_deck(deck: Array[Dictionary], seed_text: String) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(seed_text) if not seed_text.is_empty() else Time.get_unix_time_from_system()
	for index in range(deck.size() - 1, 0, -1):
		var swap_index := rng.randi_range(0, index)
		var card := deck[index]
		deck[index] = deck[swap_index]
		deck[swap_index] = card

func _answers_seed(answers: Array[Dictionary]) -> String:
	var parts: Array[String] = []
	for answer in answers:
		parts.append(String(answer.get("question_id", "")))
		parts.append(String(answer.get("choice", answer.get("text", ""))))
		var tags: Variant = answer.get("tags", [])
		if tags is Array:
			for tag in tags:
				parts.append(String(tag))
	return "|".join(parts)

func _make_position_card(card: Dictionary, position: String) -> Dictionary:
	var result := card.duplicate(true)
	result["position"] = position
	return result

func _tag_profile(answers: Array[Dictionary]) -> Dictionary:
	var profile := {}
	for answer in answers:
		var tags: Variant = answer.get("tags", [])
		if tags is Array:
			for tag in tags:
				var key := String(tag)
				profile[key] = int(profile.get(key, 0)) + 1
	return profile

func _hybrid_score(card: Dictionary, tag_profile: Dictionary, rng: RandomNumberGenerator) -> float:
	var affinity := 0.0
	var tags: Variant = card.get("affinity_tags", [])
	if tags is Array:
		for tag in tags:
			affinity += float(tag_profile.get(String(tag), 0))
	var normalized_affinity := min(1.0, affinity / 3.0)
	return normalized_affinity * AFFINITY_WEIGHT + rng.randf() * RANDOM_WEIGHT

func _slugify(value: String) -> String:
	return value.to_lower().replace(" ", "_").replace("-", "_")

func _to_dictionary_array(value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if value is Array:
		for item in value:
			if item is Dictionary:
				result.append(item)
	return result
```

- [ ] **Step 2: Run Godot parse check**

Run:

```bash
rtk godot --headless --path "D:/KÌ" --quit
```

Expected: no parse errors mentioning `tarot_manager.gd`.

- [ ] **Step 3: Commit TarotManager update**

```bash
rtk git add scripts/tarot/tarot_manager.gd
rtk git commit -m "feat: draw tarot cards with hybrid weighting"
```

## Task 5: Update UI choice rendering and card display

**Files:**
- Modify: `scripts/ui/screens/onboarding_screen.gd`
- Modify: `scripts/ui/screens/inner_space_screen.gd`
- Modify: `scripts/ui/screens/card_reveal_screen.gd`

- [ ] **Step 1: Update onboarding choices**

In `scripts/ui/screens/onboarding_screen.gd`, replace loop body lines 17-21 with:

```gdscript
		for choice in choices:
			var choice_text := QuestionManager.get_choice_text(choice)
			var label := QuestionManager.get_choice_label(choice)
			var button_text := choice_text if label.is_empty() else "%s. %s" % [label, choice_text]
			var button := _create_button(button_text)
			button.pressed.connect(choice_selected.emit.bind(question, choice_text))
			choices_box.add_child(button)
```

- [ ] **Step 2: Update inner space choices and display names**

In `scripts/ui/screens/inner_space_screen.gd`, change card labels in `setup()`:

```gdscript
	card_name_label.text = TarotManager.get_display_name_for_card(card_data)
	theme_label.text = TarotManager.get_subtitle_for_card(card_data)
```

Replace choice loop with:

```gdscript
			for choice in choices:
				var choice_text := QuestionManager.get_choice_text(choice)
				var label := QuestionManager.get_choice_label(choice)
				var button_text := choice_text if label.is_empty() else "%s. %s" % [label, choice_text]
				var button := _create_button(button_text)
				button.pressed.connect(choice_selected.emit.bind(card_data, question_data, choice_text))
				choices_box.add_child(button)
```

- [ ] **Step 3: Update card reveal display**

In `scripts/ui/screens/card_reveal_screen.gd`, replace card name/theme label lines with:

```gdscript
		box.add_child(_create_label(TarotManager.get_display_name_for_card(card), 28 if not is_phone else 14))
		box.add_child(_create_label(TarotManager.get_subtitle_for_card(card), 20 if not is_phone else 13))
```

Keep keyword label unchanged.

- [ ] **Step 4: Run Godot parse check**

Run:

```bash
rtk godot --headless --path "D:/KÌ" --quit
```

Expected: no parse errors mentioning changed UI files.

- [ ] **Step 5: Commit UI updates**

```bash
rtk git add scripts/ui/screens/onboarding_screen.gd scripts/ui/screens/inner_space_screen.gd scripts/ui/screens/card_reveal_screen.gd
rtk git commit -m "feat: show tagged choices and Vietnamese card names"
```

## Task 6: Wire card-position questions into main flow

**Files:**
- Modify: `scripts/ui/main_controller.gd`

- [ ] **Step 1: Add current story state**

Near current variables, add:

```gdscript
var current_space_story := ""
```

- [ ] **Step 2: Fetch questions by card slug and position**

In `_show_current_inner_space()`, replace:

```gdscript
	current_space_questions = QuestionManager.get_questions_for_position(String(card.get("position", "")))
```

with:

```gdscript
	var card_slug := TarotManager.get_slug_for_card(card)
	var card_position := String(card.get("position", ""))
	current_space_story = QuestionManager.get_story_for_card_position(card_slug, card_position)
	current_space_questions = QuestionManager.get_questions_for_card_position(card_slug, card_position)
	if current_space_questions.is_empty():
		_show_loading_screen("Thiếu dữ liệu câu hỏi", "Không tìm thấy câu hỏi cho %s / %s." % [card_slug, card_position])
		if current_screen.has_signal("continued"):
			current_screen.continued.connect(_advance_inner_space)
		return
```

- [ ] **Step 3: Include story in saved result and AI context**

In `_save_current_inner_space()`, add story:

```gdscript
		"story": current_space_story,
```

In `_build_reflection_context()`, add story:

```gdscript
		"story": current_space_story,
```

- [ ] **Step 4: Run Godot parse check**

Run:

```bash
rtk godot --headless --path "D:/KÌ" --quit
```

Expected: no parse errors mentioning `main_controller.gd`.

- [ ] **Step 5: Commit flow wiring**

```bash
rtk git add scripts/ui/main_controller.gd
rtk git commit -m "feat: use card-specific inner space questions"
```

## Task 7: Update project structure documentation

**Files:**
- Modify: `Takanote/🗺️_CẤU_TRÚC_DỰ_ÁN_KÌ.md`

- [ ] **Step 1: Add content pipeline entries**

Add entries for:

```md
- `data/questions.md`: nguồn Markdown để chỉnh onboarding và câu hỏi theo từng lá/vị trí.
- `data/questions.generated.json`: JSON runtime sinh từ Markdown, Godot đọc file này.
- `tools/content/convert_questions_md.py`: tool convert + validate nội dung câu hỏi.
```

- [ ] **Step 2: Add verification command**

Add:

```bash
rtk python tools/content/convert_questions_md.py
rtk godot --headless --path "D:/KÌ" --quit
```

- [ ] **Step 3: Add structure changelog item**

Add dated item:

```md
### 2026-05-04

- Thêm pipeline câu hỏi `data/questions.md` → `data/questions.generated.json`.
- Câu hỏi inner space chuyển sang theo từng lá tarot và vị trí Quá khứ / Hiện tại / Tương lai.
- Chọn 3 lá đầu dùng hybrid 64% affinity tags và 36% random noise.
```

- [ ] **Step 4: Commit docs update**

```bash
rtk git add "Takanote/🗺️_CẤU_TRÚC_DỰ_ÁN_KÌ.md"
rtk git commit -m "docs: document questions content pipeline"
```

## Task 8: Final verification

**Files:**
- No new file edits unless verification finds a bug.

- [ ] **Step 1: Regenerate questions JSON**

Run:

```bash
rtk python tools/content/convert_questions_md.py
```

Expected:

```text
wrote data/questions.generated.json
```

- [ ] **Step 2: Run Godot headless check**

Run:

```bash
rtk godot --headless --path "D:/KÌ" --quit
```

Expected: exits without parse/runtime startup errors.

- [ ] **Step 3: Check git status**

Run:

```bash
rtk git status --short
```

Expected: only pre-existing unrelated dirty files remain, or no changes for files touched by this plan.

- [ ] **Step 4: Manual browser smoke test if export/dev runner is available**

Run existing web export flow if Godot export template is configured:

```bash
rtk godot --headless --path "D:/KÌ" --export-release Web "D:/KÌ/exports/web/index.html"
rtk python -m http.server 8090 --directory "D:/KÌ/exports/web"
```

Open browser at local server, test: title → intro → onboarding → reveal → first inner space question. Confirm desktop layout remains readable and no softlock occurs.

## Self-review notes

Spec coverage:

- Editable MD source: Task 1.
- Generated JSON runtime: Tasks 1 and 3.
- Per-card/per-position five questions: Task 1 validation and Task 6 lookup.
- Vietnamese card display metadata: Tasks 2 and 5.
- Choice tags: Tasks 1, 3, 4, 5.
- Hybrid 64/36 draw: Task 4.
- Runtime error handling for missing generated data/questions: Tasks 3 and 6.
- Structure documentation: Task 7.
- Verification commands: Task 8.

No placeholders remain. Function names used later are defined earlier: `get_questions_for_card_position`, `get_story_for_card_position`, `get_choice_text`, `get_choice_label`, `get_slug_for_card`, `get_display_name_for_card`, `get_subtitle_for_card`.
