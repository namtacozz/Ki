# Visual Screen Scenes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert main gameplay UI from code-created panels into separate visual Godot scene files grouped under `scenes/` folders.

**Architecture:** `scenes/main.tscn` remains the shell with `ScreenRoot`. `scripts/ui/main_controller.gd` becomes the flow coordinator: it instantiates screen scenes, passes dictionaries/arrays into `setup(...)`, and listens to signals. Each screen scene owns its visible node hierarchy and only creates repeated dynamic children such as choice buttons, tarot cards, report fields, and minigame actions.

**Tech Stack:** Godot 4.x, GDScript, `.tscn` scene files, existing autoloads (`GameState`, `QuestionManager`, `TarotManager`, `MiniGameManager`, `AIClient`, `ReportBuilder`).

---

## File Structure

**Create:**
- `scenes/title/title_screen.tscn` — visual title screen.
- `scenes/title/intro_screen.tscn` — visual intro screen.
- `scenes/questions/onboarding_screen.tscn` — visual onboarding question screen.
- `scenes/cards/card_reveal_screen.tscn` — visual three-card reveal screen.
- `scenes/inner_space/inner_space_screen.tscn` — visual inner-space question screen.
- `scenes/minigames/minigame_screen.tscn` — visual mini game screen.
- `scenes/ui/loading_screen.tscn` — reusable loading/message screen.
- `scenes/ui/ai_error_screen.tscn` — visual AI error screen with retry/continue buttons.
- `scenes/report/final_report_screen.tscn` — visual final report screen.
- `scripts/ui/screens/title_screen.gd` — emits `continued` when title continues.
- `scripts/ui/screens/intro_screen.gd` — emits `continued` when intro continues.
- `scripts/ui/screens/onboarding_screen.gd` — renders current onboarding question and emits `choice_selected(question, choice)`.
- `scripts/ui/screens/card_reveal_screen.gd` — renders drawn cards and emits `continued`.
- `scripts/ui/screens/inner_space_screen.gd` — renders current inner-space question and emits `choice_selected(card, question, choice)`.
- `scripts/ui/screens/minigame_screen.gd` — renders current minigame and emits `action_selected(action)` or `reward_requested`.
- `scripts/ui/screens/loading_screen.gd` — renders title/body text.
- `scripts/ui/screens/ai_error_screen.gd` — renders error and emits `retry_requested` or `continue_requested`.
- `scripts/ui/screens/final_report_screen.gd` — renders report and emits `retry_requested` or `replay_requested`.

**Modify:**
- `scripts/ui/main_controller.gd` — replace `_create_*` screen construction with scene instantiation.
- `Takanote/🗺️_CẤU_TRÚC_DỰ_ÁN_KÌ.md` — document new scene/script structure and updated UI flow.

**Verify:**
- `rtk godot --headless --path "D:/KÌ" --quit`
- If export still needed after changes: `rtk godot --headless --path "D:/KÌ" --export-release Web "D:/KÌ/exports/web/index.html"`

---

### Task 1: Create screen script folder and reusable screen scripts

**Files:**
- Create: `scripts/ui/screens/title_screen.gd`
- Create: `scripts/ui/screens/intro_screen.gd`
- Create: `scripts/ui/screens/loading_screen.gd`
- Create: `scripts/ui/screens/ai_error_screen.gd`

- [ ] **Step 1: Create `scripts/ui/screens/title_screen.gd`**

```gdscript
extends Control

signal continued

@onready var continue_button: Button = %ContinueButton

func _ready() -> void:
	continue_button.pressed.connect(continued.emit)
```

- [ ] **Step 2: Create `scripts/ui/screens/intro_screen.gd`**

```gdscript
extends Control

signal continued

@onready var continue_button: Button = %ContinueButton

func _ready() -> void:
	continue_button.pressed.connect(continued.emit)
```

- [ ] **Step 3: Create `scripts/ui/screens/loading_screen.gd`**

```gdscript
extends Control

@onready var title_label: Label = %TitleLabel
@onready var body_label: Label = %BodyLabel

func setup(title: String, body: String) -> void:
	title_label.text = title
	body_label.text = body
```

- [ ] **Step 4: Create `scripts/ui/screens/ai_error_screen.gd`**

```gdscript
extends Control

signal retry_requested
signal continue_requested

@onready var message_label: Label = %MessageLabel
@onready var retry_button: Button = %RetryButton
@onready var continue_button: Button = %ContinueButton

func _ready() -> void:
	retry_button.pressed.connect(retry_requested.emit)
	continue_button.pressed.connect(continue_requested.emit)

func setup(message: String) -> void:
	message_label.text = message
```

- [ ] **Step 5: Run Godot syntax check**

Run: `rtk godot --headless --path "D:/KÌ" --quit`

