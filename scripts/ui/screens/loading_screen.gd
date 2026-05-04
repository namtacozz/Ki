extends Control

@onready var title_label: Label = %TitleLabel
@onready var body_label: Label = %BodyLabel

func setup(title: String, body: String) -> void:
	title_label.text = title
	body_label.text = body