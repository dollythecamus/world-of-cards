extends Node2D

const CARD_SCENE = preload("res://world/world_card.tscn")
const SPACING_X = 76
const SPACING_Y = 144
const CHUNK_WIDTH = 24
const CHUNK_HEIGHT = 10
const CHUNKS_FILE = "user://chunks.save"

var loaded_chunks = {}
var all_chunks = {}  # Dictionary to store all ever-loaded chunks
var world_cards = [] # bi dimensional array

@onready var player = %Player

#func _ready():
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

func unload_chunk(chunk : Vector2i):
	if not loaded_chunks.has(chunk):
		return  # Chunk is not loaded

	bi_dimensional_chunks_array(all_chunks, chunk)
	for c in loaded_chunks[chunk]:
		for card in c:
			all_chunks[chunk][card.indexed_pos.x][card.indexed_pos.y] = {
				"type": card.type,
				"is_face_up": card.is_face_up,
				"indexed_pos": card.indexed_pos
			}
			card.queue_free()
	
	loaded_chunks.erase(chunk)

func load_chunk(chunk : Vector2i):
	if loaded_chunks.has(chunk):
		return  # Chunk is already loaded
	
	bi_dimensional_chunks_array(loaded_chunks, chunk)
	
	if all_chunks.has(chunk):
		for c in all_chunks[chunk]:
			for card_data in c:
				var card = CARD_SCENE.instantiate()
				card.type = card_data["type"]
				card.is_face_up = card_data["is_face_up"]
				card.indexed_pos = card_data["indexed_pos"]
				
				var chunk_offset = Vector2(chunk.x * SPACING_X * CHUNK_WIDTH,
										chunk.y * SPACING_Y * CHUNK_HEIGHT)
				
				card.position = Vector2(card_data.indexed_pos.x * SPACING_X, 
										card_data.indexed_pos.y * SPACING_Y) 
				card.position += chunk_offset
				
				add_child(card)
				loaded_chunks[chunk][card.indexed_pos.x][card.indexed_pos.y] = card
	else:
		# Generate new chunk
		for x in CHUNK_WIDTH:
			for y in CHUNK_HEIGHT:
				var card = CARD_SCENE.instantiate()
				
				var chunk_offset = Vector2(chunk.x * SPACING_X * CHUNK_WIDTH,
										chunk.y * SPACING_Y * CHUNK_HEIGHT)
				
				card.position = Vector2(x * SPACING_X, y * SPACING_Y) + chunk_offset
				card.type = randi() % 3 + 1  # Randomly pick biome
				card.indexed_pos = Vector2i(x, y)
				add_child(card)
				loaded_chunks[chunk][x][y] = card

func bi_dimensional_chunks_array(array, chunk):
	# bi dimensional array for storing the cards in chunks
	array[chunk] = []
	array[chunk].resize(CHUNK_WIDTH)
	for i in CHUNK_WIDTH:
		array[chunk][i] = [] 
		array[chunk][i].resize(CHUNK_HEIGHT)

func _on_card_dropped(dropped_card): # this is not needed anymore
	var chunk = get_chunk(dropped_card.position)
	if not loaded_chunks.has(chunk):
		return
	
	for cc in loaded_chunks[chunk]:
		for card in cc:
			if card.is_pos_over(dropped_card.position):
				card.action(dropped_card, get_neighbours(card))
				return

func _process(_delta):
	var camera_chunk = get_chunk(%Camera.position)
	# Load surrounding chunks
	
	load_chunk(player.chunk)
	
	for dx in range(-1, 1):  # Load chunks in a 3x3 grid around the camera
		for dy in range(-1, 1):
			var d = Vector2i(dx, dy)
			load_chunk(camera_chunk + d)

	# Unload chunks that are too far based on distance
	var max_distance = 2  # Maximum distance in chunks to keep loaded
	var chunks_to_unload = []

	for chunk in loaded_chunks.keys():
		if chunk.distance_to(camera_chunk) > max_distance:
			if chunk == player.chunk:
				continue
			chunks_to_unload.append(chunk)

	for chunk in chunks_to_unload:
		unload_chunk(chunk)

func get_chunk(pos):
	return Vector2i(floor(pos.x / (CHUNK_WIDTH * SPACING_X)),
					floor(pos.y / (CHUNK_HEIGHT * SPACING_Y)))

func get_neighbours(card):
	var neighbors = []

	var card_x = card.indexed_pos.x
	var card_y = card.indexed_pos.y
	var current_chunk = get_chunk(card.position)

	for dx in [1, 0, -1]:
		for dy in [1, 0, -1]:
			if dx == 0 and dy == 0:
				continue  # Skip the card itself

			var neighbor_x = card_x + dx
			var neighbor_y = card_y + dy
			var neighbor_chunk = current_chunk

			# Check if the neighbor is outside the current chunk
			if neighbor_x < 0:
				neighbor_x = CHUNK_WIDTH - 1
				neighbor_chunk.x -= 1
			elif neighbor_x >= CHUNK_WIDTH:
				neighbor_x = 0
				neighbor_chunk.x += 1

			if neighbor_y < 0:
				neighbor_y = CHUNK_HEIGHT - 1
				neighbor_chunk.y -= 1
			elif neighbor_y >= CHUNK_HEIGHT:
				neighbor_y = 0
				neighbor_chunk.y += 1

			# Add the neighbor if it exists in the loaded chunks
			if loaded_chunks.has(neighbor_chunk) and loaded_chunks[neighbor_chunk][neighbor_x][neighbor_y]:
				neighbors.append(loaded_chunks[neighbor_chunk][neighbor_x][neighbor_y])

	return neighbors