Expected: scripts parse or fail only because matching scene files are not created yet. Continue to Task 2 before final verification.

---

### Task 2: Create title, intro, loading, and AI error visual scenes

**Files:**
- Create: `scenes/title/title_screen.tscn`
- Create: `scenes/title/intro_screen.tscn`
- Create: `scenes/ui/loading_screen.tscn`
- Create: `scenes/ui/ai_error_screen.tscn`

- [ ] **Step 1: Create `scenes/title/title_screen.tscn`**

```ini
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/ui/screens/title_screen.gd" id="1"]

[node name="TitleScreen" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
script = ExtResource("1")

[node name="Panel" type="PanelContainer" parent="."]
custom_minimum_size = Vector2(720, 360)
layout_mode = 1
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -360.0
offset_top = -180.0
offset_right = 360.0
offset_bottom = 180.0
grow_horizontal = 2
grow_vertical = 2

[node name="Margin" type="MarginContainer" parent="Panel"]
layout_mode = 2
theme_override_constants/margin_left = 32
theme_override_constants/margin_top = 32
theme_override_constants/margin_right = 32
theme_override_constants/margin_bottom = 32

[node name="Scroll" type="ScrollContainer" parent="Panel/Margin"]
layout_mode = 2
horizontal_scroll_mode = 0

[node name="Box" type="VBoxContainer" parent="Panel/Margin/Scroll"]
layout_mode = 2
size_flags_horizontal = 3
theme_override_constants/separation = 24
alignment = 1

[node name="TitleLabel" type="Label" parent="Panel/Margin/Scroll/Box"]
layout_mode = 2
theme_override_font_sizes/font_size = 36
text = "KÌ: Ba Lá Của Bản Ngã"
horizontal_alignment = 1
autowrap_mode = 3

[node name="BodyLabel" type="Label" parent="Panel/Margin/Scroll/Box"]
layout_mode = 2
theme_override_font_sizes/font_size = 22
text = "Chạm để mở cửa phòng bói của KÌ."
horizontal_alignment = 1
autowrap_mode = 3

[node name="DemoLabel" type="Label" parent="Panel/Margin/Scroll/Box"]
layout_mode = 2
theme_override_font_sizes/font_size = 18
text = "Demo: onboarding → 3 lá → 3 không gian → report cuối."
horizontal_alignment = 1
autowrap_mode = 3

[node name="ContinueButton" type="Button" parent="Panel/Margin/Scroll/Box"]
unique_name_in_owner = true
custom_minimum_size = Vector2(300, 60)
layout_mode = 2
theme_override_font_sizes/font_size = 18
text = "Tiếp tục"
```

- [ ] **Step 2: Create `scenes/title/intro_screen.tscn`**

Use same layout as title, with script `res://scripts/ui/screens/intro_screen.gd`, root name `IntroScreen`, title text `KÌ đang chờ Ngài`, body text `KÌ sẽ hỏi ba câu nhập môn, chọn ba lá Major Arcana cho Quá khứ / Hiện tại / Tương lai, rồi dẫn Ngài qua từng không gian nội tâm.`, and no `DemoLabel`.

- [ ] **Step 3: Create `scenes/ui/loading_screen.tscn`**

Use same panel layout, script `res://scripts/ui/screens/loading_screen.gd`, root name `LoadingScreen`, unique labels `%TitleLabel` and `%BodyLabel`, no button.

- [ ] **Step 4: Create `scenes/ui/ai_error_screen.tscn`**

Use same panel layout, script `res://scripts/ui/screens/ai_error_screen.gd`, root name `AIErrorScreen`, title label text `AI proxy gặp lỗi`, unique `%MessageLabel`, unique `%RetryButton` text `Thử lại`, unique `%ContinueButton` text `Tiếp tục demo`.

- [ ] **Step 5: Run Godot syntax check**

Run: `rtk godot --headless --path "D:/KÌ" --quit`

Expected: no errors from these four scenes/scripts.

---

### Task 3: Create data-driven question and card screen scripts

**Files:**
- Create: `scripts/ui/screens/onboarding_screen.gd`
- Create: `scripts/ui/screens/card_reveal_screen.gd`
- Create: `scripts/ui/screens/inner_space_screen.gd`

- [ ] **Step 1: Create `scripts/ui/screens/onboarding_screen.gd`**

