extends Node2D

var EXAMPLE_DATA = {
	"character":
	{
		"name": "John Doe",
		"character_card": {
			"name": "Scholar",
			"description": "Study the world",
		},
		"level": 1,
	},

	"actions":
	[
		{
			"name": "Walk To",
			"description": "Walk to an adjacent card.",
			"cost_currency": "time",
			"cost": 5,
		},
		{
			"name": "Explore",
			"description": "Exploring the world. Uncover Adjacent Cards",
			"cost_currency": "time",
			"cost": 10,
		}
	],

	"stats": {
		"health": 20,
		"inspiration": 5,
		"energy": 5,
		"magic": 5,
		"time": 216 # time in months. # TODO: when you get old, you get less energy, slower and eventually die
	},				# that's certainly one of many ideas

	"inventory": {
		"gold": 100,
		"items": [ # items are cards btw
			{"name": "Health Potion", "quantity": 5},
			{"name": "Mana Potion",   "quantity": 3},
			{"name": "Sword",        "quantity": 1},
			{"name": "Spellbook",    "quantity": 1},
		],
	},
}

var data = EXAMPLE_DATA

signal spawned_player(player)

var card := GridCard.new()

var ontopof_card
# ontopof_card = %World.get_card(chunk, indexed_pos)

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
	spawn_random_player_data()

func spawn_random_player_data() -> void:
	var random_character = GameData.player.character_cards.pick_random()
	var base_character = GameData.player.BaseCharacter
	var actions = base_character.base_actions
	actions.append_array(random_character.base_actions)
	
	data.character.character_card = random_character
	data.actions = actions
	
	var rand_chunk = Vector2i(range(-1, 1).pick_random(), range(-1, 1).pick_random())
	var rand_pos = Vector2i(range(GridCard.CHUNK_SIZE.x).pick_random(), range(GridCard.CHUNK_SIZE.y).pick_random())
	
	chunk = rand_chunk
	indexed_pos = rand_pos
	
	spawned_player.emit(self)

func walk_to(target_chunk, target_indexed_pos):
	chunk = target_chunk
	indexed_pos = target_indexed_pos
