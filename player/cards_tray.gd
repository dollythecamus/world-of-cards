extends Node
const ACTION_CARD_SCENE = preload("res://player/action/actionCard.tscn")

# Adjust this to wherever you want the player hand to start
var hand_origin = Vector2(0, 0)

var current_cards = {}

func spawn_action_hand(player_actions):
	for i in range(player_actions.size()):
		var card = ACTION_CARD_SCENE.instantiate()
		var action_card_data = GameData.get_action_card(player_actions[i])
		card.data = action_card_data  # Custom method on the ActionCard
		current_cards[card.data.name] = card
		add_child(card)

func _process(_delta: float) -> void:
	var pos = %Camera.position + Vector2(0, 400)
	DragCard.set_group_position(0, pos)
	$Sprite.position = pos 

func _on_spawned_player(player: Variant) -> void:
	spawn_action_hand(player.data.actions)

func _input(event: InputEvent) -> void:
	
	if event is InputEventKey:
		for card in current_cards.values():
			if card.shortcut_input != null:
				if event.is_action_released(card.shortcut_input):
					card.dropped()
