extends Node2D

enum CardType { UNEXPLORED, FOREST, VILLAGE, DUNGEON }

var type = CardType.UNEXPLORED
var is_face_up = false

var indexed_pos = Vector2i()

func _ready() -> void:
	update_visual()

func flip():
	# Update the sprite/texture here based on `type`
	is_face_up = true
	update_visual()

func update_visual():
	if is_face_up:
		match type:
			CardType.FOREST:
				modulate = Color(1, 0, 0, 1)  # Make it visible
				#$Sprite.texture = preload("res://forest.png")
			CardType.VILLAGE:
				modulate = Color(1, 0, 1, 1)  # Make it visible
				#$Sprite.texture = preload("res://village.png")
			_:
				modulate = Color(1, 1, 1, 1)
	else:
		modulate = Color(1, 1, 1, 0.2)  # Make it lower_oppacity
		#$Sprite.texture = preload("res://card_back.png")

func _on_color_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		pass
		#flip_card()

func is_mouse_over() -> bool:
	var mouse_pos = get_global_mouse_position()
	return $Color.get_global_rect().has_point(mouse_pos)

func action(card, neighbours):
	print("does some function based on the card")
	if card.data.name == "Explore":
		for neighbour in neighbours:
			neighbour.flip()
