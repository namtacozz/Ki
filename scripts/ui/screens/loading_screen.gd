extends Control

@onready var title_label: Label = %TitleLabel
@onready var body_label: Label = %BodyLabel
@onready var background_texture: TextureRect = $BackgroundTexture

func setup(title: String, body: String) -> void:
	title_label.text = title
	body_label.text = body
	_apply_accessibility()

func _apply_accessibility() -> void:
	if is_instance_valid(background_texture):
		if SettingsManager.settings.high_contrast:
			background_texture.modulate = Color.BLACK
		else:
			background_texture.modulate = Color.WHITE