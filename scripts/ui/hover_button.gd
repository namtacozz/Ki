extends Button

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_update_pivot()
	item_rect_changed.connect(_update_pivot)

func _update_pivot() -> void:
	pivot_offset = size / 2.0

func _on_mouse_entered() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.03, 1.03), 0.2)
	# Màu sắc đã được theme xử lý, nhưng ta có thể thêm hiệu ứng nhấn mạnh nếu cần

func _on_mouse_exited() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
