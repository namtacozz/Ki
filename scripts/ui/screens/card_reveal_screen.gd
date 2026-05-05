extends Control

signal continued

@onready var card_row: HBoxContainer = %CardRow
@onready var continue_button: Button = %ContinueButton

func _ready() -> void:
	continue_button.pressed.connect(continued.emit)

const TarotCardDisplayScene := preload("res://scenes/ui/tarot_card_display.tscn")

func setup(cards: Array[Dictionary]) -> void:
	_clear_cards()
	var viewport_width := get_viewport_rect().size.x
	var is_phone := viewport_width < 720
	card_row.add_theme_constant_override("separation", 8 if is_phone else 20)
	
	for card in cards:
		var display := TarotCardDisplayScene.instantiate()
		card_row.add_child(display)
		_setup_card_display(display, card)
		
		if is_phone:
			_apply_phone_layout(display)

func _setup_card_display(display: Node, card: Dictionary) -> void:
	display.get_node("%PositionLabel").text = String(card.get("position", "")).to_upper()
	display.get_node("%NameLabel").text = TarotManager.get_display_name_for_card(card)
	display.get_node("%SubtitleLabel").text = TarotManager.get_subtitle_for_card(card)
	display.get_node("%KeywordsLabel").text = _join_strings(TarotManager.get_keywords_for_card(card))
	
	var art_path := TarotManager.get_art_path_for_card(card)
	if not art_path.is_empty() and FileAccess.file_exists(art_path):
		display.get_node("%CardArt").texture = load(art_path)

func _apply_phone_layout(display: Node) -> void:
	display.custom_minimum_size = Vector2(104, 220)
	display.get_node("%PositionLabel").add_theme_font_size_override("font_size", 14)
	display.get_node("%NameLabel").add_theme_font_size_override("font_size", 14)
	display.get_node("%SubtitleLabel").add_theme_font_size_override("font_size", 13)
	display.get_node("%KeywordsLabel").add_theme_font_size_override("font_size", 11)

func _clear_cards() -> void:
	for child in card_row.get_children():
		child.queue_free()

func _join_strings(values: Array) -> String:
	var strings: PackedStringArray = []
	for value in values:
		strings.append(String(value))
	return ", ".join(strings)
