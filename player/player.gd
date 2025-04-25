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
	},

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

var player_data = EXAMPLE_DATA

signal spawned_player(data)

var chunk = Vector2i():
	get():
		chunk = %World.get_chunk(position)
		return chunk
var indexed_position = Vector2i()

func _ready() -> void:
	spawn_random_player_data()

func spawn_random_player_data() -> void:
	var random_character = GameData.gd.character_cards.pick_random()
	var base_character = GameData.gd.BaseCharacter
	var actions = base_character.base_actions
	actions.append_array(random_character.base_actions)
	
	player_data.character.character_card = random_character
	player_data.actions = actions
	
	spawned_player.emit(player_data)
