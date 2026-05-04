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
			var choice_text := QuestionManager.get_choice_text(choice)
			var label := QuestionManager.get_choice_label(choice)
			var button_text := choice_text if label.is_empty() else "%s. %s" % [label, choice_text]
			var button := _create_button(button_text)
			button.pressed.connect(choice_selected.emit.bind(question, choice_text))
			choices_box.add_child(button)

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