```gdscript
extends Control

signal choice_selected(question: Dictionary, choice: String)

@onready var progress_label: Label = %ProgressLabel
@onready var prompt_label: Label = %PromptLabel
@onready var choices_box: VBoxContainer = %ChoicesBox

var question: Dictionary = {}

func setup(next_question: Dictionary, index: int, total: int) -> void:
	question = next_question.duplicate(true)
	progress_label.text = "Câu hỏi %d/%d" % [index + 1, total]
	prompt_label.text = String(question.get("prompt", ""))
	_clear_choices()
	var choices: Variant = question.get("choices", [])
	if choices is Array:
		for choice in choices:
			var button := _create_button(String(choice))
			button.pressed.connect(choice_selected.emit.bind(question, String(choice)))
			choices_box.add_child(button)

func _create_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(300, 60)
	button.add_theme_font_size_override("font_size", 18)
	return button

func _clear_choices() -> void:
	for child in choices_box.get_children():
		child.queue_free()
```

- [ ] **Step 2: Create `scripts/ui/screens/card_reveal_screen.gd`**

```gdscript
extends Control

signal continued

@onready var card_row: HBoxContainer = %CardRow
@onready var continue_button: Button = %ContinueButton

func _ready() -> void:
	continue_button.pressed.connect(continued.emit)

func setup(cards: Array[Dictionary]) -> void:
	_clear_cards()
	for card in cards:
		card_row.add_child(_create_card_panel(card))

func _create_card_panel(card: Dictionary) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(280, 220)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 12)
	box.add_child(_create_label(String(card.get("position", "")), 20))
	box.add_child(_create_label(String(card.get("name", "")), 28))
	box.add_child(_create_label(String(card.get("theme", "")), 20))
	box.add_child(_create_label(", ".join(TarotManager.get_keywords_for_card(card)), 16))
	margin.add_child(box)
	panel.add_child(margin)
	return panel

func _create_label(text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	return label

func _clear_cards() -> void:
	for child in card_row.get_children():
		child.queue_free()
```

- [ ] **Step 3: Create `scripts/ui/screens/inner_space_screen.gd`**

```gdscript
extends Control

signal choice_selected(card: Dictionary, question: Dictionary, choice: String)

@onready var position_label: Label = %PositionLabel
@onready var card_name_label: Label = %CardNameLabel
@onready var theme_label: Label = %ThemeLabel
@onready var keywords_label: Label = %KeywordsLabel
@onready var progress_label: Label = %ProgressLabel
@onready var prompt_label: Label = %PromptLabel
@onready var choices_box: VBoxContainer = %ChoicesBox
@onready var free_text_input: TextEdit = %FreeTextInput
@onready var free_text_error_label: Label = %FreeTextErrorLabel
@onready var submit_button: Button = %SubmitButton

var card_data: Dictionary = {}
var question_data: Dictionary = {}

func _ready() -> void:
	submit_button.pressed.connect(_submit_free_text)

func setup(card: Dictionary, question: Dictionary, index: int, total: int) -> void:
	card_data = card.duplicate(true)
	question_data = question.duplicate(true)
	position_label.text = _position_label(String(card_data.get("position", "")))
	card_name_label.text = String(card_data.get("name", ""))
	theme_label.text = String(card_data.get("theme", ""))
	keywords_label.text = ", ".join(TarotManager.get_keywords_for_card(card_data))
	progress_label.text = "Câu hỏi %d/%d" % [index + 1, total]
	prompt_label.text = String(question_data.get("prompt", ""))
	free_text_error_label.text = ""
	free_text_input.text = ""
	_clear_choices()
	var is_free_text := QuestionManager.is_free_text_question(question_data)
	free_text_input.visible = is_free_text
	free_text_error_label.visible = is_free_text
	submit_button.visible = is_free_text
	choices_box.visible = not is_free_text
	if not is_free_text:
		var choices: Variant = question_data.get("choices", [])
		if choices is Array:
			for choice in choices:
				var button := _create_button(String(choice))
				button.pressed.connect(choice_selected.emit.bind(card_data, question_data, String(choice)))
				choices_box.add_child(button)

func _submit_free_text() -> void:
	var text := free_text_input.text.strip_edges()
	if text.is_empty():
		free_text_error_label.text = "Hãy viết ít nhất một câu ngắn để KÌ có thể soi chiếu."
		return
	choice_selected.emit(card_data, question_data, text)

func _create_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(300, 60)
	button.add_theme_font_size_override("font_size", 18)
	return button

func _clear_choices() -> void:
	for child in choices_box.get_children():
		child.queue_free()

func _position_label(card_position: String) -> String:
	match card_position.to_lower():
		"past":
			return "Quá khứ"
		"present":
			return "Hiện tại"
		"future":
			return "Tương lai"
		_:
			return card_position
```

- [ ] **Step 4: Run Godot syntax check**

Run: `rtk godot --headless --path "D:/KÌ" --quit`

Expected: scripts parse or fail only because matching scenes are not created yet. Continue to Task 4 before final verification.

---

### Task 4: Create onboarding, card reveal, and inner-space visual scenes

**Files:**
- Create: `scenes/questions/onboarding_screen.tscn`
- Create: `scenes/cards/card_reveal_screen.tscn`
- Create: `scenes/inner_space/inner_space_screen.tscn`

