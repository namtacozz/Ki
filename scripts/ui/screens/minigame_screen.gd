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

const GameButtonScene := preload("res://scenes/ui/game_button.tscn")
const MinigameCardVisualScene := preload("res://scenes/ui/minigame_card_visual.tscn")

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
				var button := GameButtonScene.instantiate() as Button
				button.text = String(action)
				button.pressed.connect(action_selected.emit.bind(String(action)))
				action_box.add_child(button)

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
	var visual := MinigameCardVisualScene.instantiate()
	var art_path := _card_art_path(card)
	if not art_path.is_empty() and FileAccess.file_exists(art_path):
		visual.get_node("%CardTexture").texture = load(art_path)
	visual.get_node("%Label").text = String(card.get("label", ""))
	return visual

func _card_art_path(card: Dictionary) -> String:
	var art_path := String(card.get("image_path", card.get("art_path", "")))
	if art_path.is_empty() or not ResourceLoader.exists(art_path):
		return ""
	return art_path

func _minigame_hand_text(game: Dictionary) -> String:
	match String(game.get("mode", "")):
		"blackjack":
			var player_hand: Array = game.get("player_hand", [])
			var dealer_hand: Array = game.get("dealer_hand", [])
			return "Ngài: %s (%d)\nKÌ: %s" % [CardModelScript.labels(player_hand), CardModelScript.calculate_blackjack_total(player_hand), CardModelScript.labels(dealer_hand)]
		"poker":
			return "Tay bài: %s" % CardModelScript.labels(game.get("player_hand", []))
		_:
			return "Biểu tượng mục tiêu ẩn trong lá bài. Tay bài: %s" % CardModelScript.labels(game.get("player_hand", []))



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
