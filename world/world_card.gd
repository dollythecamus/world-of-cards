extends Area2D
class_name WorldCard

const WIDTH = 140
const HEIGHT = 260

enum CardType { UNEXPLORED, FOREST, VILLAGE, DUNGEON }

var type = CardType.UNEXPLORED
var is_face_up = false

var indexed_pos = Vector2i()

@onready var visual_back = $Visual/Back
@onready var visual_front = $Visual/Front

func _ready() -> void:
	update_visual()

func flip():
	is_face_up = true
	await animate_card_flip()
	#update_visual()

func animate_card_flip():
	const half_duration = .1
	
	var tween0 = get_tree().create_tween().bind_node(self).set_parallel(true)
	tween0.tween_property(visual_back, "scale", Vector2(0, 1), half_duration)
	tween0.tween_property(visual_front, "scale", Vector2(0, 1), half_duration)
	await tween0.finished
	# halfway. switch around the front for the back
	# will give an almost 3d view of flipping the card
	update_visual()
	
	var tween1 = get_tree().create_tween().bind_node(self).set_parallel(true)
	tween1.tween_property(visual_back, "scale", Vector2(1, 1), half_duration)
	tween1.tween_property(visual_front, "scale", Vector2(1, 1), half_duration)
	await tween0.finished

func update_visual():
	var d = -1 if is_face_up else 1
	visual_back.z_index = d
	visual_front.z_index = -d
	
	if is_face_up:
		modulate.a = 1.0
	else:
		modulate.a = 0.2

func _input_event(_viewport: Viewport, _event: InputEvent, _shape_idx: int) -> void:
	pass

func is_pos_over(pos) -> bool:
	return visual_back.get_rect().has_point(pos)

func action(card):
	var neighbours = get_parent().get_neighbours(self)
	
	if card.data.name == "Explore":
		for neighbour in neighbours:
			neighbour.flip()
