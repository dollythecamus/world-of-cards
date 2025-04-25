extends Node2D

@onready var sprite = $ColorRect
@onready var label = $ColorRect/Label

var data = {}

var is_dragging = false
var DRAG_SPEED = 15

var starting_position
var velocity = Vector2()

signal dropped(card)

func _ready() -> void:
	starting_position = position
	label.text = data.name + "\n" + data.description

func _on_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
			elif !event.pressed && is_dragging: # detect when card is dropped
				is_dragging = false
				dropped.emit(self) # emits the signal when the card is dropped, self-explanatory

func target_position(vel : Vector2, pos0 : Vector2, pos1 : Vector2):
	return vel.move_toward(pos1 - pos0, DRAG_SPEED)

func _process(delta: float) -> void:
	if is_dragging:
		velocity = target_position(velocity, position, get_global_mouse_position()) 
	else:
		velocity = target_position(velocity, position, starting_position)
		
	position += velocity * delta * DRAG_SPEED
