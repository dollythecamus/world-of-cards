extends Node
class_name WorldGenerator

@export var card_scene: PackedScene
const CHUNKS_FILE = "user://chunks.save"

var world_data = {}

var loaded_chunks = {}
var all_chunks = {}  # Dictionary to store all ever-loaded chunks
var world_cards = [] # bi dimensional array

@export var noise : Noise
@onready var player = %Player

var load_target = GridCard.get_position_from_global(Vector2(0, 0))
var target 

var permanent_cards = {} # TODO: important structures always get loaded so the player knows where they are

const RENDER_DISTANCE = 2
const UNLOAD_DISTANCE = 6

func _ready():
	set_process(false)
	
	#_load_all_chunks_from_file()

func _exit_tree():
	_save_all_chunks_to_file()

func _save_all_chunks_to_file():
	if not FileAccess.file_exists(CHUNKS_FILE):
		FileAccess.open(CHUNKS_FILE, FileAccess.WRITE).close()
	var file = FileAccess.open(CHUNKS_FILE, FileAccess.WRITE)
	if file:
		file.store_var(all_chunks)
		file.close()

func _load_all_chunks_from_file():
	var file = FileAccess.open(CHUNKS_FILE, FileAccess.READ)
	if file:
		if file.get_length() > 0:
			all_chunks = file.get_var()
		file.close()

func _process(_delta):
	load_target = get_target(target)
	load_chunks_around_target()
	# Unload chunks that are too far based on distance
	var max_distance = UNLOAD_DISTANCE  # Maximum distance in chunks to keep loaded
	var chunks_to_unload = []

	for chunk in loaded_chunks.keys():
		if chunk.distance_to(load_target.chunk) > max_distance: # distance around the player chunk 
			if chunk == load_target.chunk:
				continue
			chunks_to_unload.append(chunk)

	for chunk in chunks_to_unload:
		unload_chunk(chunk)

func load_chunk(chunk : Vector2i):
	if loaded_chunks.has(chunk):
		return  # Chunk is already loaded
	
	loaded_chunks[chunk] = {}
	
	if all_chunks.has(chunk):
		for card_data in all_chunks[chunk].values():
			var card = card_scene.instantiate()
			card.type = card_data["type"]
			card.data.biome = card_data['biome']
			card.is_face_up = card_data["is_face_up"]
			card.indexed_pos = card_data["indexed_pos"]
			card.chunk = chunk
			var chunk_offset = chunk * GridCard.OFFSET * Chunk.SIZE
			
			card.position = card.indexed_pos * GridCard.OFFSET + chunk_offset
			
			add_child(card)
			loaded_chunks[chunk][card.indexed_pos] = card
	else:
		generate_chunk(chunk)

func unload_chunk(chunk : Vector2i):
	if not loaded_chunks.has(chunk):
		return  # Chunk is not loaded
	
	all_chunks[chunk] = {}
	
	for card in loaded_chunks[chunk].values():
		all_chunks[chunk][card.indexed_pos] = {
			"type": card.type,
			"is_face_up": card.is_face_up,
			"indexed_pos": card.indexed_pos,
			"biome": card.data.biome
		}
		card.queue_free()
	
	loaded_chunks.erase(chunk)

func generate_chunk(chunk):
	# Generate new chunk
	for x in Chunk.SIZE.x:
		for y in  Chunk.SIZE.y:
			var card = card_scene.instantiate()
			
			card.indexed_pos = Vector2i(x, y)
			card.chunk = chunk
			
			# here we go. generating a world
			# first: make natural world
			# all cards are biomes, by default for now it's an island
			if GameData.world.type == "islands":
				card.type = WorldCard.CardType.BIOME
				card.data.biome = WorldCard.Biomes.OCEAN
				for isl in GameData.world.islands:
					var dis = isl.distance
					var dir = Vector2.from_angle(deg_to_rad(isl.direction_angle))
					var radius = isl.island_radius
					var noise_scale = isl.island_noise_scale
					
					noise.frequency = noise_scale
					
					# pick a position for the center of the island, based on the distance from the player
					# var reference = player.get_pos()
					
					if dis != 0:
						# generate some island around the specified center of island
						var island_center = (dis * GridCard.OFFSET) * dir
						
						var reference = island_center as Vector2
						var n = noise.get_noise_2dv(card.global)
						var effective_distance = (n + radius) * GridCard.OFFSET.length()
						if card.global.distance_to(reference) < effective_distance:
							card.data.biome = WorldCard.Biomes.FOREST
					else:
						
						# generate some island around the player (distance zero)
						var reference = player.global
						var n = noise.get_noise_2dv(card.global)
						var effective_distance = (n + radius) * GridCard.OFFSET.length()
						if card.global.distance_to(reference) < effective_distance:
							card.data.biome = WorldCard.Biomes.FOREST
			
			add_child(card)
			loaded_chunks[chunk][card.indexed_pos] = card