- [ ] **Step 1: Create `scenes/questions/onboarding_screen.tscn`**

Root `Control` named `OnboardingScreen` with script `res://scripts/ui/screens/onboarding_screen.gd`. Node tree:

```text
OnboardingScreen
└── Panel: PanelContainer
    └── Margin: MarginContainer
        └── Scroll: ScrollContainer
            └── Box: VBoxContainer
                ├── ProgressLabel: Label (unique_name_in_owner = true)
                ├── PromptLabel: Label (unique_name_in_owner = true)
                └── ChoicesBox: VBoxContainer (unique_name_in_owner = true)
```

Label font sizes: `ProgressLabel = 20`, `PromptLabel = 30`. Panel minimum size: `Vector2(760, 460)`. Margin: `32` each side. Box separation: `24`, alignment center.

- [ ] **Step 2: Create `scenes/cards/card_reveal_screen.tscn`**

Root `Control` named `CardRevealScreen` with script `res://scripts/ui/screens/card_reveal_screen.gd`. Node tree:

```text
CardRevealScreen
└── Panel: PanelContainer
    └── Margin: MarginContainer
        └── Scroll: ScrollContainer
            └── Box: VBoxContainer
                ├── TitleLabel: Label text "Ba Lá Của Bản Ngã"
                ├── BodyLabel: Label text "KÌ đã đặt bài theo Quá khứ / Hiện tại / Tương lai."
                ├── CardRow: HBoxContainer (unique_name_in_owner = true)
                └── ContinueButton: Button (unique_name_in_owner = true) text "Bước vào không gian đầu tiên"
```

Panel minimum size: `Vector2(980, 560)`. `CardRow.alignment = center`, separation `20`. Button minimum size `Vector2(300, 60)`.

- [ ] **Step 3: Create `scenes/inner_space/inner_space_screen.tscn`**

Root `Control` named `InnerSpaceScreen` with script `res://scripts/ui/screens/inner_space_screen.gd`. Node tree:

```text
InnerSpaceScreen
└── Panel: PanelContainer
    └── Margin: MarginContainer
        └── Scroll: ScrollContainer
            └── Box: VBoxContainer
                ├── PositionLabel: Label (unique_name_in_owner = true)
                ├── CardNameLabel: Label (unique_name_in_owner = true)
                ├── ThemeLabel: Label (unique_name_in_owner = true)
                ├── KeywordsLabel: Label (unique_name_in_owner = true)
                ├── ProgressLabel: Label (unique_name_in_owner = true)
                ├── PromptLabel: Label (unique_name_in_owner = true)
                ├── ChoicesBox: VBoxContainer (unique_name_in_owner = true)
                ├── FreeTextInput: TextEdit (unique_name_in_owner = true)
                ├── FreeTextErrorLabel: Label (unique_name_in_owner = true)
                └── SubmitButton: Button (unique_name_in_owner = true) text "Gửi câu trả lời"
```

Panel minimum size: `Vector2(920, 620)`. `FreeTextInput.custom_minimum_size = Vector2(640, 120)`. Label font sizes: position `20`, card name `34`, theme `20`, keywords `16`, progress `18`, prompt `26`, error `16`.

- [ ] **Step 4: Run Godot syntax check**

Run: `rtk godot --headless --path "D:/KÌ" --quit`

Expected: no errors from these three scenes/scripts.

---

### Task 5: Create minigame and final report screen scripts and scenes

**Files:**
- Create: `scripts/ui/screens/minigame_screen.gd`
- Create: `scripts/ui/screens/final_report_screen.gd`
- Create: `scenes/minigames/minigame_screen.tscn`
- Create: `scenes/report/final_report_screen.tscn`

- [ ] **Step 1: Create `scripts/ui/screens/minigame_screen.gd`**

