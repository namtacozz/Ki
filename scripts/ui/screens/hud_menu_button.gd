extends MarginContainer

signal pressed

@onready var menu_button: Button = %MenuButton

func _ready() -> void:
	menu_button.pressed.connect(pressed.emit)

func set_button_text(value: String) -> void:
	menu_button.text = value
