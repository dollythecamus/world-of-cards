extends Node

var EXAMPLE_DATA = {
	"character":
	{
		"name": "John Doe",
		"card": {
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

func _ready() -> void:
	pass
