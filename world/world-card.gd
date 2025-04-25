extends Node2D

enum CardType { UNEXPLORED, FOREST, VILLAGE, DUNGEON }

var type = CardType.UNEXPLORED
var is_face_up = false

func _ready() -> void:
	update_visual()

func flip_card():
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
			# etc.
	else:
		self_modulate = Color(1, 1, 1, 0.2)  # Make it invisible
		#$Sprite.texture = preload("res://card_back.png")

func _on_color_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		flip_card()
