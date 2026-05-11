import json
from pathlib import Path

path = Path("data/questions.json")
data = json.loads(path.read_text(encoding="utf-8"))

assert "onboarding_intro" in data
assert "onboarding" in data
assert "cards" in data
assert len(data["cards"]) == 22

for slug, positions in data["cards"].items():
    assert set(positions) == {"past", "present", "future"}
    for pos, section in positions.items():
        assert section.get("story_title"), f"missing story_title for {slug}/{pos}"
        beats = section.get("story_beats", [])
        questions = section.get("questions", [])
        assert isinstance(beats, list), f"story_beats not list for {slug}/{pos}"
        assert isinstance(questions, list), f"questions not list for {slug}/{pos}"
        assert len(beats) == 5, f"expected 5 story beats for {slug}/{pos}, got {len(beats)}"
        assert len(questions) == 5, f"expected 5 questions for {slug}/{pos}, got {len(questions)}"
        for index, beat in enumerate(beats, start=1):
            assert isinstance(beat, str) and beat.strip(), f"empty story beat {index} for {slug}/{pos}"

print("questions.json story-beat schema ok")
