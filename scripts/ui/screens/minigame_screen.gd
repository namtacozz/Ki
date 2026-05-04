extends Control

const CardModelScript := preload("res://scripts/minigames/card_model.gd")

signal action_selected(action: String)
signal reward_requested

@onready var position_label: Label = %PositionLabel
@onready var title_label: Label = %TitleLabel
@onready var goal_label: Label = %GoalLabel
@onready var hand_label: Label = %HandLabel
@onready var hand_visuals: HBoxContainer = %HandVisuals
@onready var detail_label: Label = %DetailLabel
@onready var action_box: VBoxContainer = %ActionBox
@onready var reward_label: Label = %RewardLabel
@onready var reward_button: Button = %RewardButton

func _ready() -> void:
	reward_button.pressed.connect(reward_requested.emit)

func setup(card: Dictionary, game: Dictionary) -> void:
	position_label.text = _position_label(String(card.get("position", "")))
	title_label.text = String(game.get("title", "Mini Game"))
	goal_label.text = String(game.get("goal", ""))
	hand_label.text = _minigame_hand_text(game)
	_populate_hand_visuals(game)
	detail_label.text = String(game.get("detail", ""))
	reward_label.text = String(game.get("reward", "Self Fragment"))
	_clear_actions()
	var is_playing := String(game.get("state", "")) == "playing"
	action_box.visible = is_playing
	reward_label.visible = not is_playing
	reward_button.visible = not is_playing
	if is_playing:
		var actions: Variant = game.get("actions", [])
		if actions is Array:
			for action in actions:
				var button := _create_button(String(action))
				button.pressed.connect(action_selected.emit.bind(String(action)))
				action_box.add_child(button)

func _create_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(_content_width(300), 60)
	button.add_theme_font_size_override("font_size", 18)
	return button

func _content_width(max_width: float) -> float:
	return max(0.0, min(max_width, get_viewport_rect().size.x - 80))

func _clear_actions() -> void:
	for child in action_box.get_children():
		child.queue_free()

func _populate_hand_visuals(game: Dictionary) -> void:
	for child in hand_visuals.get_children():
		child.queue_free()
	var hand: Array = game.get("player_hand", [])
	for card in hand:
		if card is Dictionary:
			hand_visuals.add_child(_create_card_visual(card))
	hand_visuals.visible = hand_visuals.get_child_count() > 0

func _create_card_visual(card: Dictionary) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(72, 104)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	var art_path: String = _card_art_path(card)
	var texture := _create_card_texture(art_path)
	if texture != null:
		box.add_child(texture)
	box.add_child(_create_small_label(String(card.get("label", ""))))
	margin.add_child(box)
	panel.add_child(margin)
	return panel

func _card_art_path(card: Dictionary) -> String:
	var art_path := String(card.get("image_path", card.get("art_path", "")))
	if art_path.is_empty() or not ResourceLoader.exists(art_path):
		return ""
	return art_path

func _create_card_texture(art_path: String) -> TextureRect:
	if art_path.is_empty():
		return null
	var texture := load(art_path) as Texture2D
	if texture == null:
		return null
	var texture_rect := TextureRect.new()
	texture_rect.texture = texture
	texture_rect.custom_minimum_size = Vector2(62, 82)
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	return texture_rect

func _create_small_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 11)
	return label

func _minigame_hand_text(game: Dictionary) -> String:
	match String(game.get("mode", "")):
		"blackjack":
			var player_hand: Array = game.get("player_hand", [])
			var dealer_hand: Array = game.get("dealer_hand", [])
			return "Ngài: %s (%d)\nKÌ: %s" % [CardModelScript.labels(player_hand), _card_hand_total(player_hand), CardModelScript.labels(dealer_hand)]
		"poker":
			return "Tay bài: %s" % CardModelScript.labels(game.get("player_hand", []))
		_:
			return "Biểu tượng mục tiêu ẩn trong lá bài. Tay bài: %s" % CardModelScript.labels(game.get("player_hand", []))

func _card_hand_total(hand: Array) -> int:
	var total := 0
	var aces := 0
	for card in hand:
		var value := int(card.get("value", 0))
		if value == 1:
			aces += 1
			total += 11
		else:
			total += min(value, 10)
	while total > 21 and aces > 0:
		total -= 10
		aces -= 1
	return total

func _position_label(card_position: String) -> String:
	match card_position.to_lower():
		"past":
			return "Quá khứ"
		"present":
			return "Hiện tại"
		"future":
			return "Tương lai"
		_:
			return card_position
