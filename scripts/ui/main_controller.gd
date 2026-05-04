extends Control

const TitleScreenScene := preload("res://scenes/title/title_screen.tscn")
const IntroScreenScene := preload("res://scenes/title/intro_screen.tscn")
const OnboardingScreenScene := preload("res://scenes/questions/onboarding_screen.tscn")
const CardRevealScreenScene := preload("res://scenes/cards/card_reveal_screen.tscn")
const InnerSpaceScreenScene := preload("res://scenes/inner_space/inner_space_screen.tscn")
const MinigameScreenScene := preload("res://scenes/minigames/minigame_screen.tscn")
const LoadingScreenScene := preload("res://scenes/ui/loading_screen.tscn")
const AIErrorScreenScene := preload("res://scenes/ui/ai_error_screen.tscn")
const FinalReportScreenScene := preload("res://scenes/report/final_report_screen.tscn")

@onready var screen_root: Control = $ScreenRoot

var current_screen: Control
var onboarding_questions: Array[Dictionary] = []
var onboarding_index := 0
var current_space_questions: Array[Dictionary] = []
var current_space_story := ""
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
	var screen := _show_screen(TitleScreenScene)
	screen.continued.connect(_show_intro)

func _show_intro() -> void:
	var screen := _show_screen(IntroScreenScene)
	screen.continued.connect(_on_title_continue)

func _on_title_continue() -> void:
	onboarding_questions = QuestionManager.get_onboarding_questions()
	onboarding_index = 0
	_show_onboarding_question()

func _show_onboarding_question() -> void:
	if onboarding_index >= onboarding_questions.size():
		_show_card_reveal()
		return
	var question := onboarding_questions[onboarding_index]
	var screen := _show_screen(OnboardingScreenScene)
	screen.choice_selected.connect(_on_onboarding_choice)
	screen.setup(question, onboarding_index, onboarding_questions.size())

func _on_onboarding_choice(question: Dictionary, choice: String) -> void:
	if not QuestionManager.is_valid_choice(question, choice):
		return
	GameState.add_onboarding_answer(QuestionManager.build_answer(question, choice))
	onboarding_index += 1
	_show_onboarding_question()

func _show_card_reveal() -> void:
	var cards := TarotManager.draw_for_answers(GameState.onboarding_answers)
	GameState.set_selected_cards(cards)
	var screen := _show_screen(CardRevealScreenScene)
	screen.continued.connect(_start_inner_spaces)
	screen.setup(cards)

func _start_inner_spaces() -> void:
	GameState.set_current_space_index(0)
	_show_current_inner_space()

func _show_current_inner_space() -> void:
	if GameState.current_space_index >= GameState.selected_cards.size():
		_show_inner_spaces_complete()
		return
	var card := GameState.selected_cards[GameState.current_space_index]
	var card_slug := TarotManager.get_slug_for_card(card)
	var card_position := String(card.get("position", ""))
	current_space_story = QuestionManager.get_story_for_card_position(card_slug, card_position)
	current_space_questions = QuestionManager.get_questions_for_card_position(card_slug, card_position)
	if current_space_questions.is_empty():
		_show_ai_error_screen("Thiếu dữ liệu câu hỏi\nKhông tìm thấy câu hỏi cho %s / %s" % [card_slug, card_position])
		return
	current_space_answers = []
	current_space_question_index = 0
	_show_inner_space_question(card)

func _show_inner_space_question(card: Dictionary) -> void:
	if current_space_question_index >= current_space_questions.size():
		_save_current_inner_space(card)
		return
	var question := current_space_questions[current_space_question_index]
	var screen := _show_screen(InnerSpaceScreenScene)
	screen.choice_selected.connect(_on_inner_space_choice)
	screen.setup(card, question, current_space_question_index, current_space_questions.size())

func _on_inner_space_choice(card: Dictionary, question: Dictionary, choice: String) -> void:
	if not QuestionManager.is_valid_choice(question, choice):
		return
	_store_inner_space_answer(card, QuestionManager.build_answer(question, choice))

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
		"story": current_space_story,
		"answers": current_space_answers.duplicate(true),
	}
	GameState.add_inner_space_result(result)
	current_minigame = MiniGameManager.create_game(card)
	_show_minigame_screen(card)

func _show_minigame_screen(card: Dictionary) -> void:
	var screen := _show_screen(MinigameScreenScene)
	screen.action_selected.connect(_on_minigame_action.bind(card))
	screen.reward_requested.connect(_on_minigame_reward.bind(card))
	screen.setup(card, current_minigame)

func _on_minigame_action(action: String, card: Dictionary) -> void:
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
		"story": current_space_story,
		"onboarding_answers": GameState.onboarding_answers.duplicate(true),
		"space_answers": current_space_answers.duplicate(true),
		"minigame_result": GameState.minigame_results.get(card_position, {}),
		"self_fragments": GameState.self_fragments,
	}

func _on_reflection_ready(space_id: String, data: Dictionary) -> void:
	pending_ai_card = {}
	GameState.set_ai_reflection(space_id, data)
	var summary := _format_ai_dictionary(data)
	_show_loading_screen("Soi chiếu %s" % _position_label(space_id), summary)
	if current_screen.has_signal("continued"):
		current_screen.continued.connect(_advance_inner_space)
	else:
		_advance_inner_space()

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
	var screen := _show_screen(AIErrorScreenScene)
	screen.retry_requested.connect(_retry_ai_request)
	screen.continue_requested.connect(_continue_after_ai_error.bind(message))
	screen.setup(message)

func _retry_ai_request() -> void:
	if not pending_ai_card.is_empty():
		_request_reflection(pending_ai_card)
	else:
		_request_final_report()

func _continue_after_ai_error(message: String) -> void:
	if not pending_ai_card.is_empty():
		_advance_inner_space()
	else:
		_show_final_report_screen(ReportBuilder.build_local_summary(message), true)

func _format_ai_dictionary(data: Dictionary) -> String:
	var lines: Array[String] = []
	for key in data.keys():
		lines.append("%s: %s" % [str(key), _format_ai_value(data[key])])
	return "\n".join(lines)

func _format_ai_value(value: Variant) -> String:
	if value is Dictionary or value is Array:
		return JSON.stringify(value)
	return str(value)

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
	var screen := _show_screen(FinalReportScreenScene)
	screen.retry_requested.connect(_request_final_report)
	screen.replay_requested.connect(_replay_from_title)
	screen.setup(report, is_local_summary, final_report_error)

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

func _show_loading_screen(title: String, body: String) -> void:
	var screen := _show_screen(LoadingScreenScene)
	screen.setup(title, body)

func _show_screen(scene: PackedScene) -> Control:
	_clear_screen()
	var screen := scene.instantiate() as Control
	screen_root.add_child(screen)
	current_screen = screen
	return screen

func _clear_screen() -> void:
	for child in screen_root.get_children():
		child.queue_free()
	current_screen = null
