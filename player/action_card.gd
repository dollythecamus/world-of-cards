extends Area2D
class_name Card
# Static variables
static var cards: Array = []
static var card_sort_position := Vector2(0, 0)
static var is_sorted := false

static var width := 125.0
static var height := 255.0

# Instance vars
var card_sort_index := -1
var sorted_position := Vector2.ZERO
var sprite_rest_position := Vector2(-32, -64)
var sorted_rotation := 0.0
var is_mouse_dragging := false
var is_mouse_over := false

var velocity := Vector2.ZERO
var sprite_velocity := Vector2.ZERO
var angular_velocity := 0.0

var drag_speed := 20.0
var angular_speed := 1.0
var mouse_over_offset := Vector2(0, -20)
var is_close_threshold := 21.0

# Game data
var data = {}

# Signals
signal dropped(card)

# Nodes
@onready var visual = $Sprite
@onready var label = $Sprite/Label

var start_color := Color(1, 1, 1)
var dragging_opacity := 0.5

func _ready():
	start_color = modulate
	if not cards.has(self):
		cards.append(self)
		Sort()
	set_visuals()

static func Sort():
	var pos_index := 0
	var any_dragging := false

	for i in range(cards.size()):
		var card = cards[i]
		pos_index = i
		if any_dragging:
			pos_index = i - 1

		if card.is_mouse_dragging:
			pos_index = i - 1
			any_dragging = true

		card.card_sort_index = pos_index
		#card.set_z_index(pos_index)
		card.sorted_position = get_point_on_line(pos_index, cards.size())
		card.sorted_rotation = get_rotation_on_line(pos_index, cards.size())

	is_sorted = true

func _process(delta):
	if not is_mouse_dragging:
		if is_mouse_over:
			velocity = target_position(velocity, position, sorted_position)
			sprite_velocity = target_position(sprite_velocity, visual.position, sprite_rest_position + mouse_over_offset)
			#angular_velocity = target_rotation(angular_velocity, visual.rotation_degrees, 0.0)
		else:
			velocity = target_position(velocity, position, sorted_position)
			sprite_velocity = target_position(sprite_velocity, visual.position, sprite_rest_position)
			#angular_velocity = target_rotation(angular_velocity, visual.rotation_degrees, sorted_rotation)
	else:
		var target = get_global_mouse_position()
		velocity = target_position(velocity, position, target)
		sprite_velocity = target_position(sprite_velocity, visual.position, sprite_rest_position)
		# angular_velocity = target_rotation(angular_velocity, visual.rotation_degrees, 0.0)
	
	# not doing rotation anymore :)
	#visual.rotation += angular_velocity * angular_speed * delta
	visual.position += sprite_velocity * drag_speed * delta
	position += velocity * drag_speed * delta

func target_position(velocity: Vector2, current: Vector2, target: Vector2) -> Vector2:
	return velocity.move_toward(target - current, drag_speed);

func target_rotation(velocity : float, current: float, target: float) -> float:
	var difference = angle_difference(current, target);
	return move_toward(velocity, difference, angular_speed);  

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_on_drag_start()
		else:
			_on_drag_end()
	elif event is InputEventMouseMotion and is_mouse_dragging:
		if (position - sorted_position).length() > is_close_threshold and not is_sorted:
			Sort()

func _mouse_enter() -> void:
	is_mouse_over = true

func _mouse_exit() -> void:
	is_mouse_over = false

func _on_drag_start():
	is_mouse_dragging = true
	is_sorted = false
	set_opacity(dragging_opacity)

func _on_drag_end():
	is_mouse_dragging = false
	set_opacity(1.0)
	Sort()
	dropped_action()
	# dropped.emit(self) # emits the signal when the card is dropped, self-explanatory

func set_visuals():
	label.text = data.name + "\n" + data.description

func set_opacity(opacity: float):
	var col = start_color
	col.a = opacity
	modulate = col

# Positioning helpers
static func get_point_on_line(i: int, max: int) -> Vector2:
	var s = card_sort_position
	var dir = Vector2.RIGHT
	var bump := Vector2.ZERO
	var index := i - int(max / 2)

	if is_even(max):
		bump.y = -30.0 / max(1.0, abs(index + 0.5))
		return s + dir * (index * width + width * 0.5) + bump
	else:
		if index == 0:
			bump.y = -35.0
			return s + bump
		else:
			bump.y = 30.0 / max(1.0, abs(index))
			return s + dir * (index * width) - bump

static func get_rotation_on_line(i: int, max: int) -> float:
	var index := i - int(max / 2)
	var angle := float(index) * -15.0
	if is_even(max):
		angle -= 7.5
	return deg_to_rad(angle)

static func is_even(i: int) -> bool:
	return i % 2 == 0

##################

# actions

func dropped_action():
	var closest_area = null
	var closest_distance = INF

	for area in get_overlapping_areas():
		var distance = position.distance_to(area.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_area = area

	if closest_area:
		# closest area is the world card which this dropped card is on top of.
		closest_area.action(self)
