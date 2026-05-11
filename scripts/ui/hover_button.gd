extends Button

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_pressed)
	_update_pivot()
	item_rect_changed.connect(_update_pivot)



func _update_pivot() -> void:
	pivot_offset = size / 2.0

func _on_mouse_entered() -> void:
	AudioManager.play_sfx("hover")
	if SettingsManager.settings.get("reduce_motion", false): return
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.03, 1.03), 0.2)
	# Màu sắc đã được theme xử lý, nhưng ta có thể thêm hiệu ứng nhấn mạnh nếu cần

func _on_mouse_exited() -> void:
	if SettingsManager.settings.get("reduce_motion", false): 
		scale = Vector2(1.0, 1.0)
		return
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)

func _on_pressed() -> void:
	AudioManager.notify_user_interaction()
	AudioManager.play_sfx("click")
