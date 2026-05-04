extends Control

@onready var screen_root: Control = $ScreenRoot

var current_screen: Control
var onboarding_questions: Array[Dictionary] = []
var onboarding_index := 0

func _ready() -> void:
	GameState.reset_run()
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
	card_row.add_theme_constant_override("separation", 20)
	for card in cards:
		card_row.add_child(_create_card_panel(card))
	box.add_child(card_row)
	var button := _create_button("Bước vào không gian đầu tiên")
	button.pressed.connect(func(): _show_label_screen("Không Gian Nội Tâm", "Task tiếp theo sẽ mở đối thoại với lá bài đầu tiên.", func(): pass))
	box.add_child(button)
	screen_root.add_child(panel)
	current_screen = panel

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

func _create_center_panel(panel_size: Vector2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = panel_size
	return panel

func _create_panel_box(panel: PanelContainer) -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_top", 32)
	margin.add_theme_constant_override("margin_bottom", 32)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 24)
	margin.add_child(box)
	panel.add_child(margin)
	return box

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
	panel.custom_minimum_size = Vector2(280, 260)
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