```gdscript
extends Control

const CardModelScript := preload("res://scripts/minigames/card_model.gd")

signal action_selected(action: String)
signal reward_requested

@onready var position_label: Label = %PositionLabel
@onready var title_label: Label = %TitleLabel
@onready var goal_label: Label = %GoalLabel
@onready var hand_label: Label = %HandLabel
@onready var detail_label: Label = %DetailLabel
@onready var action_box: VBoxContainer = %ActionBox
@onready var reward_label: Label = %RewardLabel
@onready var reward_button: Button = %RewardButton

func _ready() -> void:
	reward_button.pressed.connect(reward_requested.emit)

func setup(card: Dictionary, game: Dictionary) -> void:
	position_label.text = _position_label(String(card.get("position", "")))
	title_label.text = String(game.get("title", "Mini Game"))
	goal_label.text = String(game.get("goal", ""))
	hand_label.text = _minigame_hand_text(game)
	detail_label.text = String(game.get("detail", ""))
	reward_label.text = String(game.get("reward", "Self Fragment"))
	_clear_actions()
	var is_playing := String(game.get("state", "")) == "playing"
	action_box.visible = is_playing
	reward_label.visible = not is_playing
	reward_button.visible = not is_playing
	if is_playing:
		var actions: Variant = game.get("actions", [])
		if actions is Array:
			for action in actions:
				var button := _create_button(String(action))
				button.pressed.connect(action_selected.emit.bind(String(action)))
				action_box.add_child(button)

func _create_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(300, 60)
	button.add_theme_font_size_override("font_size", 18)
	return button

func _clear_actions() -> void:
	for child in action_box.get_children():
		child.queue_free()

func _minigame_hand_text(game: Dictionary) -> String:
	match String(game.get("mode", "")):
		"blackjack":
			var player_hand: Array = game.get("player_hand", [])
			var dealer_hand: Array = game.get("dealer_hand", [])
			return "Ngài: %s (%d)\nKÌ: %s" % [CardModelScript.labels(player_hand), _card_hand_total(player_hand), CardModelScript.labels(dealer_hand)]
		"poker":
			return "Tay bài: %s" % CardModelScript.labels(game.get("player_hand", []))
		_:
			return "Biểu tượng mục tiêu ẩn trong lá bài. Tay bài: %s" % CardModelScript.labels(game.get("player_hand", []))

func _card_hand_total(hand: Array) -> int:
	var total := 0
	var aces := 0
	for card in hand:
		var value := int(card.get("value", 0))
		if value == 1:
			aces += 1
			total += 11
		else:
			total += min(value, 10)
	while total > 21 and aces > 0:
		total -= 10
		aces -= 1
	return total

func _position_label(card_position: String) -> String:
	match card_position.to_lower():
		"past":
			return "Quá khứ"
		"present":
			return "Hiện tại"
		"future":
			return "Tương lai"
		_:
			return card_position
```

- [ ] **Step 2: Create `scripts/ui/screens/final_report_screen.gd`**

```gdscript
extends Control

signal retry_requested
signal replay_requested

@onready var title_label: Label = %TitleLabel
@onready var temporary_label: Label = %TemporaryLabel
@onready var error_label: Label = %ErrorLabel
@onready var fields_box: VBoxContainer = %FieldsBox
@onready var retry_button: Button = %RetryButton
@onready var replay_button: Button = %ReplayButton

func _ready() -> void:
	retry_button.pressed.connect(retry_requested.emit)
	replay_button.pressed.connect(replay_requested.emit)

func setup(report: Dictionary, is_local_summary: bool, final_report_error: String) -> void:
	title_label.text = String(report.get("title", "Bản Soi Chiếu Cuối"))
	temporary_label.visible = is_local_summary
	error_label.visible = is_local_summary and not final_report_error.is_empty()
	error_label.text = final_report_error
	retry_button.visible = is_local_summary
	_clear_fields()
	fields_box.add_child(_create_report_field("Core self", String(report.get("core_self", ""))))
	fields_box.add_child(_create_report_field("Past pattern", String(report.get("past_pattern", ""))))
	fields_box.add_child(_create_report_field("Present tension", String(report.get("present_tension", ""))))
	fields_box.add_child(_create_report_field("Future invitation", String(report.get("future_invitation", ""))))
	fields_box.add_child(_create_report_field("Advice", String(report.get("advice", ""))))
	fields_box.add_child(_create_report_field("Keywords", ", ".join(report.get("keywords", []))))

func _create_report_field(title: String, body: String) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	box.add_child(_create_label(title, 18))
	box.add_child(_create_label(body, 20))
	return box

func _create_label(text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	return label

func _clear_fields() -> void:
	for child in fields_box.get_children():
		child.queue_free()
```

- [ ] **Step 3: Create `scenes/minigames/minigame_screen.tscn`**

Root `Control` named `MinigameScreen` with script `res://scripts/ui/screens/minigame_screen.gd`. Node tree:

```text
MinigameScreen
└── Panel: PanelContainer
    └── Margin: MarginContainer
        └── Scroll: ScrollContainer
            └── Box: VBoxContainer
                ├── PositionLabel: Label (unique_name_in_owner = true)
                ├── TitleLabel: Label (unique_name_in_owner = true)
                ├── GoalLabel: Label (unique_name_in_owner = true)
                ├── HandLabel: Label (unique_name_in_owner = true)
                ├── DetailLabel: Label (unique_name_in_owner = true)
                ├── ActionBox: VBoxContainer (unique_name_in_owner = true)
                ├── RewardLabel: Label (unique_name_in_owner = true)
                └── RewardButton: Button (unique_name_in_owner = true) text "Nhận Self Fragment"
```

