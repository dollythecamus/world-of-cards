extends  Area2D
class_name WorldCard

enum CardType { UNEXPLORED, BIOME, STRUCTURE }
enum Biomes {OCEAN, FOREST}

var type = CardType.UNEXPLORED
var data = {"biome" : Biomes.OCEAN}

var is_face_up = false

@export var debug_color : Color

var card := GridCard.new()

@onready var visual = $Visual
@onready var visual_back = $Visual/Back
@onready var visual_front = $Visual/Front

var chunk: Vector2i:
	get():
		return card.position.chunk
	set(v):
		card.set_position(v, indexed_pos)
		position = card.position.global
var indexed_pos: Vector2i:
	get():
		return card.position.indexed_pos
	set(v):
		card.set_position(chunk, v)
		position = card.position.global
var global: Vector2:
	get():
		return card.position.global
	set(v):
		card.set_global_position(v)
		position = v

func _ready() -> void:
	update_visual()

func flip(up = true):
	if up:
		if is_face_up != up:
			is_face_up = up
			animate_card_flip()

func animate_card_flip():
	const half_duration = .1
	
	var tween0 = get_tree().create_tween().bind_node(self).set_parallel(true)
	tween0.tween_property(visual, "scale", Vector2(0, 1), half_duration)
	await tween0.finished
	# halfway. switch around the front for the back
	# will give an almost 3d view of flipping the card
	update_visual()
	
	var tween1 = get_tree().create_tween().bind_node(self).set_parallel(true)
	tween1.tween_property(visual, "scale", Vector2(1, 1), half_duration)
	await tween0.finished

func update_visual():
	if GameData.is_debug_mode:
		visual_back.z_index = -1
		visual_front.z_index = 1
		visual.modulate = debug_color
		visual_front.modulate = Color(1.0 , 1.0, 1.0, 1.0)
		visual_front.texture = get_texture()
		return

	if is_face_up:
		visual_back.z_index = -1
		visual_front.z_index = 1
		visual_front.modulate = Color(1.0 , 1.0, 1.0, 1.0)
		visual_front.texture = get_texture()
		visual.modulate = Color(1.0 , 1.0, 1.0, 1.0)
	else:
		visual_back.z_index = 1
		visual_front.z_index = -1
		visual_front.modulate = Color(1.0 , 1.0, 1.0, 0.0)
		visual.modulate = Color(1.0 , 1.0, 1.0, 0.5)

func get_texture():
	if type == CardType.BIOME:
		if data.biome == Biomes.OCEAN:
			return load("res://world/images/ocean_texture.tres")
	
	return visual_front.texture

func is_pos_over(pos) -> bool:
	return visual_back.get_rect().has_point(pos)

func action(action_card):
	var neighbors = get_parent().get_neighbors(self, 1, true)
	var player = get_parent().get_node("%Player")
	
	if action_card.data.name == "Explore":
		for n in neighbors:
			n.flip()
	if action_card.data.name == "Walk To":
		player.walk_to(chunk, indexed_pos)
