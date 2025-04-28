extends Node2D

# Size of one chunk in pixels

func _draw():
	if not GameData.is_debug_mode:
		return

	for chunk in %World.loaded_chunks.keys():
		var rect = WorldGenerator.Chunk.get_chunk_rect(chunk)
		draw_rect(rect, Color.RED, false, 10.0)  # 2.0 = line width

func _process(_delta: float) -> void:
	queue_redraw()

func _on_debug_toggled(toggled_on: bool) -> void:
	GameData.is_debug_mode = toggled_on
	
	# update card visuals for debug
	for chunk in %World.loaded_chunks.values():
		for card in chunk.values():
			card.update_visual()
