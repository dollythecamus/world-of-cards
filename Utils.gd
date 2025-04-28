extends Node

func random_point_on_circumference(radius = 1.0):
	return Vector2(randf(),randf()).normalized() * radius
