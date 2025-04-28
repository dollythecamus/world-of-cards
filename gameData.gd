extends Node

var player = {}
var world = {}

signal loaded_world(world)
signal loaded_player(data)

var is_debug_mode = false

func get_action_card(card_name):
	for card in player.action_cards:
		if card_name == card.name:
			return card
	return null

func get_game_data_from_json():
	var file = FileAccess.open("res://data/player.json", FileAccess.READ)
	var file_text = file.get_as_text()
	file.close()
	player = JSON.parse_string(file_text)
	loaded_player.emit(player)

func get_world_data_from_json():
	var file = FileAccess.open("res://data/world.json", FileAccess.READ)
	var file_text = file.get_as_text()
	file.close()
	world = JSON.parse_string(file_text)
	loaded_world.emit(world)

func _init():
	randomize()
	get_game_data_from_json()
	get_world_data_from_json()
