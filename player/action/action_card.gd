extends Area2D
class_name ActionCard

var data = {}

@onready var label = $Visual/Front/Label

var shortcut_input:
	get():
		if data.has('shortcut'):
			return data.shortcut
		return null

func _ready() -> void:
	set_visuals()

func set_visuals():
	label.text = data.name + "\n" + data.description

func dropped(override_position = position):
	var dropped_on_card = null
	var closest_distance = INF
	
	position = override_position if override_position != position else position
	for area in get_overlapping_areas():
		if not area is WorldCard:
			continue 
		
		var distance = override_position.distance_to(area.global_position)
		if distance < closest_distance:
			closest_distance = distance
			dropped_on_card = area

	if dropped_on_card && dropped_on_card is WorldCard:
		var conditions = [true]
		if data.has('condition'):
			for c in data.condition.split(','):
				conditions.append(call(c, dropped_on_card))
				# closest area is the world card which this dropped card is on top of.
		var any_condition_not_met = false in conditions
		if !any_condition_not_met:
			dropped_on_card.action(self)

func on_player(card):
	var player = get_parent().get_node("%Player")
	return card.chunk == player.chunk && card.indexed_pos == player.indexed_pos

func explored(card):
	return card.is_face_up

func player_adjacent(card):
	var player = get_parent().get_node("%Player")
	var world = get_parent().get_node("%World")
	var player_card = world.get_card(player.chunk, player.indexed_pos)
	return card in world.get_neighbors(player_card, data.range)
