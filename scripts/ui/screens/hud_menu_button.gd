extends Control

signal resume_requested
signal settings_requested
signal guide_requested
signal confirm_restart_requested
signal confirm_title_requested

@onready var menu_button: Button = %MenuButton
@onready var menu_overlay: CanvasLayer = $MenuOverlay
@onready var overlay_blocker: Control = $OverlayBlocker
@onready var resume_button: Button = %ResumeButton
@onready var settings_button: Button = %SettingsButton
@onready var guide_button: Button = %GuideButton
@onready var restart_button: Button = %RestartButton
@onready var title_button: Button = %TitleButton
@onready var confirm_dialog: ConfirmationDialog = $ConfirmDialog

var _confirm_action: String = ""

func _ready() -> void:
	menu_button.pressed.connect(show_menu)
	overlay_blocker.gui_input.connect(_on_overlay_blocker_input)
	resume_button.pressed.connect(_on_resume)
	settings_button.pressed.connect(_on_settings)
	guide_button.pressed.connect(_on_guide)
	restart_button.pressed.connect(_on_restart)
	title_button.pressed.connect(_on_title)
	confirm_dialog.confirmed.connect(_on_confirmed)

func set_button_text(value: String) -> void:
	menu_button.text = value

func show_menu() -> void:
	menu_overlay.show()
	overlay_blocker.show()
	resume_button.grab_focus()

func hide_menu() -> void:
	menu_overlay.hide()
	overlay_blocker.hide()
	confirm_dialog.hide()
	_confirm_action = ""

func _on_resume() -> void:
	hide_menu()
	resume_requested.emit()

func _on_settings() -> void:
	hide_menu()
	settings_requested.emit()

func _on_guide() -> void:
	hide_menu()
	guide_requested.emit()

func _on_restart() -> void:
	_confirm_action = "restart"
	confirm_dialog.popup_centered()

func _on_title() -> void:
	_confirm_action = "title"
	confirm_dialog.popup_centered()

func _on_confirmed() -> void:
	match _confirm_action:
		"restart":
			hide_menu()
			confirm_restart_requested.emit()
		"title":
			hide_menu()
			confirm_title_requested.emit()
	_confirm_action = ""

func _on_overlay_blocker_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		hide_menu()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		hide_menu()
		get_viewport().set_input_as_handled()
