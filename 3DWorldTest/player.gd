extends Node3D

var card := GridCard3D.new()

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
