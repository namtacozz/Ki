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
@onready var action_box: HBoxContainer = %ActionBox
@onready var reward_label: Label = %RewardLabel
@onready var reward_button: Button = %RewardButton
@onready var background_texture: TextureRect = $BackgroundTexture

const GameButtonScene := preload("res://scenes/ui/game_button.tscn")
const MinigameCardVisualScene := preload("res://scenes/ui/minigame_card_visual.tscn")

var _last_community_count := 0

func _ready() -> void:
	reward_button.pressed.connect(reward_requested.emit)
	_apply_accessibility()

func _apply_accessibility() -> void:
	if is_instance_valid(background_texture):
		if SettingsManager.settings.high_contrast:
			background_texture.modulate = Color.BLACK
		else:
			background_texture.modulate = Color.WHITE

func setup(card: Dictionary, game: Dictionary) -> void:
	position_label.text = _position_label(String(card.get("position", "")))
	title_label.text = String(game.get("title", "Mini Game"))
	goal_label.text = String(game.get("goal", ""))
	hand_label.text = _minigame_hand_text(game)
	_populate_hand_visuals(game)
	detail_label.text = String(game.get("detail", ""))
	reward_label.text = String(game.get("reward", "Mảnh Hồn"))
	_clear_actions()
	var is_playing := String(game.get("status", game.get("state", ""))) == "playing"
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
	
	var mode := String(game.get("mode", ""))
	if mode == "higher_lower":
		var last_drawn: Dictionary = game.get("last_drawn_card", {})
		if not last_drawn.is_empty():
			hand_visuals.add_child(_create_card_visual(last_drawn))
			
		var current_card: Dictionary = game.get("current_card", {})
		if not current_card.is_empty():
			hand_visuals.add_child(_create_card_visual(current_card))
	elif mode == "present_poker":
		var container := VBoxContainer.new()
		container.alignment = BoxContainer.ALIGNMENT_CENTER
		container.add_theme_constant_override("separation", 20)
		hand_visuals.add_child(container)
		
		var comm_row := HBoxContainer.new()
		comm_row.alignment = BoxContainer.ALIGNMENT_CENTER
		container.add_child(comm_row)
		
		var hole_row := HBoxContainer.new()
		hole_row.alignment = BoxContainer.ALIGNMENT_CENTER
		container.add_child(hole_row)
		
		# For standardized result fallback
		var community_cards: Array = game.get("state", game).get("community_cards", [])
		var hole_cards: Array = game.get("state", game).get("hole_cards", [])
		
		if community_cards.size() < _last_community_count:
			_last_community_count = 0
			
		for i in community_cards.size():
			var card: Variant = community_cards[i]
			if card is Dictionary:
				var visual = _create_card_visual(card)
				comm_row.add_child(visual)
				if i >= _last_community_count:
					_animate_card_appear(visual, float(i - _last_community_count) * 0.15)
		
		_last_community_count = community_cards.size()
		
		for card in hole_cards:
			if card is Dictionary:
				hole_row.add_child(_create_card_visual(card))
	else:
		var hand: Array = game.get("state", game).get("player_hand", [])
		for card in hand:
			if card is Dictionary:
				hand_visuals.add_child(_create_card_visual(card))
				
	hand_visuals.visible = hand_visuals.get_child_count() > 0

func _animate_card_appear(card_visual: Control, delay: float) -> void:
	if SettingsManager.settings.get("reduce_motion", false):
		return
		
	card_visual.scale = Vector2.ZERO
	card_visual.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_interval(delay)
	tween.tween_property(card_visual, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(card_visual, "modulate:a", 1.0, 0.3)

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
		"twenty_one_confession":
			var hand: Array = game.get("player_hand", [])
			var total := int(game.get("final_total", 0))
			var text := "Tay bài hiện tại: %s\nTổng giá trị: %d" % [CardModelScript.labels(hand), total]
			if game.get("burn_used", false):
				text += " (Đã buông bỏ một ký ức)"
			return text
		"poker":
			return "Tay bài: %s" % CardModelScript.labels(game.get("player_hand", []))
		"present_poker":
			var stage: String = game.get("stage", "pre_flop")
			var stage_text := _poker_stage_name(stage)
			var hole_cards: Array = game.get("hole_cards", [])
			var comm_cards: Array = game.get("community_cards", [])
			var text := "Giai đoạn: %s\nLá tẩy: %s" % [stage_text, CardModelScript.labels(hole_cards)]
			if not comm_cards.is_empty():
				text += " | Lá chung: %s" % CardModelScript.labels(comm_cards)
			if game.get("ended", false):
				text += "\nKẾT QUẢ: %s" % String(game.get("hand_rank_label", ""))
			return text
		_:
			return "Tay bài: %s" % CardModelScript.labels(game.get("player_hand", []))

func _poker_stage_name(stage: String) -> String:
	match stage:
		"pre_flop": return "Trước Flop"
		"flop": return "Flop"
		"turn": return "Turn"
		"river": return "River"
	return stage



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
