extends Control

signal retry_requested
signal continue_requested

@onready var message_label: Label = %MessageLabel
@onready var retry_button: Button = %RetryButton
@onready var continue_button: Button = %ContinueButton

func _ready() -> void:
	retry_button.pressed.connect(retry_requested.emit)
	continue_button.pressed.connect(continue_requested.emit)

func setup(message: String, can_continue: bool = true) -> void:
	message_label.text = message
	continue_button.visible = can_continue