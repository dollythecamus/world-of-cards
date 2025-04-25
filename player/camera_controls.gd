extends Camera2D

var dragging := false
const SPEED = 1

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			dragging = event.pressed
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom *= 1.1  # Zoom in
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom *= 0.9  # Zoom out
	elif event is InputEventMouseMotion and dragging:
		position -= event.relative * SPEED / zoom
