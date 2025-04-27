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

var player_data = EXAMPLE_DATA

signal spawned_player(data)

var chunk = Vector2i()
var indexed_pos = Vector2i(0, 0):
	set(v):
		if not v:
			return
		
		indexed_pos = v
		var chunk_offset = Vector2(chunk.x * WorldGenerator.SPACING_X * WorldGenerator.CHUNK_WIDTH, 
			chunk.y * WorldGenerator.SPACING_Y * WorldGenerator.CHUNK_HEIGHT)
		var centered = Vector2(indexed_pos.x * WorldGenerator.SPACING_X,
			indexed_pos.y * WorldGenerator.SPACING_Y)
		position = centered + chunk_offset

func get_chunk():
	return %World.get_chunk(position)

func _ready() -> void:
	spawn_random_player_data()

func spawn_random_player_data() -> void:
	var random_character = GameData.gd.character_cards.pick_random()
	var base_character = GameData.gd.BaseCharacter
	var actions = base_character.base_actions
	actions.append_array(random_character.base_actions)
	
	player_data.character.character_card = random_character
	player_data.actions = actions
	
	chunk.x = range(-1, 1).pick_random()
	chunk.y = range(-1, 1).pick_random()
	indexed_pos.x = range(WorldGenerator.CHUNK_WIDTH).pick_random()
	indexed_pos.y = range(WorldGenerator.CHUNK_HEIGHT).pick_random()
	
	spawned_player.emit(player_data)
