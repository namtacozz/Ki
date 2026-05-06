extends Control

signal continued
signal settings_requested
signal guide_requested

@onready var background_texture: TextureRect = $BackgroundTexture
@onready var continue_button: Button = %ContinueButton

func _ready() -> void:
	var vbox = continue_button.get_parent()
	continue_button.queue_free() # We replace it with new buttons

	_add_btn(vbox, "Bắt đầu hành trình", continued.emit)
	_add_btn(vbox, "Cài đặt", settings_requested.emit)
	_add_btn(vbox, "Hướng dẫn", guide_requested.emit)
	_apply_accessibility()

func _apply_accessibility() -> void:
	if is_instance_valid(background_texture):
		if SettingsManager.settings.high_contrast:
			background_texture.modulate = Color.BLACK
		else:
			background_texture.modulate = Color.WHITE

const HoverButtonScript := preload("res://scripts/ui/hover_button.gd")

func _add_btn(parent: Control, text: String, callable: Callable) -> void:
	var b := Button.new()
	b.set_script(HoverButtonScript)
	b.text = text
	b.custom_minimum_size = Vector2(0, 40)
	b.pressed.connect(callable)
	parent.add_child(b)
