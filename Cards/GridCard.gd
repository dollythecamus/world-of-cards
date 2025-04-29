class_name GridCard 
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

var global: Vector2:
	get():
		return card.position.global
	set(v):
		card.set_global_position(v)
		position = v
"""

var position = {'chunk' : Vector2i(), 'indexed_pos': Vector2i(), 'global': Vector2i()}

const SIZE = Vector2i(500, 500)
const CHUNK_SIZE = WorldGenerator.Chunk.SIZE
const SPACING = Vector2i(20, 20)
const OFFSET = SIZE + SPACING
const Z = 0.0

func set_position(chunk, indexed_pos):
	position.chunk = chunk
	position.indexed_pos = indexed_pos
	
	var chunk_offset = chunk * OFFSET * CHUNK_SIZE
	var centered = indexed_pos * OFFSET
	
	position.global = centered + chunk_offset

func set_global_position(global):
	position = get_position_from_global(global)

static func get_chunk(pos):
	return pos / (CHUNK_SIZE * OFFSET)

static func get_position_from_global(global : Vector2i):
	var chunk = get_chunk(global)
	var chunk_offset = chunk * CHUNK_SIZE
	var indexed_pos = (global - chunk_offset) / OFFSET
	return {"chunk":chunk, "indexed_pos":indexed_pos, "global": global}

static func get_globaL_from_position(chunk, indexed_pos):
	var chunk_offset = chunk * OFFSET * CHUNK_SIZE
	var centered = indexed_pos * OFFSET
	return centered + chunk_offset
	
static func get_relative(pos0, pos1):
	# calculating a distance with the global positions and converting them to distance in ammount of cards
	var distance = (pos1.global - pos0.global) / OFFSET
	
	return {'chunk':pos1.chunk - pos0.chunk, 
	'indexed_pos':pos1.indexed_pos - pos0.indexed_pos,
	'global': pos1.global - pos0.global,
	'distance':distance.length()}
