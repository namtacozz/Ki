extends Control

const TitleScreenScene := preload("res://scenes/title/title_screen.tscn")
const CardRevealScreenScene := preload("res://scenes/cards/card_reveal_screen.tscn")
const MinigameScreenScene := preload("res://scenes/minigames/minigame_screen.tscn")
const LoadingScreenScene := preload("res://scenes/ui/loading_screen.tscn")
const NarrativeScreenScene := preload("res://scenes/ui/narrative_screen.tscn")
const AIErrorScreenScene := preload("res://scenes/ui/ai_error_screen.tscn")
const HUDMenuButtonScene := preload("res://scenes/ui/hud_menu_button.tscn")
const FinalReportScreenScene := preload("res://scenes/report/final_report_screen.tscn")
const SettingsOverlayScript := preload("res://scripts/ui/screens/settings_overlay.gd")
const GuideOverlayScript := preload("res://scripts/ui/screens/guide_overlay.gd")
const LoadingScreenScript := preload("res://scripts/ui/screens/loading_screen.gd")

@onready var screen_root: Control = $ScreenRoot

var current_screen: Control
var onboarding_questions: Array[Dictionary] = []
var onboarding_index := 0
var current_space_questions: Array[Dictionary] = []
var current_space_story_title := ""
var current_space_story_beats: Array[String] = []
var current_space_answers: Array[Dictionary] = []
var current_space_question_index := 0
var current_minigame: Dictionary = {}
var pending_ai_card: Dictionary = {}
var final_report_error := ""
var error_mode := ""
var _last_soul_fragments := 0
var _fragments_label: Label
var _menu_button: Control
var _bgm_label: Label
var _bgm_clip: Control

func _ready() -> void:
	GameState.reset_run()
	AIClient.reflection_ready.connect(_on_reflection_ready)
	AIClient.report_ready.connect(_on_report_ready)
	AIClient.ai_failed.connect(_on_ai_failed)
	GameState.soul_fragments_changed.connect(_on_soul_fragments_changed)
	if SettingsManager.has_signal("settings_changed"):
		SettingsManager.settings_changed.connect(_on_settings_changed)
	_setup_hud()
	show_title()

func _on_settings_changed() -> void:
	if is_instance_valid(current_screen) and current_screen.has_method("_apply_accessibility"):
		current_screen.call("_apply_accessibility")

func _setup_hud() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 100
	add_child(canvas)

	var hud_root := Control.new()
	hud_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(hud_root)

	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 20)
	hud_root.add_child(margin)

	_fragments_label = Label.new()
	_fragments_label.add_theme_font_size_override("font_size", 20)
	_fragments_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	_fragments_label.text = "Mảnh Hồn: 0"
	_fragments_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(_fragments_label)

	_menu_button = HUDMenuButtonScene.instantiate() as Control
	_menu_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_root.add_child(_menu_button)
	_menu_button.connect("settings_requested", _show_settings)
	_menu_button.connect("guide_requested", _show_guide)
	_menu_button.connect("confirm_restart_requested", _restart_run)
	_menu_button.connect("confirm_title_requested", _return_to_title)
	_menu_button.show()

	var bgm_margin := MarginContainer.new()
	bgm_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bgm_margin.add_theme_constant_override("margin_right", 80)
	bgm_margin.add_theme_constant_override("margin_top", 35)
	bgm_margin.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	hud_root.add_child(bgm_margin)

	_bgm_clip = Control.new()
	_bgm_clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bgm_clip.clip_contents = true
	_bgm_clip.custom_minimum_size = Vector2(180, 24)
	bgm_margin.add_child(_bgm_clip)

	_bgm_label = Label.new()
	_bgm_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bgm_label.add_theme_font_size_override("font_size", 16)
	_bgm_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 0.7))
	_bgm_label.text = "♪ BGM: Tarot Veil"
	_bgm_label.position.x = 180
	_bgm_clip.add_child(_bgm_label)

	AudioManager.music_changed.connect(_on_music_changed)

