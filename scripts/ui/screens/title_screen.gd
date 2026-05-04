extends Control

signal continued

@onready var continue_button: Button = %ContinueButton

func _ready() -> void:
	continue_button.pressed.connect(continued.emit)
