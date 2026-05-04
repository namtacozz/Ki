extends Control

const CardModelScript := preload("res://scripts/minigames/card_model.gd")

@onready var screen_root: Control = $ScreenRoot

var current_screen: Control
var onboarding_questions: Array[Dictionary] = []
var onboarding_index := 0
var current_space_questions: Array[Dictionary] = []
var current_space_answers: Array[Dictionary] = []
var current_space_question_index := 0
var current_minigame: Dictionary = {}
var pending_ai_card: Dictionary = {}
var final_report_error := ""

func _ready() -> void:
	GameState.reset_run()
	AIClient.reflection_ready.connect(_on_reflection_ready)
	AIClient.report_ready.connect(_on_report_ready)
	AIClient.ai_failed.connect(_on_ai_failed)
	show_title()

func show_title() -> void:
	_show_label_screen("KÌ: Ba Lá Của Bản Ngã", "Chạm để bắt đầu hành trình soi chiếu bản thân.", _on_title_continue)

func _on_title_continue() -> void:
	onboarding_questions = QuestionManager.get_onboarding_questions()
	onboarding_index = 0
	_show_onboarding_question()

func _show_onboarding_question() -> void:
	if onboarding_index >= onboarding_questions.size():
		_show_card_reveal()
		return
	var question := onboarding_questions[onboarding_index]
	_clear_screen()
	var panel := _create_center_panel(Vector2(760, 460))
	var box := _create_panel_box(panel)
	box.add_child(_create_label("Câu hỏi %d/%d" % [onboarding_index + 1, onboarding_questions.size()], 20))
	box.add_child(_create_label(String(question.get("prompt", "")), 30))
	var choices: Variant = question.get("choices", [])
	if choices is Array:
		for choice in choices:
			var button := _create_button(String(choice))
			button.pressed.connect(_on_onboarding_choice.bind(question, String(choice)))
			box.add_child(button)
	screen_root.add_child(panel)
	current_screen = panel

func _on_onboarding_choice(question: Dictionary, choice: String) -> void:
	if not QuestionManager.is_valid_choice(question, choice):
		return
	GameState.add_onboarding_answer(QuestionManager.build_answer(question, choice))
	onboarding_index += 1
	_show_onboarding_question()

func _show_card_reveal() -> void:
	var cards := TarotManager.draw_for_answers(GameState.onboarding_answers)
	GameState.set_selected_cards(cards)
	_clear_screen()
	var panel := _create_center_panel(Vector2(980, 560))
	var box := _create_panel_box(panel)
	box.add_child(_create_label("Ba Lá Của Bản Ngã", 36))
	box.add_child(_create_label("KÌ đã đặt bài theo Quá khứ / Hiện tại / Tương lai.", 22))
	var card_row := HBoxContainer.new()
	card_row.alignment = BoxContainer.ALIGNMENT_CENTER
	card_row.add_theme_constant_override("separation", 8 if get_viewport_rect().size.x < 720 else 20)
	for card in cards:
		card_row.add_child(_create_card_panel(card))
	box.add_child(card_row)
	var button := _create_button("Bước vào không gian đầu tiên")
	button.pressed.connect(_start_inner_spaces)
	box.add_child(button)
	screen_root.add_child(panel)
	current_screen = panel

func _start_inner_spaces() -> void:
	GameState.set_current_space_index(0)
	_show_current_inner_space()

func _show_current_inner_space() -> void:
	if GameState.current_space_index >= GameState.selected_cards.size():
		_show_inner_spaces_complete()
		return
	var card := GameState.selected_cards[GameState.current_space_index]
	current_space_questions = QuestionManager.get_questions_for_position(String(card.get("position", "")))
	current_space_answers = []
	current_space_question_index = 0
	_show_inner_space_question(card)