Panel minimum size: `Vector2(920, 620)`. Label font sizes: position `20`, title `34`, goal `22`, hand/detail/reward `18-22`.

- [ ] **Step 4: Create `scenes/report/final_report_screen.tscn`**

Root `Control` named `FinalReportScreen` with script `res://scripts/ui/screens/final_report_screen.gd`. Node tree:

```text
FinalReportScreen
└── Panel: PanelContainer
    └── Margin: MarginContainer
        └── Scroll: ScrollContainer
            └── Box: VBoxContainer
                ├── TitleLabel: Label (unique_name_in_owner = true)
                ├── TemporaryLabel: Label (unique_name_in_owner = true) text "Bản tạm thời. AI proxy chưa trả report hoàn chỉnh."
                ├── ErrorLabel: Label (unique_name_in_owner = true)
                ├── FieldsBox: VBoxContainer (unique_name_in_owner = true)
                └── ButtonRow: HBoxContainer
                    ├── RetryButton: Button (unique_name_in_owner = true) text "Thử lại AI"
                    └── ReplayButton: Button (unique_name_in_owner = true) text "Chơi lại"
```

Panel minimum size: `Vector2(980, 680)`. Button minimum size `Vector2(300, 60)`. `ButtonRow.alignment = center`, separation `16`.

- [ ] **Step 5: Run Godot syntax check**

Run: `rtk godot --headless --path "D:/KÌ" --quit`

Expected: no errors from these scenes/scripts.

---

### Task 6: Refactor `main_controller.gd` to instantiate visual scenes

**Files:**
- Modify: `scripts/ui/main_controller.gd`

- [ ] **Step 1: Add scene preloads near top of `scripts/ui/main_controller.gd`**

```gdscript
extends Control

const TitleScreenScene := preload("res://scenes/title/title_screen.tscn")
const IntroScreenScene := preload("res://scenes/title/intro_screen.tscn")
const OnboardingScreenScene := preload("res://scenes/questions/onboarding_screen.tscn")
const CardRevealScreenScene := preload("res://scenes/cards/card_reveal_screen.tscn")
const InnerSpaceScreenScene := preload("res://scenes/inner_space/inner_space_screen.tscn")
const MinigameScreenScene := preload("res://scenes/minigames/minigame_screen.tscn")
const LoadingScreenScene := preload("res://scenes/ui/loading_screen.tscn")
const AIErrorScreenScene := preload("res://scenes/ui/ai_error_screen.tscn")
const FinalReportScreenScene := preload("res://scenes/report/final_report_screen.tscn")
```

Remove `const CardModelScript := preload("res://scripts/minigames/card_model.gd")` because minigame display moves to `minigame_screen.gd`.

- [ ] **Step 2: Add helper to show screen instance**

```gdscript
func _show_screen(scene: PackedScene) -> Control:
	_clear_screen()
	var screen := scene.instantiate() as Control
	screen_root.add_child(screen)
	current_screen = screen
	return screen
```

- [ ] **Step 3: Replace `show_title()` and `_show_intro()`**

```gdscript
func show_title() -> void:
	var screen := _show_screen(TitleScreenScene)
	screen.continued.connect(_show_intro)

func _show_intro() -> void:
	var screen := _show_screen(IntroScreenScene)
	screen.continued.connect(_on_title_continue)
```

- [ ] **Step 4: Replace `_show_onboarding_question()` screen construction**

```gdscript
func _show_onboarding_question() -> void:
	if onboarding_index >= onboarding_questions.size():
		_show_card_reveal()
		return
	var question := onboarding_questions[onboarding_index]
	var screen := _show_screen(OnboardingScreenScene)
	screen.choice_selected.connect(_on_onboarding_choice)
	screen.setup(question, onboarding_index, onboarding_questions.size())
```

- [ ] **Step 5: Replace `_show_card_reveal()` screen construction**

```gdscript
func _show_card_reveal() -> void:
	var cards := TarotManager.draw_for_answers(GameState.onboarding_answers)
	GameState.set_selected_cards(cards)
	var screen := _show_screen(CardRevealScreenScene)
	screen.continued.connect(_start_inner_spaces)
	screen.setup(cards)
```

- [ ] **Step 6: Replace `_show_inner_space_question(card)` screen construction**

```gdscript
func _show_inner_space_question(card: Dictionary) -> void:
	if current_space_question_index >= current_space_questions.size():
		_save_current_inner_space(card)
		return
	var question := current_space_questions[current_space_question_index]
	var screen := _show_screen(InnerSpaceScreenScene)
	screen.choice_selected.connect(_on_inner_space_choice)
	screen.setup(card, question, current_space_question_index, current_space_questions.size())
```

- [ ] **Step 7: Replace `_on_inner_space_answer` usage**

