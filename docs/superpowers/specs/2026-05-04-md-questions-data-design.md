# MD Questions Data Design

## Goal

Move game question content into an editable Markdown source file, then generate runtime JSON for Godot. The game must support per-card, per-position question sets for all 22 Major Arcana while keeping runtime parsing stable.

## Scope

- Keep the current 22 Major Arcana ids, art, and gameplay slots.
- Add Vietnamese display aliases for cards while preserving stable English-style ids.
- Add 5 narrative questions for each card in each spread position: past, present, future.
- Make the fifth question free-text and reflective.
- Add semantic tags to choice answers so onboarding and later responses can shape AI interpretation and weighted card drawing.
- Change initial card draw to hybrid weighting: 64% onboarding affinity, 36% random noise.

Out of scope:

- Replacing Major Arcana with custom KÌ-only cards.
- Adding all 78 tarot cards.
- Building an in-game editor.
- Parsing Markdown directly in Godot at runtime.

## Files

- `data/questions.md`: human-editable source for onboarding and card questions.
- `data/questions.generated.json`: generated runtime data read by Godot.
- `data/tarot_major_arcana.json`: remains card source of truth and gains display metadata and affinity tags.
- `tools/content/convert_questions_md.py`: converter and validator from Markdown to JSON.
- `scripts/questions/question_manager.gd`: loads generated JSON and returns question sets by card id and position.
- `scripts/tarot/tarot_manager.gd`: draws cards with hybrid 64/36 weighted randomness.
- `Takanote/🗺️_CẤU_TRÚC_DỰ_ÁN_KÌ.md`: structure document updated after implementation.

## Markdown shape

`data/questions.md` uses stable ids and readable names:

```md
# KÌ Questions

## the_fool — Kẻ Khờ (The Fool)

### past
Story: Kẻ Khờ bước qua một ngưỡng cửa cũ mà chưa hiểu hết điều mình rời bỏ.

1. Prompt text
- A | choice text | tags: trust,beginning
- B | choice text | tags: fear,avoidance

2. Prompt text
- A | choice text | tags: memory,loss
- B | choice text | tags: courage,release

3. Prompt text
- A | choice text | tags: innocence,hope
- B | choice text | tags: risk,impulse

4. Prompt text
- A | choice text | tags: learning,fall
- B | choice text | tags: freedom,unknown

5. Free: Khi Kẻ Khờ chọn bước tiếp thay vì quay lại, Ngài thấy đó là lựa chọn tốt không? Nếu là Ngài, Ngài sẽ làm gì khác?
```

Each card must contain exactly three position sections: `past`, `present`, `future`. Each section must contain one story and exactly five questions. Questions 1-4 must have choices with tags. Question 5 must be free text.

## Generated JSON shape

`data/questions.generated.json` contains:

```json
{
  "onboarding": [
    {
      "id": "current_pull",
      "prompt": "...",
      "choices": [
        {"label": "A", "text": "...", "tags": ["change", "threshold"]}
      ]
    }
  ],
  "cards": {
    "the_fool": {
      "past": {
        "story": "...",
        "questions": []
      },
      "present": {
        "story": "...",
        "questions": []
      },
      "future": {
        "story": "...",
        "questions": []
      }
    }
  }
}
```

Question objects keep `id`, `prompt`, `choices`, `tags`, and `free_text` fields. The game stores selected answer text plus tags.

## Card display metadata

`data/tarot_major_arcana.json` keeps numeric `id` and English `name`, and adds:

- `slug`: stable id such as `the_fool`.
- `display_name_vi`: Vietnamese card name shown in UI, such as `Kẻ Khờ`.
- `subtitle`: English subtitle shown in smaller text, such as `The Fool`.
- `affinity_tags`: semantic tags used for weighted drawing.

UI should prefer `display_name_vi` and show `subtitle` when present. Existing English name remains fallback.

## Card draw algorithm

`TarotManager.draw_for_answers()` builds a tag profile from onboarding answers. Each card gets:

- affinity score from matching card `affinity_tags` with onboarding answer tags.
- random score from session RNG.
- final score = `affinity_score * 0.64 + random_score * 0.36`.

The three highest-scoring cards are assigned to past, present, and future, then removed from the deck so no duplicate card appears in one spread. If no tags exist, draw becomes pure random.

## Runtime flow

1. Onboarding screen loads `onboarding` questions from `QuestionManager`.
2. Player choices produce answer dictionaries containing text and tags.
3. `TarotManager` draws three cards with hybrid 64/36 scoring.
4. Inner space screen asks `QuestionManager.get_questions_for_card_position(card_slug, position)`.
5. Screen displays the card story before or alongside the five questions.
6. AI interpretation receives card data, position, story, questions, answers, and tags.

## Error handling

- Converter fails loudly if required card sections, stories, questions, choices, or tags are missing.
- Godot never parses Markdown.
- If generated JSON is missing at runtime, `QuestionManager` returns empty sets and UI shows an explicit content error instead of crashing.
- If a card lacks Vietnamese display metadata, UI falls back to English `name`.

## Verification

Run after implementation:

```bash
rtk python tools/content/convert_questions_md.py
rtk godot --headless --path "D:/KÌ" --quit
```

Manual verification:

- Desktop browser can complete onboarding, reveal cards, enter inner spaces, answer five questions per card, and reach final report.
- Desktop browser keeps question text and buttons readable through onboarding and inner-space flow.
- Converter rejects malformed Markdown with a clear message.
- Hybrid draw changes across runs while still reflecting onboarding tags.
