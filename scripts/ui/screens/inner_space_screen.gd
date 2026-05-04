extends Control

signal choice_selected(card: Dictionary, question: Dictionary, choice: String)

@onready var position_label: Label = %PositionLabel
@onready var card_name_label: Label = %CardNameLabel
@onready var theme_label: Label = %ThemeLabel
@onready var keywords_label: Label = %KeywordsLabel
@onready var story_label: Label = %StoryLabel
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

func setup(card: Dictionary, story: String, question: Dictionary, index: int, total: int) -> void:
	card_data = card.duplicate(true)
	question_data = question.duplicate(true)
	position_label.text = _position_label(String(card_data.get("position", "")))
	card_name_label.text = TarotManager.get_display_name_for_card(card_data)
	theme_label.text = TarotManager.get_subtitle_for_card(card_data)
	keywords_label.text = _join_strings(TarotManager.get_keywords_for_card(card_data))
	story_label.text = story
	progress_label.text = "Câu hỏi %d/%d" % [index + 1, total]
	prompt_label.text = String(question_data.get("prompt", ""))
	free_text_error_label.text = ""
	free_text_input.text = ""
	free_text_input.custom_minimum_size = Vector2(_content_width(640), 120)
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
				var choice_text := QuestionManager.get_choice_text(choice)
				var label := QuestionManager.get_choice_label(choice)
				var button_text := choice_text if label.is_empty() else "%s. %s" % [label, choice_text]
				var button := _create_button(button_text)
				button.pressed.connect(choice_selected.emit.bind(card_data, question_data, choice_text))
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
	button.custom_minimum_size = Vector2(_content_width(300), 60)
	button.add_theme_font_size_override("font_size", 18)
	return button

func _content_width(max_width: float) -> float:
	return max(0.0, min(max_width, get_viewport_rect().size.x - 80))

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

func _join_strings(values: Array) -> String:
	var strings: PackedStringArray = []
	for value in values:
		strings.append(String(value))
	return ", ".join(strings)
