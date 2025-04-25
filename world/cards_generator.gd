extends Node2D

const CARD_SCENE = preload("res://card.tscn")
const GRID_WIDTH = 5
const GRID_HEIGHT = 5
const SPACING_X = 88
const SPACING_Y = 160

func _ready():
	generate_world()

func generate_world():
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			var card = CARD_SCENE.instantiate()
			card.position = Vector2(x * SPACING_X, y * SPACING_Y)
			card.type = randi() % 3 + 1  # Randomly pick biome (skip 0 for unexplored)
			add_child(card)