func _on_soul_fragments_changed(amount: int) -> void:
	if amount > _last_soul_fragments:
		AudioManager.play_sfx("soul_fragment")
	_last_soul_fragments = amount
	if is_instance_valid(_fragments_label):
		_fragments_label.text = "Mảnh Hồn: %d" % amount

func show_title() -> void:
	AudioManager.play_main_theme()
	if is_instance_valid(_menu_button):
		_menu_button.show()
	var screen := _show_screen(TitleScreenScene)
	screen.continued.connect(_show_intro)
	screen.settings_requested.connect(_show_settings)
	screen.guide_requested.connect(_show_guide)

func _show_intro() -> void:
	if is_instance_valid(_menu_button):
		_menu_button.show()
	var screen := _show_screen(NarrativeScreenScene)
	screen.continued.connect(_on_title_continue)
	screen.setup("KÌ", "KÌ sẽ hỏi ba câu nhập môn, chọn ba lá Major Arcana cho Quá khứ / Hiện tại / Tương lai, rồi dẫn Ngài qua từng không gian nội tâm.")

func _on_title_continue() -> void:
	onboarding_questions = QuestionManager.get_onboarding_questions()
	onboarding_index = 0
	if onboarding_questions.is_empty():
		error_mode = "missing_onboarding"
		_show_ai_error_screen("Thiếu dữ liệu câu hỏi\nKhông tìm thấy câu hỏi nhập môn")
		return
	var intro := QuestionManager.get_onboarding_intro()
	if not intro.is_empty():
		_show_onboarding_intro(intro)
	else:
		_show_onboarding_question()

func _show_onboarding_intro(intro: String) -> void:
	var screen := _show_screen(NarrativeScreenScene)
	screen.continued.connect(_show_onboarding_question)
	screen.setup("KÌ", intro, "res://assets/characters/KI.png", "res://assets/backgrounds/bg_title_fortune_booth_ki.png")

func _show_onboarding_question() -> void:
	if onboarding_index >= onboarding_questions.size():
		_show_card_reveal()
		return
	var question := onboarding_questions[onboarding_index]
	var screen := _show_screen(NarrativeScreenScene)
	screen.choice_selected.connect(_on_onboarding_choice.bind(question))

	var prompt = question.get("prompt", "")
	var choices = question.get("choices", [])

	screen.setup("KÌ", prompt, "res://assets/characters/KI.png", "res://assets/backgrounds/bg_title_fortune_booth_ki.png")
	if QuestionManager.is_free_text_question(question):
		screen.setup_free_text()
	else:
		screen.setup_choices(choices)

func _on_onboarding_choice(choice: String, question: Dictionary) -> void:
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
	var card_id := int(card.get("id", -1))
	AudioManager.play_card_music(card_id)

	var card_slug := TarotManager.get_slug_for_card(card)
	var card_position := String(card.get("position", ""))
	current_space_story_title = QuestionManager.get_story_title_for_card_position(card_slug, card_position)
	current_space_story_beats = QuestionManager.get_story_beats_for_card_position(card_slug, card_position)
	current_space_questions = QuestionManager.get_questions_for_card_position(card_slug, card_position)
	if current_space_questions.is_empty():
		_show_missing_questions_error(card_slug, card_position)
		return
	if not current_space_story_beats.is_empty() and current_space_story_beats.size() != current_space_questions.size():
		error_mode = "story_beats_mismatch"
		_show_ai_error_screen("Thiếu dữ liệu cảnh truyện\nSố cảnh không khớp số câu hỏi cho %s / %s" % [card_slug, card_position])
		return
	_reset_inner_space_state()
	_show_next_inner_space_step(card)

func _reset_inner_space_state() -> void:
	current_space_answers = []
	current_space_question_index = 0
	error_mode = ""

