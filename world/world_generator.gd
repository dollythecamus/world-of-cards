extends Node2D

const CARD_SCENE = preload("res://world/world_card.tscn")
const GRID_WIDTH = 5
const GRID_HEIGHT = 5
const SPACING_X = 68
const SPACING_Y = 132

var world_cards = [] # bi dimensional array. maybe this will work (something is truly weird with how it does the indexing here)

func _ready():
	generate_world()

func generate_world():
	for x in range(GRID_WIDTH):
		var arr = []
		arr.resize(GRID_HEIGHT)
		world_cards.append(arr)
	
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			var card = CARD_SCENE.instantiate()
			card.position = Vector2(x * SPACING_X, y * SPACING_Y)
			card.type = randi() % 3 + 1  # Randomly pick biome (skip 0 for unexplored)
			card.indexed_pos = Vector2i(x, y)
			world_cards[x][y] = card
			add_child(card)

func _on_card_dropped(card):
	for cc in world_cards:
		for c in cc:
			if c.is_mouse_over():
				c.action(card, get_neighbours(c))
				return

func get_neighbours(card):
	var neighbors = []

	var card_x = card.indexed_pos.x
	var card_y = card.indexed_pos.y

	for dx in [1, 0, -1]:
		for dy in [1, 0, -1]:
			if dx == 0 and dy == 0:
				continue  # Skip the card itself
			var neighbor_x = card_x + dx
			var neighbor_y = card_y + dy
			if neighbor_x >= 0 and neighbor_x < GRID_WIDTH and neighbor_y >= 0 and neighbor_y < GRID_HEIGHT:
				neighbors.append(world_cards[neighbor_x][neighbor_y])

	return neighbors
