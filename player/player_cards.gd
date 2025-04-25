extends Node2D

const ACTION_CARD_SCENE = preload("res://player/actionCard.tscn")

# Adjust this to wherever you want the player hand to start
var hand_origin = Vector2(200, 500)
var card_spacing = 120

func spawn_action_hand(player_actions):
	for i in range(player_actions.size()):
		var card = ACTION_CARD_SCENE.instantiate()
		card.position = hand_origin + Vector2(i * card_spacing, 0)
		
		var action_card_data = GameData.get_action_card(player_actions[i])
		card.data = action_card_data  # Custom method on the ActionCard
		card.connect("dropped", %World._on_card_dropped)
		
		add_child(card)


func _on_player_spawned_player(data: Variant) -> void:
	spawn_action_hand(data.actions)
