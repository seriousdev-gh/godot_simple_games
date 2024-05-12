extends Node2D

const block_size = 16
const play_field_height = 16
const play_field_width = 8

func _on_ready():
	spawn_piece()
	
func spawn_piece():
	var pieces = get_node("pieces")
	
	var count = pieces.get_child_count()
	var index = randi_range(0, count - 1)
	var template = pieces.get_child(index)
	#var template = pieces.get_child(1)

	var piece = template.duplicate()
	piece.position = Vector2(-block_size/2, -play_field_height*block_size/2 - block_size/2)
	add_child(piece)
	piece.get_node("Timer").start()
	piece.stopped = false
	piece.on_piece_placed.connect(spawn_piece)
	piece.on_piece_placed.connect(check_rows)

func check_rows():
	var rows = {}
	var blocks = get_node("placed_blocks").get_children()
	for block in blocks:
		var y = int(block.position.y)
		if not rows.get(y):
			rows[y] = []
		rows[y].push_back(block)
	
	var deleted_rows = []
	for y in rows.keys():
		var row = rows[y]
		if row.size() == play_field_width:
			for block in row:
				block.queue_free()
			rows.erase(y)
			deleted_rows.push_back(y)
	
	for deleted_y in deleted_rows:
		for y in rows.keys():
			if y < deleted_y:
				for block in rows[y]:
					block.position.y += block_size
