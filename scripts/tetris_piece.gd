extends Node2D

signal on_piece_placed

@export var placed_block_scene: PackedScene
@export var stopped = true
@export var rotations: Array[float] = [0, -PI/2]

const block_size = 16
const play_field_height = 16
var can_move_left = true
var can_move_right = true
var can_rotate_left = true
var can_rotate_right = true
var can_rotate = true
var intersect_areas_down_rotate = 0
var intersect_areas_down = 0
var move_right_after_rotate
var current_rotation_index = 0

func _process(_delta):
	if stopped:
		return
	
	var direction = 0
	
	if Input.is_action_just_pressed("rotate"):
		if intersect_areas_down_rotate == 0:
			if can_rotate_left and can_rotate_right:
				current_rotation_index = (current_rotation_index + 1) % rotations.size()
			elif not can_rotate_left && can_move_right:
				current_rotation_index = (current_rotation_index + 1) % rotations.size()
				position.x += block_size
			elif not can_rotate_right && can_move_left:
				current_rotation_index = (current_rotation_index + 1) % rotations.size()
				position.x -= block_size
			else:
				print("Cant rotate for some reason")
		else:
			print("Cant rotate because lower cell is occupied")
		
		rotation = rotations[current_rotation_index]
	
	if Input.is_action_just_pressed("down"):
		$Timer.wait_time = 0.1
		$Timer.start(0.05)
	
	if Input.is_action_just_pressed("left") and can_move_left:
		direction = -1
		$LongPressCooldown.start()
	elif Input.is_action_just_pressed("right") and can_move_right:
		direction = 1
		$LongPressCooldown.start()
	elif $LongPressCooldown.is_stopped():
		if Input.is_action_pressed("left") and can_move_left:
			direction = -1
			$LongPressCooldown.start()
		elif Input.is_action_pressed("right") and can_move_right:
			direction = 1
			$LongPressCooldown.start()
		else:
			return 
	else:
		return
	
	
	position.x += direction * block_size

func _on_timer_timeout():
	if stopped:
		return
	
	if intersect_areas_down == 0:
		position.y += block_size
	else:
		for child in get_children():
			if child.name.begins_with("Block"):
				var block = placed_block_scene.instantiate()
				block.position = child.global_position
				get_parent().get_node("placed_blocks").add_child(block)
		queue_free()
		on_piece_placed.emit()

func _on_area_2d_area_entered(area):
	if area.name == 'block_left':
		can_move_left = false
	if area.name == 'block_right':
		can_move_right = false
	if area.name == 'block_down':
		intersect_areas_down += 1

func _on_area_2d_area_exited(area):
	if area.name == 'block_left':
		can_move_left = true
	if area.name == 'block_right':
		can_move_right = true
	if area.name == 'block_down':
		intersect_areas_down -= 1

func _on_rotation_probe_area_entered(area):
	if area.name == 'block_left':
		can_rotate_left = false
	if area.name == 'block_right':
		can_rotate_right = false
	if area.name == 'block_down':
		intersect_areas_down_rotate += 1

func _on_rotation_probe_area_exited(area):
	if area.name == 'block_left':
		can_rotate_left = true
	if area.name == 'block_right':
		can_rotate_right = true
	if area.name == 'block_down':
		intersect_areas_down_rotate -= 1
