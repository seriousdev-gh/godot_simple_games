extends Sprite2D

@export var snake_segment_scene: PackedScene
@export var tail: AnimatedSprite2D
var current_direction = Vector2.UP
var step = 4
var grow = false

var input_buffer: Array[Vector2] = []
var input_buffer_size = 2

const EPSILON: float = 0.0001

func is_direction_allowed(old_dir, new_dir):
	var angle = abs(old_dir.angle_to(new_dir))
	return abs(PI - angle) > EPSILON

func process_input(dir):
	if input_buffer.is_empty():
		if is_direction_allowed(current_direction, dir):
			input_buffer.push_back(dir)
	elif input_buffer.size() < input_buffer_size:
		if is_direction_allowed(input_buffer.back(), dir):
			input_buffer.push_back(dir)
	elif input_buffer.size() == input_buffer_size:
		if is_direction_allowed(input_buffer.back(), current_direction):
			input_buffer.pop_front()
		else:
			input_buffer.clear()
		if is_direction_allowed(input_buffer.back(), dir):
			input_buffer.push_back(dir)

func _process(_delta):
	if Input.is_action_just_pressed("up"):
		process_input(Vector2.UP)
	if Input.is_action_just_pressed("left"):
		process_input(Vector2.LEFT)
	if Input.is_action_just_pressed("right"):
		process_input(Vector2.RIGHT)
	if Input.is_action_just_pressed("down"):
		process_input(Vector2.DOWN)

func _on_timer_timeout():
	var segment = snake_segment_scene.instantiate()
	segment.position = position
	segment.next = tail
	
	var new_direction = current_direction if input_buffer.is_empty() else input_buffer.pop_front()
	
#region Select segment type based on direction
	if current_direction == Vector2.DOWN and new_direction == Vector2.RIGHT or \
	   current_direction == Vector2.LEFT and new_direction == Vector2.UP:
		segment.rotation_degrees = 0
		segment.play("corner")
	elif current_direction == Vector2.UP and new_direction == Vector2.RIGHT or \
	   current_direction == Vector2.LEFT and new_direction == Vector2.DOWN:
		segment.rotation_degrees = 90
		segment.play("corner")
	elif current_direction == Vector2.RIGHT and new_direction == Vector2.DOWN or \
	   current_direction == Vector2.UP and new_direction == Vector2.LEFT:
		segment.rotation_degrees = 180
		segment.play("corner")
	elif current_direction == Vector2.RIGHT and new_direction == Vector2.UP or \
	   current_direction == Vector2.DOWN and new_direction == Vector2.LEFT:
		segment.rotation_degrees = 270
		segment.play("corner")
	elif current_direction == Vector2.LEFT and new_direction == Vector2.LEFT:
		segment.rotation_degrees = 270
		segment.play("straight")
	elif current_direction == Vector2.RIGHT and new_direction == Vector2.RIGHT:
		segment.rotation_degrees = 90
		segment.play("straight")
	elif current_direction == Vector2.UP and new_direction == Vector2.UP:
		segment.rotation_degrees = 0
		segment.play("straight")
	elif current_direction == Vector2.DOWN and new_direction == Vector2.DOWN:
		segment.rotation_degrees = 180
		segment.play("straight")
#endregion
	
#region Rotate Head
	if new_direction == Vector2.LEFT:
		rotation_degrees = 270
	elif new_direction == Vector2.UP:
		rotation_degrees = 0
	elif new_direction == Vector2.RIGHT:
		rotation_degrees = 90
	elif new_direction == Vector2.DOWN:
		rotation_degrees = 180
#endregion
	
	tail = segment
	add_sibling(segment)
	
	if grow:
		grow = false
	else:
		tail.update_segment(self)
		
	position += new_direction * step
	current_direction = new_direction
	


func _on_area_2d_area_entered(area):
	if area.name == 'snake_food':
		area.get_parent().queue_free()
		grow = true