func _show_missing_questions_error(card_slug: String, card_position: String) -> void:
	error_mode = "missing_questions"
	_show_ai_error_screen("Thiếu dữ liệu câu hỏi\nKhông tìm thấy câu hỏi cho %s / %s" % [card_slug, card_position])

func _show_next_inner_space_step(card: Dictionary) -> void:
	if current_space_question_index >= current_space_questions.size():
		_save_current_inner_space(card)
		return

	if current_space_question_index < current_space_story_beats.size():
		var beat := current_space_story_beats[current_space_question_index]
		if not beat.is_empty():
			_show_inner_space_story(card, beat)
			return

	_show_inner_space_question(card)

func _show_inner_space_story(card: Dictionary, beat: String) -> void:
	var screen := _show_screen(NarrativeScreenScene)
	screen.continued.connect(_show_inner_space_question.bind(card))

	var speaker = TarotManager.get_display_name_for_card(card)
	var art_path = _get_card_art_or_default(card)
	var bg_path = _get_space_background(card)

	screen.setup(speaker, beat, art_path, bg_path)

func _show_inner_space_question(card: Dictionary) -> void:
	if current_space_question_index >= current_space_questions.size():
		_save_current_inner_space(card)
		return

	var question := current_space_questions[current_space_question_index]
	var screen := _show_screen(NarrativeScreenScene)
	screen.choice_selected.connect(_on_inner_space_choice.bind(card, question))

	var speaker = TarotManager.get_display_name_for_card(card)
	var prompt = question.get("prompt", "")
	var choices = question.get("choices", [])
	var art_path = _get_card_art_or_default(card)
	var bg_path = _get_space_background(card)

	screen.setup(speaker, prompt, art_path, bg_path)
	if QuestionManager.is_free_text_question(question):
		screen.setup_free_text()
	else:
		screen.setup_choices(choices)

func _on_inner_space_choice(choice: String, card: Dictionary, question: Dictionary) -> void:
	if not QuestionManager.is_valid_choice(question, choice):
		return
	_store_inner_space_answer(card, QuestionManager.build_answer(question, choice))

func _store_inner_space_answer(card: Dictionary, answer: Dictionary) -> void:
	var card_position := String(card.get("position", ""))
	current_space_answers.append(answer)
	GameState.add_space_answer(card_position, answer)
	current_space_question_index += 1
	_show_next_inner_space_step(card)

func _save_current_inner_space(card: Dictionary) -> void:
	var story_text := "\n\n".join(current_space_story_beats)
	var result := {
		"position": String(card.get("position", "")),
		"card": card.duplicate(true),
		"story_title": current_space_story_title,
		"story_beats": current_space_story_beats.duplicate(),
		"story": story_text,
		"answers": current_space_answers.duplicate(true),
	}
	GameState.add_inner_space_result(result)

	pending_ai_card = card.duplicate(true)
	var card_position := String(card.get("position", ""))
	AIClient.request_reflection(card_position, _build_reflection_context(card))

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
	_check_reflection_ready(card_position)

func _check_reflection_ready(card_position: String) -> void:
	if GameState.ai_reflections.has(card_position):
		var data: Dictionary = GameState.ai_reflections[card_position]
		_show_reflection_summary(card_position, data)
	else:
		_show_loading_screen(_position_label(card_position), "KÌ đang lắng nghe tiếng vọng nội tâm...")

func _build_reflection_context(card: Dictionary) -> Dictionary:
	var card_position := String(card.get("position", ""))
	return {
		"position": card_position,
		"card": card.duplicate(true),
		"story_title": current_space_story_title,
		"story_beats": current_space_story_beats.duplicate(),
		"story": "\n\n".join(current_space_story_beats),
		"questions": current_space_questions.duplicate(true),
		"onboarding_answers": GameState.onboarding_answers.duplicate(true),
		"space_answers": current_space_answers.duplicate(true),
	}

