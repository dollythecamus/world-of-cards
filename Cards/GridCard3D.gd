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

static func get_global_from_position(chunk, indexed_pos):
	var chunk_offset = chunk * OFFSET * CHUNK_SIZE
	var centered = indexed_pos * OFFSET
	var g = centered + chunk_offset
	return {"chunk":chunk, "indexed_pos":indexed_pos, "global": Vector3(g.x, Z, g.y)}

static func get_relative(pos0, pos1):
	return {'chunk':pos1.chunk - pos0.chunk, 
	'indexed_pos':pos1.indexed_pos - pos0.indexed_pos,
	'global': pos1.global - pos0.global}

static func correct_position(chunk: Vector2i, indexed_pos: Vector2i) -> Dictionary:
	# Given a base chunk coordinate and an “indexed” (tile) position that
	# may lie outside that chunk by any number of chunks, compute:
	#   • the adjusted chunk coords
	#   • the wrapped “local” tile position within [0..SIZE)
	#
	# e.g. chunk=(0,0), indexed_pos=(24,0), SIZE=(10,10):
	#   dx = 24 / 10 = 2 chunks to the right
	#   new_pos.x = 24 % 10 = 4
	#   → chunk=(2,0), pos=(4,0)
	
	var p = indexed_pos
	var c = chunk

	# compute how many chunks to move in x, and wrap p.x into [0..size.x)
	var dx = int(floor(p.x / CHUNK_SIZE.x))
	p.x = int(p.x % CHUNK_SIZE.x)
	if p.x < 0:
		# fix negatives
		p.x += CHUNK_SIZE.x
		dx -= 1
	c.x += dx

	# same for y
	var dy = int(floor(p.y / CHUNK_SIZE.y))
	p.y = int(p.y % CHUNK_SIZE.y)
	if p.y < 0:
		p.y += CHUNK_SIZE.y
		dy -= 1
	c.y += dy

	return GridCard3D.get_global_from_position(c, p)
