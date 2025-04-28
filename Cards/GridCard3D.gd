class_name GridCard3D
# add this as a variable to the card to put in a grid
""" # put this code in the card code to use the positioning system
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
"""

var position = {'chunk' : Vector2i(), 'indexed_pos': Vector2i(), 'global': Vector3()}

const SIZE = Vector2(2, 2)
const CHUNK_SIZE = WorldGenerator.Chunk.SIZE
const SPACING = Vector2(.1, .1)
const OFFSET = SIZE + SPACING
const Z = 1.0

func set_position(chunk, indexed_pos):
	position.chunk = chunk
	position.indexed_pos = indexed_pos
	
	var chunk_offset = Vector2(chunk) * OFFSET * Vector2(CHUNK_SIZE)
	var centered = Vector2(indexed_pos) * OFFSET
	
	var global = Vector3(
		centered.x + chunk_offset.x,
		Z,
		centered.y + chunk_offset.y
		)
	
	position.global = global

func set_global_position(global):
	position = get_position_from_global(global)

static func get_chunk(global):
	var pos = Vector2(global.x, global.z)
	return (pos / (Vector2(CHUNK_SIZE) * OFFSET)).floor() as Vector2i

static func get_position_from_global(global : Vector3):
	var chunk = get_chunk(global)
	var chunk_offset = chunk * CHUNK_SIZE
	var global2D = Vector2(global.x, global.z)
	var indexed_pos = (global2D - (chunk_offset as Vector2) )  / OFFSET
	return {"chunk":chunk, "indexed_pos":indexed_pos, "global": global}

static func get_relative(pos0, pos1):
	return {'chunk':pos1.chunk - pos0.chunk, 
	'indexed_pos':pos1.indexed_pos - pos0.indexed_pos,
	'global': pos1.global - pos0.global}