func is_loaded(chunk):
	return loaded_chunks.has(chunk)

func get_card(chunk, pos):
	return loaded_chunks[chunk][pos]

func get_neighbors(card, distance = 1, is_circle = false, radius = distance):
	var neighbors = []

	for dx in range(-distance, distance + 1):
		for dy in range(-distance, distance + 1):
			if dx == 0 and dy == 0:
				continue  # Skip the card itself
			
			var pos = Vector2i(card.indexed_pos.x + dx, card.indexed_pos.y + dy)
			var n = correct_position(card.chunk, pos)
			
			# card.card_position is strange maybe correct that 
			if is_circle && GridCard.get_relative(card.card_position, n).distance > radius: # skip outside of a radius
				continue
			
			if loaded_chunks.has(n.chunk) and loaded_chunks[n.chunk][n.indexed_pos]:
				neighbors.append(loaded_chunks[n.chunk][n.indexed_pos])
	return neighbors

func correct_position(chunk: Vector2i, indexed_pos: Vector2i) -> Dictionary:
	# Given a base chunk coordinate and an “indexed” (tile) position that
	# may lie outside that chunk by any number of chunks, compute:
	#   • the adjusted chunk coords
	#   • the wrapped “local” tile position within [0..SIZE)
	#
	# e.g. chunk=(0,0), indexed_pos=(24,0), SIZE=(10,10):
	#   dx = 24 / 10 = 2 chunks to the right
	#   new_pos.x = 24 % 10 = 4
	#   → chunk=(2,0), pos=(4,0)
	#
	var size = Chunk.SIZE  # assume a Vector2i
	var p = indexed_pos
	var c = chunk

	# compute how many chunks to move in x, and wrap p.x into [0..size.x)
	var dx = int(floor(p.x / size.x))
	p.x = int(p.x % size.x)
	if p.x < 0:
		# fix negatives
		p.x += size.x
		dx -= 1
	c.x += dx

	# same for y
	var dy = int(floor(p.y / size.y))
	p.y = int(p.y % size.y)
	if p.y < 0:
		p.y += size.y
		dy -= 1
	c.y += dy

	return {'chunk': c, 'indexed_pos':p, 'global':GridCard.get_globaL_from_position(c, p)}

func load_chunks_around_target(render_distance = RENDER_DISTANCE):
	if not is_loaded(load_target.chunk):
		load_chunk(load_target.chunk)
	
	for dx in range(-render_distance, render_distance + 1):  # Load chunks in a grid around the target
		for dy in range(-render_distance, render_distance + 1):
			var d = Vector2i(dx, dy)
			if not is_loaded(load_target.chunk + d): # only loads new chunks when the player moved to an unloaded place 
				load_chunk(load_target.chunk + d)

func load_chunks_around_player():
	load_target = get_target(player)
	load_chunks_around_target()
	get_card(player.chunk, player.indexed_pos).flip()

func _on_spawned_player(_player: Variant) -> void:
	player = _player
	load_chunks_around_player()

class Chunk:
	const SIZE = Vector2i(10, 10)
	static func get_chunk_rect(chunk: Vector2i) -> Rect2i:
		var size = SIZE * GridCard.OFFSET
		var p = chunk * size - GridCard.OFFSET/2
		return Rect2i(p, size)

func get_target(node : Node2D):
	return GridCard.get_position_from_global(node.position)

func _on_load_around_camera_toggled(toggled_on: bool) -> void:
	if toggled_on:
		target = %Camera
		set_process(true)
	else:
		target = player
		load_chunks_around_target(2)
		set_process(false)
