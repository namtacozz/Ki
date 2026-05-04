extends Control

signal continued

@onready var card_row: HBoxContainer = %CardRow
@onready var continue_button: Button = %ContinueButton

func _ready() -> void:
	continue_button.pressed.connect(continued.emit)

func setup(cards: Array[Dictionary]) -> void:
	_clear_cards()
	var viewport_width := get_viewport_rect().size.x
	card_row.add_theme_constant_override("separation", 8 if viewport_width < 720 else 20)
	for card in cards:
		card_row.add_child(_create_card_panel(card))

func _create_card_panel(card: Dictionary) -> PanelContainer:
	var panel := PanelContainer.new()
	var viewport_width := get_viewport_rect().size.x
	var is_phone := viewport_width < 720
	var card_width := 280.0 if not is_phone else 104.0
	panel.custom_minimum_size = Vector2(card_width, 300 if not is_phone else 220)
	var margin := MarginContainer.new()
	var margin_size := 16 if not is_phone else 8
	margin.add_theme_constant_override("margin_left", margin_size)
	margin.add_theme_constant_override("margin_right", margin_size)
	margin.add_theme_constant_override("margin_top", margin_size)
	margin.add_theme_constant_override("margin_bottom", margin_size)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 10 if not is_phone else 6)
	box.add_child(_create_label(String(card.get("position", "")), 20 if not is_phone else 14))
	var texture := _create_card_texture(TarotManager.get_art_path_for_card(card), Vector2(card_width - margin_size * 2, 160 if not is_phone else 96))
	if texture != null:
		box.add_child(texture)
	box.add_child(_create_label(TarotManager.get_display_name_for_card(card), 28 if not is_phone else 14))
	box.add_child(_create_label(TarotManager.get_subtitle_for_card(card), 20 if not is_phone else 13))
	box.add_child(_create_label(_join_strings(TarotManager.get_keywords_for_card(card)), 16 if not is_phone else 11))
	margin.add_child(box)
	panel.add_child(margin)
	return panel

func _create_card_texture(art_path: String, texture_size: Vector2) -> TextureRect:
	if art_path.is_empty():
		return null
	var texture := load(art_path) as Texture2D
	if texture == null:
		return null
	var texture_rect := TextureRect.new()
	texture_rect.texture = texture
	texture_rect.custom_minimum_size = texture_size
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	return texture_rect

func _create_label(text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	return label

func _clear_cards() -> void:
	for child in card_row.get_children():
		child.queue_free()

func _join_strings(values: Array) -> String:
	var strings: PackedStringArray = []
	for value in values:
		strings.append(String(value))
	return ", ".join(strings)