func _on_reflection_ready(space_id: String, data: Dictionary) -> void:
	GameState.set_ai_reflection(space_id, data)

	if is_instance_valid(current_screen) and current_screen.get_script() == LoadingScreenScript:
		_show_reflection_summary(space_id, data)

func _show_reflection_summary(space_id: String, data: Dictionary) -> void:
	AudioManager.play_main_theme()
	pending_ai_card = {}
	var summary := _format_reflection_summary(space_id, data)
	var screen = _show_screen(NarrativeScreenScene)
	screen.setup("KÌ", summary, "res://assets/characters/KI.png", "res://assets/backgrounds/bg_ai_state_booth.png")
	screen.continued.connect(_advance_inner_space)

func _on_report_ready(data: Dictionary) -> void:
	final_report_error = ""
	var report := ReportBuilder.normalize_report(data)
	GameState.set_final_report(report)
	_show_final_report_screen(report, false)

func _on_ai_failed(message: String) -> void:
	if error_mode == "missing_questions":
		_show_ai_error_screen(message)
		return
	if pending_ai_card.is_empty():
		_handle_final_report_failure(message)
		return
	_show_ai_error_screen(message)

func _handle_final_report_failure(message: String) -> void:
	final_report_error = message
	var report := ReportBuilder.build_local_summary(message)
	GameState.set_final_report(report)
	_show_final_report_screen(report, true)

func _show_ai_error_screen(message: String) -> void:
	var screen := _show_screen(AIErrorScreenScene)
	screen.retry_requested.connect(_retry_ai_request)
	screen.continue_requested.connect(_continue_after_ai_error.bind(message))
	var can_continue := error_mode != "missing_onboarding" and error_mode != "missing_questions"
	screen.setup(message, can_continue)

func _retry_ai_request() -> void:
	if error_mode == "missing_onboarding":
		_on_title_continue()
		return
	if error_mode == "missing_questions":
		_show_current_inner_space()
		return
	if not pending_ai_card.is_empty():
		var card_position := String(pending_ai_card.get("position", ""))
		_show_loading_screen(_position_label(card_position), "KÌ đang lắng nghe tiếng vọng nội tâm...")
		AIClient.request_reflection(card_position, _build_reflection_context(pending_ai_card))
	else:
		_request_final_report()

func _continue_after_ai_error(message: String) -> void:
	if error_mode == "missing_onboarding" or error_mode == "missing_questions":
		_retry_ai_request()
		return
	if not pending_ai_card.is_empty():
		_advance_inner_space()
	else:
		_show_final_report_screen(ReportBuilder.build_local_summary(message), true)

func _format_reflection_summary(space_id: String, data: Dictionary) -> String:
	var sections: Array[String] = []
	var card_name := String(data.get("display_name_vi", data.get("name", ""))).strip_edges()
	if card_name.is_empty() and not pending_ai_card.is_empty():
		card_name = String(pending_ai_card.get("display_name_vi", pending_ai_card.get("name", ""))).strip_edges()
	if not card_name.is_empty():
		sections.append("%s — %s" % [_position_label(space_id), card_name])

	for key in ["tong_quan", "tổng_quan", "summary", "overview"]:
		var text := _string_or_empty(data.get(key, ""))
		if not text.is_empty():
			sections.append(text)
			break

	var answer_insights := _format_answer_insights(data.get("dien_giai_theo_cau_tra_loi", data.get("diễn_giải_theo_câu_trả_lời", {})))
	if not answer_insights.is_empty():
		sections.append(answer_insights)

	for key in ["mau_hinh_bong_toi", "mẫu_hình_bóng_tối", "shadow_pattern"]:
		var text := _string_or_empty(data.get(key, ""))
		if not text.is_empty():
			sections.append("Mẫu hình bóng tối: %s" % text)
			break

	if sections.is_empty():
		return _format_ai_dictionary(data)
	return "\n\n".join(sections)

