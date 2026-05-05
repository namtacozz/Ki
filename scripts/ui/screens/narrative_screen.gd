extends Control

signal continued
signal choice_selected(choice: String)

@onready var background_texture: TextureRect = %BackgroundTexture
@onready var avatar_texture: TextureRect = %AvatarTexture
@onready var speaker_label: Label = %SpeakerLabel
@onready var body_label: RichTextLabel = %BodyLabel
@onready var continue_button: Button = %ContinueButton
@onready var choices_container: VBoxContainer = %ChoicesContainer
@onready var dialogue_box: Control = %DialogueBox

@onready var free_text_container: VBoxContainer = %FreeTextContainer
@onready var input_field: TextEdit = %InputField
@onready var submit_button: Button = %SubmitButton

var _full_text := ""
var _is_typing := false
var _type_speed := 0.03
var _typing_timer := 0.0
var _is_free_text := false

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	submit_button.pressed.connect(_on_submit_pressed)
	body_label.bbcode_enabled = true
	choices_container.hide()
	free_text_container.hide()

func _input(event: InputEvent) -> void:
	if not _is_typing:
		return
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_finish_typing()

func _process(delta: float) -> void:
	if _is_typing:
		_typing_timer += delta
		if _typing_timer >= _type_speed:
			_typing_timer = 0.0
			body_label.visible_characters += 1
			if body_label.visible_characters >= _full_text.length():
				_finish_typing()

func setup(speaker: String, body: String, avatar_path: String = "res://assets/characters/ki_avatar.jpg", bg_path: String = "res://assets/backgrounds/opening.jpg") -> void:
	speaker_label.text = speaker
	_full_text = body
	body_label.text = body
	body_label.visible_characters = 0
	_is_typing = true
	continue_button.disabled = true
	choices_container.hide()
	free_text_container.hide()
	_is_free_text = false
	
	if FileAccess.file_exists(avatar_path):
		avatar_texture.texture = load(avatar_path)
	
	if FileAccess.file_exists(bg_path):
		background_texture.texture = load(bg_path)
		if bg_path != "res://assets/backgrounds/opening.jpg":
			background_texture.modulate = Color(0.3, 0.3, 0.3, 1.0)
		else:
			background_texture.modulate = Color(1.0, 1.0, 1.0, 1.0)

const ChoiceButtonScene := preload("res://scenes/ui/choice_button.tscn")

func setup_choices(choices: Array) -> void:
	_is_free_text = false
	for child in choices_container.get_children():
		child.queue_free()
	
	for choice in choices:
		var btn := ChoiceButtonScene.instantiate() as Button
		var choice_text := QuestionManager.get_choice_text(choice)
		var choice_label := QuestionManager.get_choice_label(choice)
		
		if choice_label.is_empty():
			btn.text = choice_text
		else:
			btn.text = choice_label + ". " + choice_text
			
		btn.pressed.connect(_on_choice_pressed.bind(choice_text))
		choices_container.add_child(btn)

func setup_free_text() -> void:
	_is_free_text = true
	input_field.text = ""

func _finish_typing() -> void:
	_is_typing = false
	body_label.visible_characters = -1
	continue_button.disabled = false
	
	if _is_free_text:
		free_text_container.show()
		continue_button.hide()
	elif choices_container.get_child_count() > 0:
		choices_container.show()
		continue_button.hide()
	else:
		continue_button.show()

func _on_continue_pressed() -> void:
	if _is_typing:
		_finish_typing()
	else:
		continued.emit()

func _on_choice_pressed(choice: String) -> void:
	choice_selected.emit(choice)

func _on_submit_pressed() -> void:
	var text := input_field.text.strip_edges()
	if not text.is_empty():
		choice_selected.emit(text)