func _show_inner_space_question(card: Dictionary) -> void:
	if current_space_question_index >= current_space_questions.size():
		_save_current_inner_space(card)
		return
	var question := current_space_questions[current_space_question_index]
	_clear_screen()
	var panel := _create_center_panel(Vector2(920, 620))
	var box := _create_panel_box(panel)
	box.add_child(_create_label(_position_label(String(card.get("position", ""))), 20))
	box.add_child(_create_label(String(card.get("name", "")), 34))
	box.add_child(_create_label(String(card.get("theme", "")), 20))
	box.add_child(_create_label(", ".join(TarotManager.get_keywords_for_card(card)), 16))
	box.add_child(_create_label("Câu hỏi %d/%d" % [current_space_question_index + 1, current_space_questions.size()], 18))
	box.add_child(_create_label(String(question.get("prompt", "")), 26))
	if QuestionManager.is_free_text_question(question):
		var input := TextEdit.new()
		input.custom_minimum_size = Vector2(_content_width(640), 120)
		box.add_child(input)
		var button := _create_button("Gửi câu trả lời")
		button.pressed.connect(_on_inner_space_answer.bind(card, question, input))
		box.add_child(button)
	else:
		var choices: Variant = question.get("choices", [])
		if choices is Array:
			for choice in choices:
				var button := _create_button(String(choice))
				button.pressed.connect(_on_inner_space_choice.bind(card, question, String(choice)))
				box.add_child(button)
	screen_root.add_child(panel)
	current_screen = panel

func _on_inner_space_choice(card: Dictionary, question: Dictionary, choice: String) -> void:
	if not QuestionManager.is_valid_choice(question, choice):
		return
	_store_inner_space_answer(card, QuestionManager.build_answer(question, choice))

func _on_inner_space_answer(card: Dictionary, question: Dictionary, input: TextEdit) -> void:
	var text := input.text.strip_edges()
	if not QuestionManager.is_valid_choice(question, text):
		return
	_store_inner_space_answer(card, QuestionManager.build_answer(question, text))

func _store_inner_space_answer(card: Dictionary, answer: Dictionary) -> void:
	var card_position := String(card.get("position", ""))
	current_space_answers.append(answer)
	GameState.add_space_answer(card_position, answer)
	current_space_question_index += 1
	_show_inner_space_question(card)

func _save_current_inner_space(card: Dictionary) -> void:
	var result := {
		"position": String(card.get("position", "")),
		"card": card.duplicate(true),
		"answers": current_space_answers.duplicate(true),
	}
	GameState.add_inner_space_result(result)
	current_minigame = MiniGameManager.create_game(card)
	_show_minigame_screen(card)

func _show_minigame_screen(card: Dictionary) -> void:
	_clear_screen()
	var panel := _create_center_panel(Vector2(920, 620))
	var box := _create_panel_box(panel)
	box.add_child(_create_label(_position_label(String(card.get("position", ""))), 20))
	box.add_child(_create_label(String(current_minigame.get("title", "Mini Game")), 34))
	box.add_child(_create_label(String(current_minigame.get("goal", "")), 22))
	box.add_child(_create_label(_minigame_hand_text(current_minigame), 18))
	if String(current_minigame.get("state", "")) == "playing":
		var detail := String(current_minigame.get("detail", ""))
		if not detail.is_empty():
			box.add_child(_create_label(detail, 18))
		var actions: Variant = current_minigame.get("actions", [])
		if actions is Array:
			for action in actions:
				var button := _create_button(String(action))
				button.pressed.connect(_on_minigame_action.bind(card, String(action)))
				box.add_child(button)
	else:
		box.add_child(_create_label(String(current_minigame.get("detail", "")), 20))
		box.add_child(_create_label(String(current_minigame.get("reward", "Self Fragment")), 22))
		var button := _create_button("Nhận Self Fragment")
		button.pressed.connect(_on_minigame_reward.bind(card))
		box.add_child(button)
	screen_root.add_child(panel)
	current_screen = panel

