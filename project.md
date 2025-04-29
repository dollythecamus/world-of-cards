# world-of-cards
still placeholder named
it's a roguelike with rpg elements

- The world is made of cards; face-down cards represent unexplored areas.
- The player earns cards that define the actions they can perform.
- The player flips world cards face-up to see what happens—what kind of adventure, what kind of world this is.
- Some cards on the table are a natural biome, some are villages, dungeons etc
- The player explores the world by playing action cards in the game.
- They perform actions, go on adventures, fight monsters.
- Progress is incremental—exploring more and earning more points over time.
- Heavy focus on the logic/programming of each card, relying on procedural generation for the world and the adventures.
- The game ends when the player dies anyhow (battle, hunger, aging)


--- 
## unexplored ideas

_generations_ i thought that was a little brilliant. 
the player having children and in a next game+, 
they could play in the same world but with a different character 

## aging 

have actions take time
with the passage of time, player gets old



func correct_position(chunk, indexed_pos):
	# Check if the indexed_position is outside the current chunk and correct the position
	# even if the indexed_pos is outside two or more chunks, it will correct it
	var p = indexed_pos
	var c = chunk
	
	if p.x < 0:
		c.x -= 1
		p.x = Chunk.SIZE.x + p.x 
	elif p.x >= Chunk.SIZE.x:
		c.x += 1
		p.x = Chunk.SIZE.x - p.x

	if p.y < 0:
		c.y -= 1
		p.y = Chunk.SIZE.y + p.y 
	elif p.y >= Chunk.SIZE.y:
		c.y += 1
		p.y = Chunk.SIZE.y - p.y
	
	return {'chunk': c, 'indexed_pos':p}