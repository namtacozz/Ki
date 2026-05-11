extends Control

signal continued

@onready var card_row: HBoxContainer = %CardRow
@onready var continue_button: Button = %ContinueButton
@onready var background_texture: TextureRect = $BackgroundTexture

const TarotCardDisplayScene := preload("res://scenes/ui/tarot_card_display.tscn")

func _ready() -> void:
	continue_button.pressed.connect(continued.emit)
	_apply_accessibility()

func _apply_accessibility() -> void:
	if is_instance_valid(background_texture):
		if SettingsManager.settings.high_contrast:
			background_texture.modulate = Color.BLACK
		else:
			background_texture.modulate = Color.WHITE

func setup(cards: Array[Dictionary]) -> void:
	AudioManager.play_sfx("card_draw")
	_clear_cards()
	card_row.add_theme_constant_override("separation", 16)

	for card in cards:
		var display := TarotCardDisplayScene.instantiate()
		card_row.add_child(display)
		_setup_card_display(display, card)

func _setup_card_display(display: Node, card: Dictionary) -> void:
	display.get_node("%PositionLabel").text = String(card.get("position", "")).to_upper()
	display.get_node("%NameLabel").text = TarotManager.get_display_name_for_card(card)
	display.get_node("%SubtitleLabel").text = TarotManager.get_subtitle_for_card(card)
	display.get_node("%KeywordsLabel").text = _join_strings(TarotManager.get_keywords_for_card(card))

	var art_path := TarotManager.get_art_path_for_card(card)
	if not art_path.is_empty() and ResourceLoader.exists(art_path):
		display.get_node("%CardArt").texture = load(art_path)

func _clear_cards() -> void:
	for child in card_row.get_children():
		child.queue_free()

func _join_strings(values: Array) -> String:
	var strings: PackedStringArray = []
	for value in values:
		strings.append(String(value))
	return ", ".join(strings)
