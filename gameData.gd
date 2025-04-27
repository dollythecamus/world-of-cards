extends Node

var gd = {}

func get_action_card(card_name):
	for card in gd.action_cards:
		if card_name == card.name:
			return card
	return null

func get_game_data_from_json():
	var file = FileAccess.open("res://player/data.json", FileAccess.READ)
	var file_text = file.get_as_text()
	file.close()
	gd = JSON.parse_string(file_text)

func _init():
	randomize()
	get_game_data_from_json()