Delete `_on_inner_space_answer(card, question, input)` because `inner_space_screen.gd` emits free-text as `choice_selected`. Keep `_on_inner_space_choice` and `_store_inner_space_answer` unchanged.

- [ ] **Step 8: Replace `_show_minigame_screen(card)` screen construction**

```gdscript
func _show_minigame_screen(card: Dictionary) -> void:
	var screen := _show_screen(MinigameScreenScene)
	screen.action_selected.connect(_on_minigame_action.bind(card))
	screen.reward_requested.connect(_on_minigame_reward.bind(card))
	screen.setup(card, current_minigame)
```

Because signal emits `action` and bind appends `card`, adjust handler signature:

```gdscript
func _on_minigame_action(action: String, card: Dictionary) -> void:
	current_minigame = MiniGameManager.resolve_action(current_minigame, action)
	_show_minigame_screen(card)
```

- [ ] **Step 9: Replace `_show_ai_error_screen(message)` screen construction**

```gdscript
func _show_ai_error_screen(message: String) -> void:
	var screen := _show_screen(AIErrorScreenScene)
	screen.retry_requested.connect(_retry_ai_request)
	screen.continue_requested.connect(_continue_after_ai_error.bind(message))
	screen.setup(message)
```

Add helpers:

```gdscript
func _retry_ai_request() -> void:
	if not pending_ai_card.is_empty():
		_request_reflection(pending_ai_card)
	else:
		_request_final_report()

func _continue_after_ai_error(message: String) -> void:
	if not pending_ai_card.is_empty():
		_advance_inner_space()
	else:
		_show_final_report_screen(ReportBuilder.build_local_summary(message), true)
```

- [ ] **Step 10: Replace `_show_final_report_screen(report, is_local_summary)` screen construction**

```gdscript
func _show_final_report_screen(report: Dictionary, is_local_summary: bool) -> void:
	var screen := _show_screen(FinalReportScreenScene)
	screen.retry_requested.connect(_request_final_report)
	screen.replay_requested.connect(_replay_from_title)
	screen.setup(report, is_local_summary, final_report_error)
```

- [ ] **Step 11: Replace `_show_loading_screen(title, body)` screen construction**

```gdscript
func _show_loading_screen(title: String, body: String) -> void:
	var screen := _show_screen(LoadingScreenScene)
	screen.setup(title, body)
```

- [ ] **Step 12: Delete obsolete UI factory helpers from `main_controller.gd`**

Remove these functions and variables from `main_controller.gd`:
- `free_text_error_label`
- `_show_label_screen`
- `_create_report_field`
- `_create_center_panel`
- `_create_panel_box`
- `_content_width`
- `_create_label`
- `_create_button`
- `_create_card_panel`
- `_minigame_hand_text`
- `_card_hand_total`

Keep `_position_label` if still used for loading/reflection titles.

- [ ] **Step 13: Run Godot syntax check**

Run: `rtk godot --headless --path "D:/KÌ" --quit`

Expected: project opens headless without parse errors.

---

### Task 7: Keep desktop-safe sizing in scene scripts

**Files:**
- Modify: `scripts/ui/screens/card_reveal_screen.gd`
- Modify: `scripts/ui/screens/onboarding_screen.gd`
- Modify: `scripts/ui/screens/inner_space_screen.gd`

- [ ] **Step 1: Add `_content_width(max_width)` helper to screens with dynamic buttons/text input**

```gdscript
func _content_width(max_width: float) -> float:
	return min(max_width, get_viewport_rect().size.x - 80)
```

Use in `_create_button(...)`:

```gdscript
button.custom_minimum_size = Vector2(_content_width(300), 60)
```

Use in `inner_space_screen.gd` setup for free text:

```gdscript
free_text_input.custom_minimum_size = Vector2(_content_width(640), 120)
```

- [ ] **Step 2: Keep readable desktop card width in `card_reveal_screen.gd`**

```gdscript
var card_width := min(280.0, max(180.0, (get_viewport_rect().size.x - 120.0) / 3.0))
panel.custom_minimum_size = Vector2(card_width, 220)
```

- [ ] **Step 3: Keep desktop-safe card row spacing in `card_reveal_screen.gd`**

```gdscript
card_row.add_theme_constant_override("separation", 20)
```

- [ ] **Step 4: Run Godot syntax check**

Run: `rtk godot --headless --path "D:/KÌ" --quit`

Expected: project opens headless without parse errors.

---

### Task 8: Update project structure document

**Files:**
- Modify: `Takanote/🗺️_CẤU_TRÚC_DỰ_ÁN_KÌ.md`

- [ ] **Step 1: Update folder tree**

Add new `scenes/` files under existing scene folders and add `scenes/ui/`:

```text
├── scenes/
│   ├── main.tscn
│   ├── title/
│   │   ├── title_screen.tscn
│   │   └── intro_screen.tscn
│   ├── questions/
│   │   └── onboarding_screen.tscn
│   ├── cards/
│   │   └── card_reveal_screen.tscn
│   ├── inner_space/
│   │   └── inner_space_screen.tscn
│   ├── minigames/
│   │   └── minigame_screen.tscn
│   ├── report/
│   │   └── final_report_screen.tscn
│   └── ui/
│       ├── loading_screen.tscn
│       └── ai_error_screen.tscn
```

Add `scripts/ui/screens/` files:

```text
│   └── ui/
│       ├── main_controller.gd
│       └── screens/
│           ├── title_screen.gd
│           ├── intro_screen.gd
│           ├── onboarding_screen.gd
│           ├── card_reveal_screen.gd
│           ├── inner_space_screen.gd
│           ├── minigame_screen.gd
│           ├── loading_screen.gd
│           ├── ai_error_screen.gd
│           └── final_report_screen.gd
```

- [ ] **Step 2: Update Scene Flow section**

Document that `MainController` swaps visual screen scenes into `ScreenRoot` rather than building all screen panels in code.

- [ ] **Step 3: Add changelog entry**

Add under structure changelog:

```markdown
### 2026-05-04 — Visual screen scene split

- Tách UI flow thành scene trực quan theo màn hình trong `scenes/title`, `scenes/questions`, `scenes/cards`, `scenes/inner_space`, `scenes/minigames`, `scenes/report`, `scenes/ui`.
- `MainController` chuyển sang vai trò điều phối flow và swap scene vào `ScreenRoot`.
- Mỗi screen script nhận data qua `setup(...)` và emit signal về controller.
```

- [ ] **Step 4: Run Godot syntax check**

Run: `rtk godot --headless --path "D:/KÌ" --quit`

Expected: project opens headless without parse errors.

---

### Task 9: Full verification and commit

**Files:**
- Modified/created files from Tasks 1-8.

- [ ] **Step 1: Check git status**

Run: `rtk git status --short`

Expected: only relevant files changed plus pre-existing unrelated modified files already present before task. Do not stage unrelated files such as `.godot/editor/filesystem_cache10`, `.godot/uid_cache.bin`, `exports/web/index.html`, `exports/web/index.pck`, or unrelated Takanote edits unless they were changed by this task.

- [ ] **Step 2: Run final Godot parse check**

Run: `rtk godot --headless --path "D:/KÌ" --quit`

Expected: exit code 0.

- [ ] **Step 3: Run web export if Godot parse passes**

Run: `rtk godot --headless --path "D:/KÌ" --export-release Web "D:/KÌ/exports/web/index.html"`

Expected: export completes. If export modifies `exports/web/index.html` or `exports/web/index.pck`, leave them unstaged unless user wants export artifact committed.

- [ ] **Step 4: Commit only task-relevant source/docs files if user asked for commit**

Run:

```bash
rtk git add scenes/title/title_screen.tscn scenes/title/intro_screen.tscn scenes/questions/onboarding_screen.tscn scenes/cards/card_reveal_screen.tscn scenes/inner_space/inner_space_screen.tscn scenes/minigames/minigame_screen.tscn scenes/ui/loading_screen.tscn scenes/ui/ai_error_screen.tscn scenes/report/final_report_screen.tscn scripts/ui/main_controller.gd scripts/ui/screens/title_screen.gd scripts/ui/screens/intro_screen.gd scripts/ui/screens/onboarding_screen.gd scripts/ui/screens/card_reveal_screen.gd scripts/ui/screens/inner_space_screen.gd scripts/ui/screens/minigame_screen.gd scripts/ui/screens/loading_screen.gd scripts/ui/screens/ai_error_screen.gd scripts/ui/screens/final_report_screen.gd Takanote/🗺️_CẤU_TRÚC_DỰ_ÁN_KÌ.md
rtk git commit -m "refactor: split gameplay screens into scenes"
```

Expected: commit succeeds if user requested commit.

---

## Self-Review

**Spec coverage:** User asked to convert code-created child scenes in `main.tscn`/controller into manageable visual `.tscn` files. Tasks create screen `.tscn` files grouped under `scenes/` folders, move display responsibilities into screen scripts, keep controller as flow coordinator, update structure docs, and verify Godot parse/export.

**Placeholder scan:** No `TBD`, `TODO`, or undefined future sections remain. Task 2 uses “same layout” shorthand for repeated `.tscn` boilerplate; acceptable because exact layout from Step 1 and explicit changed fields are provided.

**Type consistency:** Signals and setup signatures match controller refactor steps: `continued`, `choice_selected`, `action_selected`, `reward_requested`, `retry_requested`, `continue_requested`, `replay_requested`.