func _format_answer_insights(value: Variant) -> String:
	var sections: Array[String] = []
	if value is Dictionary:
		var onboarding_lines: Array[String] = []
		var onboarding: Variant = value.get("onboarding", [])
		if onboarding is Array:
			for item in onboarding:
				var text := _string_or_empty(item)
				if not text.is_empty():
					onboarding_lines.append("• %s" % text)
		if not onboarding_lines.is_empty():
			sections.append("Điểm phản chiếu từ câu trả lời:\n%s" % "\n".join(onboarding_lines))

		var insight_lines: Array[String] = []
		var space_answers: Variant = value.get("space_answers", [])
		if space_answers is Array:
			for item in space_answers:
				if item is Dictionary:
					var text := _string_or_empty(item.get("insight", ""))
					if not text.is_empty():
						insight_lines.append("• %s" % text)
		if not insight_lines.is_empty():
			sections.append("Điểm phản chiếu trong không gian này:\n%s" % "\n".join(insight_lines))
	elif value is String:
		var text := _string_or_empty(value)
		if not text.is_empty():
			sections.append(text)
	return "\n\n".join(sections)

func _string_or_empty(value: Variant) -> String:
	if value is String:
		return value.strip_edges()
	return String(value).strip_edges()

func _format_ai_dictionary(data: Dictionary) -> String:
	var lines: Array[String] = []
	for key in data.keys():
		if key in ["card", "ngon_ngu", "ngôn_ngữ", "position", "id"]:
			continue
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
	AudioManager.play_main_theme()
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
	error_mode = ""
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

func _get_card_art_or_default(card: Dictionary) -> String:
	var art_path = TarotManager.get_art_path_for_card(card)
	return art_path if not art_path.is_empty() else "res://assets/characters/KI.png"

func _get_space_background(card: Dictionary) -> String:
	var card_position = String(card.get("position", "")).to_lower()
	match card_position:
		"past":
			return "res://assets/backgrounds/bg_space_past.png"
		"present":
			return "res://assets/backgrounds/bg_space_present.png"
		"future":
			return "res://assets/backgrounds/bg_space_future.png"
		_:
			return "res://assets/backgrounds/bg_ai_state_booth.png"

func _show_loading_screen(title: String, body: String) -> void:
	var screen := _show_screen(LoadingScreenScene)
	screen.setup(title, body)

func _show_screen(scene: PackedScene) -> Control:
	AudioManager.play_sfx("transition")
	var old_screen = current_screen

	var new_screen := scene.instantiate() as Control
	new_screen.modulate.a = 0.0
	screen_root.add_child(new_screen)
	current_screen = new_screen

	var tween := create_tween()
	if is_instance_valid(old_screen):
		tween.tween_property(old_screen, "modulate:a", 0.0, 0.3)
		tween.tween_callback(old_screen.queue_free)

	tween.tween_property(new_screen, "modulate:a", 1.0, 0.3)

	return new_screen

func _show_settings() -> void:
	add_child(SettingsOverlayScript.new())

func _show_guide() -> void:
	add_child(GuideOverlayScript.new())

func _restart_run() -> void:
	GameState.reset_run()
	_show_intro()

func _return_to_title() -> void:
	show_title()

func _clear_screen() -> void:
	for child in screen_root.get_children():
		child.queue_free()
	current_screen = null

func _process(delta: float) -> void:
	if is_instance_valid(_bgm_label) and is_instance_valid(_bgm_clip):
		_bgm_label.position.x -= delta * 50.0
		if _bgm_label.position.x < -_bgm_label.size.x - 20:
			_bgm_label.position.x = _bgm_clip.size.x + 20

func _on_music_changed(track_name: String) -> void:
	if is_instance_valid(_bgm_label) and is_instance_valid(_bgm_clip):
		_bgm_label.text = "♪ BGM: " + track_name
		_bgm_label.position.x = _bgm_clip.size.x + 20