func _on_minigame_action(card: Dictionary, action: String) -> void:
	current_minigame = MiniGameManager.resolve_action(current_minigame, action)
	_show_minigame_screen(card)

func _on_minigame_reward(card: Dictionary) -> void:
	var card_position := String(card.get("position", ""))
	GameState.set_minigame_result(card_position, current_minigame)
	_request_reflection(card)

func _request_reflection(card: Dictionary) -> void:
	pending_ai_card = card.duplicate(true)
	var card_position := String(card.get("position", ""))
	_show_loading_screen(_position_label(card_position), "KÌ đang soi chiếu lá bài này...")
	AIClient.request_reflection(card_position, _build_reflection_context(card))

func _build_reflection_context(card: Dictionary) -> Dictionary:
	var card_position := String(card.get("position", ""))
	return {
		"position": card_position,
		"card": card.duplicate(true),
		"onboarding_answers": GameState.onboarding_answers.duplicate(true),
		"space_answers": current_space_answers.duplicate(true),
		"minigame_result": GameState.minigame_results.get(card_position, {}),
		"self_fragments": GameState.self_fragments,
	}

func _on_reflection_ready(space_id: String, data: Dictionary) -> void:
	pending_ai_card = {}
	GameState.set_ai_reflection(space_id, data)
	var summary := _format_ai_dictionary(data)
	_show_label_screen("Soi chiếu %s" % _position_label(space_id), summary, _advance_inner_space)

func _on_report_ready(data: Dictionary) -> void:
	final_report_error = ""
	var report := ReportBuilder.normalize_report(data)
	GameState.set_final_report(report)
	_show_final_report_screen(report, false)

func _on_ai_failed(message: String) -> void:
	if pending_ai_card.is_empty():
		final_report_error = message
		var report := ReportBuilder.build_local_summary(message)
		GameState.set_final_report(report)
		_show_final_report_screen(report, true)
		return
	_show_ai_error_screen(message)

func _show_ai_error_screen(message: String) -> void:
	_clear_screen()
	var panel := _create_center_panel(Vector2(820, 460))
	var box := _create_panel_box(panel)
	box.add_child(_create_label("AI proxy gặp lỗi", 34))
	box.add_child(_create_label(message, 20))
	var retry_button := _create_button("Thử lại")
	if not pending_ai_card.is_empty():
		retry_button.pressed.connect(_request_reflection.bind(pending_ai_card))
	else:
		retry_button.pressed.connect(_request_final_report)
	box.add_child(retry_button)
	var continue_button := _create_button("Tiếp tục demo")
	if not pending_ai_card.is_empty():
		continue_button.pressed.connect(_advance_inner_space)
	else:
		continue_button.pressed.connect(_show_final_report_screen.bind(ReportBuilder.build_local_summary(message), true))
	box.add_child(continue_button)
	screen_root.add_child(panel)
	current_screen = panel

func _format_ai_dictionary(data: Dictionary) -> String:
	var lines: Array[String] = []
	for key in data.keys():
		lines.append("%s: %s" % [String(key), String(data[key])])
	return "\n".join(lines)

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

func _advance_inner_space() -> void:
	GameState.set_current_space_index(GameState.current_space_index + 1)
	_show_current_inner_space()

func _show_inner_spaces_complete() -> void:
	_request_final_report()

func _request_final_report() -> void:
	pending_ai_card = {}
	final_report_error = ""
	_show_loading_screen("Bản Soi Chiếu Cuối", "KÌ đang tổng hợp hành trình của Ngài...")
	AIClient.request_final_report(ReportBuilder.build_context())

