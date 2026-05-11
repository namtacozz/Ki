extends Control

signal continued
signal choice_selected(choice: String)

@onready var background_texture: TextureRect = %BackgroundTexture
@onready var avatar_texture: TextureRect = %AvatarTexture
@onready var speaker_label: Label = %SpeakerLabel
@onready var body_label: RichTextLabel = %BodyLabel
@onready var continue_button: Button = %ContinueButton
@onready var choices_container: GridContainer = %ChoicesContainer
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
	continue_button.set_script(HoverButtonScript)
	submit_button.set_script(HoverButtonScript)
	continue_button.pressed.connect(_on_continue_pressed)
	submit_button.pressed.connect(_on_submit_pressed)
	if SettingsManager.has_signal("settings_changed"):
		SettingsManager.settings_changed.connect(_apply_accessibility)
	body_label.bbcode_enabled = true
	choices_container.hide()
	free_text_container.hide()

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) or event.is_action_pressed("ui_accept"):
		if _is_typing:
			get_viewport().set_input_as_handled()
			_finish_typing()
		elif not continue_button.disabled and continue_button.visible:
			get_viewport().set_input_as_handled()
			_on_continue_pressed()

func _process(delta: float) -> void:
	if _is_typing:
		_typing_timer += delta
		if _typing_timer >= _type_speed:
			_typing_timer = 0.0
			body_label.visible_characters += 1
			if body_label.visible_characters >= _full_text.length():
				_finish_typing()

func setup(speaker: String, body: String, avatar_path: String = "res://assets/characters/KI.png", bg_path: String = "res://assets/backgrounds/bg_title_fortune_booth_ki.png") -> void:
	speaker_label.text = speaker
	_full_text = body
	body_label.text = body
	
	_apply_accessibility()
	
	var is_instant = SettingsManager.settings.instant_text or not SettingsManager.settings.typewriter_enabled
	if is_instant:
		body_label.visible_characters = -1
		_finish_typing()
	else:
		body_label.visible_characters = 0
		_is_typing = true
		continue_button.disabled = true
		choices_container.hide()
		free_text_container.hide()
		_is_free_text = false
		AudioManager.play_typewriter()
	
	if FileAccess.file_exists(avatar_path):
		avatar_texture.texture = load(avatar_path)
	
	if FileAccess.file_exists(bg_path):
		background_texture.texture = load(bg_path)
		if SettingsManager.settings.high_contrast:
			background_texture.modulate = Color.BLACK
		elif bg_path != "res://assets/backgrounds/bg_title_fortune_booth_ki.png":
			background_texture.modulate = Color(0.3, 0.3, 0.3, 1.0)
		else:
			background_texture.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _apply_accessibility() -> void:
	var spd = SettingsManager.settings.text_speed
	if spd == 0: _type_speed = 0.08 # Chậm hơn nữa để rõ rệt
	elif spd == 1: _type_speed = 0.03
	else: _type_speed = 0.01
	
	if SettingsManager.settings.high_contrast:
		background_texture.modulate = Color(0, 0, 0, 1)
		avatar_texture.modulate = Color(0.5, 0.5, 0.5, 1)
		body_label.add_theme_color_override("default_color", Color.WHITE)
	else:
		avatar_texture.modulate = Color.WHITE
		body_label.remove_theme_color_override("default_color")
		# background modulate is handled in setup() based on bg type


const HoverButtonScript := preload("res://scripts/ui/hover_button.gd")

func setup_choices(choices: Array) -> void:
	_is_free_text = false
	for child in choices_container.get_children():
		child.queue_free()

	var labels := ["A", "B", "C", "D"]
	var colors := [
		Color(0.4, 0.8, 0.4),  # Green
		Color(0.9, 0.3, 0.3),  # Red
		Color(0.95, 0.8, 0.2), # Yellow
		Color(0.3, 0.6, 0.95)  # Blue
	]

	for i in range(min(choices.size(), 4)):
		var choice = choices[i]
		var choice_text := QuestionManager.get_choice_text(choice)

		var box := PanelContainer.new()
		box.custom_minimum_size = Vector2(234, 200)
		box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 12)
		margin.add_theme_constant_override("margin_top", 12)
		margin.add_theme_constant_override("margin_right", 12)
		margin.add_theme_constant_override("margin_bottom", 12)
		box.add_child(margin)

		var vbox := VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 8)
		margin.add_child(vbox)

		var label_text := Label.new()
		label_text.text = labels[i]
		label_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label_text.add_theme_font_size_override("font_size", 28)
		label_text.add_theme_color_override("font_color", colors[i])
		vbox.add_child(label_text)

		var content := Label.new()
		content.text = choice_text
		content.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content.add_theme_font_size_override("font_size", 14)
		content.size_flags_vertical = Control.SIZE_EXPAND_FILL
		vbox.add_child(content)

		var btn := Button.new()
		btn.set_script(HoverButtonScript)
		btn.text = "Chọn"
		btn.custom_minimum_size = Vector2(0, 32)
		btn.pressed.connect(_on_choice_pressed.bind(choice_text))
		vbox.add_child(btn)

		choices_container.add_child(box)

func setup_free_text() -> void:
	_is_free_text = true
	input_field.text = ""

func _finish_typing() -> void:
	_is_typing = false
	AudioManager.stop_typewriter()
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
