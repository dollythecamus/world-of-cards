extends Area3D

var type
var data = {'biome':0}

var is_face_up = false:
	set(up):
		if up:
			if is_face_up != up:
				is_face_up = up
				animate_card_flip()

var card := GridCard3D.new()
@onready var visual = $Visual

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
var global: Vector3:
	get():
		return card.position.global
	set(v):
		card.set_global_position(v)
		position = v

func flip(up = true):
	if up:
		if is_face_up != up:
			# is_face_up = up
			animate_card_flip()

func animate_card_flip():
	const half_duration = .4
	
	if is_face_up:
		var tween0 = get_tree().create_tween().bind_node(self).set_parallel(true)
		tween0.tween_property(visual, "rotation_degrees", Vector3(0, 0, 180), half_duration)
		await tween0.finished
	else:
		var tween0 = get_tree().create_tween().bind_node(self).set_parallel(true)
		tween0.tween_property(visual, "rotation_degrees", Vector3(0, 0, 0), half_duration)
		await tween0.finished
	# halfway. switch around the front for the back
	# will give an almost 3d view of flipping the card
	# update_visual()

func update_visual():
	if GameData.is_debug_mode:
		# something to update in debug mode
		visual.rotation_degrees.z = 180.0 
		return

	if is_face_up:
		visual.rotation_degrees.z = 180.0 
		visual.modulate = Color(1.0 , 1.0, 1.0, 1.0)
	else:
		visual.rotation_degrees.z = 0.0 
		visual.modulate = Color(1.0 , 1.0, 1.0, 0.5)