func _show_final_report_screen(report: Dictionary, is_local_summary: bool) -> void:
	_clear_screen()
	var panel := _create_center_panel(Vector2(980, 680))
	var box := _create_panel_box(panel)
	box.add_child(_create_label(String(report.get("title", "Bản Soi Chiếu Cuối")), 34))
	if is_local_summary:
		box.add_child(_create_label("Bản tạm thời. AI proxy chưa trả report hoàn chỉnh.", 18))
		if not final_report_error.is_empty():
			box.add_child(_create_label(final_report_error, 16))
	box.add_child(_create_report_field("Core self", String(report.get("core_self", ""))))
	box.add_child(_create_report_field("Past pattern", String(report.get("past_pattern", ""))))
	box.add_child(_create_report_field("Present tension", String(report.get("present_tension", ""))))
	box.add_child(_create_report_field("Future invitation", String(report.get("future_invitation", ""))))
	box.add_child(_create_report_field("Advice", String(report.get("advice", ""))))
	box.add_child(_create_report_field("Keywords", ", ".join(report.get("keywords", []))))
	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 16)
	if is_local_summary:
		var retry_button := _create_button("Thử lại AI")
		retry_button.pressed.connect(_request_final_report)
		button_row.add_child(retry_button)
	var replay_button := _create_button("Chơi lại")
	replay_button.pressed.connect(_replay_from_title)
	button_row.add_child(replay_button)
	box.add_child(button_row)
	screen_root.add_child(panel)
	current_screen = panel

func _create_report_field(title: String, body: String) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	box.add_child(_create_label(title, 18))
	box.add_child(_create_label(body, 20))
	return box

func _replay_from_title() -> void:
	GameState.reset_run()
	pending_ai_card = {}
	final_report_error = ""
	show_title()

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

func _show_label_screen(title: String, body: String, callback: Callable) -> void:
	_clear_screen()
	var panel := _create_center_panel(Vector2(720, 360))
	var box := _create_panel_box(panel)
	box.add_child(_create_label(title, 36))
	box.add_child(_create_label(body, 22))
	var button := _create_button("Tiếp tục")
	button.pressed.connect(callback)
	box.add_child(button)
	screen_root.add_child(panel)
	current_screen = panel

func _show_loading_screen(title: String, body: String) -> void:
	_clear_screen()
	var panel := _create_center_panel(Vector2(720, 320))
	var box := _create_panel_box(panel)
	box.add_child(_create_label(title, 36))
	box.add_child(_create_label(body, 22))
	screen_root.add_child(panel)
	current_screen = panel

func _create_center_panel(panel_size: Vector2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	var viewport_size := get_viewport_rect().size
	panel.custom_minimum_size = Vector2(min(panel_size.x, viewport_size.x - 24), min(panel_size.y, viewport_size.y - 24))
	return panel

func _create_panel_box(panel: PanelContainer) -> VBoxContainer:
	var margin := MarginContainer.new()
	var margin_size := 16 if get_viewport_rect().size.x < 520 else 32
	margin.add_theme_constant_override("margin_left", margin_size)
	margin.add_theme_constant_override("margin_right", margin_size)
	margin.add_theme_constant_override("margin_top", margin_size)
	margin.add_theme_constant_override("margin_bottom", margin_size)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14 if get_viewport_rect().size.x < 520 else 24)
	margin.add_child(box)
	panel.add_child(margin)
	return box

func _content_width(max_width: float) -> float:
	return min(max_width, get_viewport_rect().size.x - 80)

func _create_label(text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	return label

func _create_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(260, 56)
	return button

func _create_card_panel(card: Dictionary) -> PanelContainer:
	var panel := PanelContainer.new()
	var card_width := 280.0 if get_viewport_rect().size.x >= 720 else 96.0
	panel.custom_minimum_size = Vector2(card_width, 220)
	var box := _create_panel_box(panel)
	box.add_child(_create_label(String(card.get("position", "")), 20))
	box.add_child(_create_label(String(card.get("name", "")), 28))
	box.add_child(_create_label(String(card.get("theme", "")), 20))
	box.add_child(_create_label(", ".join(TarotManager.get_keywords_for_card(card)), 16))
	return panel

func _clear_screen() -> void:
	for child in screen_root.get_children():
		child.queue_free()
	current_screen = null
