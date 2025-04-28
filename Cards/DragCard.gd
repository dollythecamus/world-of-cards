extends Node
class_name DragCard
# add this as a child of the card node you want to use to drag it around

# Static variables
static var cards: Array = []
static var groups := [Vector2(0, 0)]
static var is_sorted := false

static var width := 90.0
static var height := 135.0
static var selected_card_index := -1

# Instance vars
@export var group = -1
var card_sort_index := -1
var sorted_position := Vector2.ZERO
var sprite_rest_position := Vector2(0, 0)
var sorted_rotation := 0.0
var is_mouse_dragging := false
var is_mouse_over := false

var velocity := Vector2.ZERO
var sprite_velocity := Vector2.ZERO
var angular_velocity := 0.0
const VELOCITY_THRESHOLD = 200.0

var drag_speed := 35.0
var angular_speed := 255.0
var mouse_over_offset := Vector2(0, -20)
var is_close_threshold := 21.0

# Game data
var data = {}

@export var start_color : = Color(1, 1, 1)
@export var dragging_color : = Color(1, 1, 1)

@export var visual_path : NodePath 

@onready var visual = get_node(visual_path)
@onready var card = get_parent()

func _ready():
	if not cards.has(self):
		cards.append(self)
		Sort(group)

static func Sort(group_i):
	var pos_index := 0
	var any_dragging := false

	var myGroup = get_group(group_i)
	for i in range(myGroup.size()):
		var sort_card = myGroup[i]
		pos_index = i
		if any_dragging:
			pos_index = i - 1

		if sort_card.is_mouse_dragging:
			pos_index = i - 1
			any_dragging = true

		sort_card.card_sort_index = pos_index
		#card.set_z_index(pos_index)
		sort_card.sorted_position = get_point_on_line(pos_index, cards.size(), group_i)
		sort_card.sorted_rotation = get_rotation_on_line(pos_index, cards.size())

	is_sorted = true

func _process(delta):
	if not is_mouse_dragging:
		if is_mouse_over:
			velocity = target_position(velocity, card.position, sorted_position)
			sprite_velocity = target_position(sprite_velocity, visual.position, sprite_rest_position + mouse_over_offset)
			angular_velocity = target_rotation(angular_velocity, visual.rotation, 0.0)
		else:
			velocity = target_position(velocity, card.position, sorted_position)
			sprite_velocity = target_position(sprite_velocity, visual.position, sprite_rest_position)
			angular_velocity = target_rotation(angular_velocity, visual.rotation, sorted_rotation)
	else:
		var target = card.get_global_mouse_position()
		velocity = target_position(velocity, card.position, target)
		sprite_velocity = target_position(sprite_velocity, visual.position, sprite_rest_position)
		angular_velocity = target_rotation(angular_velocity, visual.rotation, 0.0)
	
	visual.rotation += angular_velocity * angular_speed * delta
	visual.position += sprite_velocity * drag_speed * delta
	card.position += velocity * drag_speed * delta

func target_position(vel: Vector2, current: Vector2, target: Vector2) -> Vector2:
	return vel.move_toward(target - current, drag_speed);

func target_rotation(vel : float, current: float, target: float) -> float:
	var difference = angle_difference(deg_to_rad(current), deg_to_rad(target));
	return move_toward(vel, difference, angular_speed);  

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_on_drag_start()
		else:
			_on_drag_end()
	elif event is InputEventMouseMotion and is_mouse_dragging:
		if (card.position - sorted_position).length() > is_close_threshold and not is_sorted:
			Sort(group)

func _mouse_enter() -> void:
	is_mouse_over = true

func _mouse_exit() -> void:
	is_mouse_over = false

signal dragging
func _on_drag_start():
	is_mouse_dragging = true
	is_sorted = false
	visual.modulate = dragging_color
	dragging.emit(self)

signal dragging_end
func _on_drag_end():
	is_mouse_dragging = false
	visual.modulate = start_color
	Sort(group)
	card.dropped()
	dragging_end.emit(self)
	# dropped.emit(self) # emits the signal when the card is dropped, self-explanatory

static func set_group_position(group_i, position):
	groups[group_i] = position
	Sort(group_i)

static func get_group(group_i):
	var myGroup = []
	for i in cards:
		if i.group == group_i:
			myGroup.append(i)
	return myGroup

# Positioning helpers
static func get_point_on_line(i: int, _max: int, group_i: int) -> Vector2:
	var s = groups[group_i]
	var dir = Vector2.RIGHT
	var bump := Vector2.ZERO
	var index := i - int(_max * .5)

	if is_even(_max):
		bump.y = -55.0 / max(1.0, abs(index + 0.5))
		return s + dir * (index * width + width * 0.5) + bump
	else:
		if index == 0:
			bump.y = -45.0
			return s + bump
		else:
			bump.y = 30.0 / max(1.0, abs(index))
			return s + dir * (index * width) - bump

static func get_rotation_on_line(i: int, _max: int) -> float:
	var index := i - int(_max * .5)
	var angle = index * 10.0
	if is_even(_max):
		angle += 10.0 * .5
	return deg_to_rad(angle)

static func is_even(i: int) -> bool:
	return i % 2 == 0
