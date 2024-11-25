extends Node2D

var is_dragging = false
var drag_start_pos = Vector2()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if get_global_mouse_position().distance_to(global_position) < 50:  # Arbitrary size check
				is_dragging = true
				drag_start_pos = get_global_mouse_position() - global_position
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			is_dragging = false

	elif event is InputEventMouseMotion and is_dragging:
		global_position = get_global_mouse_position() - drag_start_pos
