extends Node2D

@export var block_texture: Texture2D
@export var block_source_rect: Rect2
const block_size = 16
const rows_count = 16
const cols_count = 8
const stick_piece = 4

var rows = []
var current_piece
var current_piece_location
var current_piece_rotation

const pieces = [
	[
		Vector2i(0, 0)
	],
	[
		Vector2i(0, 0),
		Vector2i(0, 1)
	],
	[
		Vector2i(0, -1),
		Vector2i(0, 0),
		Vector2i(0, 1)
	],
	[
		Vector2i(0, -1),
		Vector2i(0, 0),
		Vector2i(1, 0)
	],
	[ # I "stick"
		Vector2i(0, -1),
		Vector2i(0, 0),
		Vector2i(0, 1),
		Vector2i(0, 2)
	],
	[ # square
		Vector2i(0, 0),
		Vector2i(0, 1),
		Vector2i(1, 1),
		Vector2i(1, 0)
	],
	[ # S right
		Vector2i(-1, -1),
		Vector2i(0, -1),
		Vector2i(0, 0),
		Vector2i(1, 0)
	],
	[ # S left
		Vector2i(-1, 0),
		Vector2i(0, 0),
		Vector2i(0, 1),
		Vector2i(1, 1)
	],
	[ # T
		Vector2i(-1, 0),
		Vector2i(0, 0),
		Vector2i(0, -1),
		Vector2i(1, 0)
	],
	[ # L
		Vector2i(0, 1),
		Vector2i(0, 0),
		Vector2i(0, -1),
		Vector2i(1, -1)
	]
]

func _ready():
	rows.resize(rows_count)
	for y in range(rows_count):
		var cols = []
		cols.resize(cols_count)
		cols.fill(false)
		rows[y]=cols
	
	reset_piece()

func reset_piece():
	current_piece = randi_range(0, pieces.size() - 1)
	current_piece_location = Vector2i(cols_count/2, 0)
	current_piece_rotation = 0
	$FallTimer.start(0.5)
	
func _process(_delta):
	if Input.is_action_just_pressed("down"):
		$FallTimer.wait_time = 0.1
		$FallTimer.start(0.05)
		
	var can_move_left = true
	var can_move_right = true
	for loc in piece_grid_positions():
		if is_collides(loc.x + 1, loc.y):
			can_move_right = false
		if is_collides(loc.x - 1, loc.y):
			can_move_left = false

	if Input.is_action_just_pressed("rotate"):
		if current_piece == stick_piece:
			try_to_rotate(0) or try_to_rotate(-1) or try_to_rotate(-2) or\
					try_to_rotate(1) or try_to_rotate(2)
		else:
			try_to_rotate(0) or try_to_rotate(-1) or try_to_rotate(1)
		queue_redraw()

	var direction = 0 
	if Input.is_action_just_pressed("left") and can_move_left:
		direction = -1
		$CooldownTimer.start()
	elif Input.is_action_just_pressed("right") and can_move_right:
		direction = 1
		$CooldownTimer.start()
	elif $CooldownTimer.is_stopped():
		if Input.is_action_pressed("left") and can_move_left:
			direction = -1
			$CooldownTimer.start()
		elif Input.is_action_pressed("right") and can_move_right:
			direction = 1
			$CooldownTimer.start()
	
	if direction != 0:
		current_piece_location.x += direction
		queue_redraw()
		
func is_collides(x, y):
	if y < 0:
		return
	return y >= rows_count or x < 0 or x >= cols_count or rows[y][x]

func try_to_rotate(offset):
	for loc in piece_grid_positions(1):
		if is_collides(loc.x + offset, loc.y):
			return false
			
	current_piece_rotation += 1
	if offset != 0:
		current_piece_location.x += offset
	return true

func rotate_vector2i(vec, amount):
	match amount % 4:
		0: 
			return Vector2i(vec.x, vec.y)
		1: 
			return Vector2i(-vec.y, vec.x)
		2: 
			return Vector2i(-vec.x, -vec.y)
		3: 
			return Vector2i(vec.y, -vec.x)
		
		
func piece_grid_positions(add_rotation = 0):
	return pieces[current_piece].map(func(block): return block_grid_position(block, add_rotation))

func block_grid_position(block, add_rotation):
	var rotated_block = rotate_vector2i(block, current_piece_rotation + add_rotation)
	return current_piece_location + rotated_block

func _on_fall_timer_timeout():
	var can_move_down = true
	for loc in piece_grid_positions():
		if loc.y + 1 >= rows_count or rows[loc.y + 1][loc.x]:
			can_move_down = false
	
	if can_move_down:
		current_piece_location.y += 1
	else:
		for loc in piece_grid_positions():
			rows[loc.y][loc.x] = true
		check_full_row()
		reset_piece()
		
	queue_redraw()

func check_full_row():
	for y in rows_count:
		if rows[y].count(true) == cols_count:
			for yy in range(y, 0, -1):
				if yy == 0:
					rows[0].fill(false)
				else:
					rows[yy] = rows[yy - 1].duplicate()
		
func _draw():
	for y in rows_count:
		for x in cols_count:
			if not rows[y][x]:
				continue
			
			var rect = Rect2(block_position(x, y), Vector2(block_size, block_size))
			draw_texture_rect_region(block_texture, rect, block_source_rect)
	
	for loc in piece_grid_positions():
		var rect = Rect2(block_position(loc.x, loc.y), Vector2(block_size, block_size))
		draw_texture_rect_region(block_texture, rect, block_source_rect)

func block_position(x, y):
	return Vector2(
		(x - cols_count/2) * block_size, 
		(y - rows_count/2) * block_size)
