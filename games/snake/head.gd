extends Sprite2D

signal food_collected
signal self_collided

@export var snake_segment_scene: PackedScene
@export var tail: AnimatedSprite2D
@export var head_close_region: Rect2
@export var head_open_region: Rect2

var current_direction = Vector2.UP
var grow = false

var input_buffer: Array[Vector2] = []

const INPUT_BUFFER_SIZE = 2
const EPSILON: float = 0.0001
const DIRECTION_UP: Vector2 = Vector2.UP
const DIRECTION_DOWN: Vector2 = Vector2.DOWN
const DIRECTION_LEFT: Vector2 = Vector2.LEFT
const DIRECTION_RIGHT: Vector2 = Vector2.RIGHT
const STEP_SIZE: int = 4

func is_direction_allowed(old_dir: Vector2, new_dir: Vector2) -> bool:
	var angle = abs(old_dir.angle_to(new_dir))
	return abs(PI - angle) > EPSILON

func process_input(dir: Vector2) -> void:
	if input_buffer.is_empty():
		if is_direction_allowed(current_direction, dir):
			input_buffer.push_back(dir)
	elif input_buffer.size() < INPUT_BUFFER_SIZE:
		if is_direction_allowed(input_buffer.back(), dir):
			input_buffer.push_back(dir)
	else:
		if is_direction_allowed(input_buffer.back(), current_direction):
			input_buffer.pop_front()
		else:
			input_buffer.clear()
		if is_direction_allowed(input_buffer.back(), dir):
			input_buffer.push_back(dir)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("up"):
		process_input(DIRECTION_UP)
	elif Input.is_action_just_pressed("left"):
		process_input(DIRECTION_LEFT)
	elif Input.is_action_just_pressed("right"):
		process_input(DIRECTION_RIGHT)
	elif Input.is_action_just_pressed("down"):
		process_input(DIRECTION_DOWN)

func _on_timer_timeout() -> void:
	var segment = snake_segment_scene.instantiate()
	segment.position = position
	segment.next = tail

	var new_direction = current_direction
	if not input_buffer.is_empty():
		new_direction = input_buffer.pop_front()

	update_segment_type(segment, new_direction)
	
	rotation_degrees = direction_to_degress(new_direction)

	tail = segment
	add_sibling(segment)

	if grow:
		grow = false
	else:
		tail.update_segment(self)

	position += new_direction * STEP_SIZE
	teleport_through_wall()
	
	current_direction = new_direction

func update_segment_type(segment: AnimatedSprite2D, new_direction: Vector2) -> void:
	var type = "straight"
	if current_direction == DIRECTION_DOWN and new_direction == DIRECTION_RIGHT or \
	   current_direction == DIRECTION_LEFT and new_direction == DIRECTION_UP:
		segment.rotation_degrees = 0
		type = "corner"
	elif current_direction == DIRECTION_UP and new_direction == DIRECTION_RIGHT or \
		 current_direction == DIRECTION_LEFT and new_direction == DIRECTION_DOWN:
		segment.rotation_degrees = 90
		type = "corner"
	elif current_direction == DIRECTION_RIGHT and new_direction == DIRECTION_DOWN or \
		 current_direction == DIRECTION_UP and new_direction == DIRECTION_LEFT:
		segment.rotation_degrees = 180
		type = "corner"
	elif current_direction == DIRECTION_RIGHT and new_direction == DIRECTION_UP or \
		 current_direction == DIRECTION_DOWN and new_direction == DIRECTION_LEFT:
		segment.rotation_degrees = 270
		type = "corner"
	elif current_direction == new_direction:
		segment.rotation_degrees = direction_to_degress(current_direction)
		type = "straight"
		
	if grow:
		segment.play(type + "_fat")
	else:
		segment.play(type)
			
func direction_to_degress(dir) -> float:
	var value = 0
	match dir:
		DIRECTION_LEFT:
			value = 270
		DIRECTION_UP:
			value = 0
		DIRECTION_RIGHT:
			value = 90
		DIRECTION_DOWN:
			value = 180
	return value
	
func teleport_through_wall():
	var bounds_size = Vector2(get_parent().width * STEP_SIZE * 0.5, get_parent().height * STEP_SIZE * 0.5)
	if position.x >= bounds_size.x or position.x <= -bounds_size.x:
		position.x = clampf(-position.x, -bounds_size.x + STEP_SIZE, bounds_size.x - STEP_SIZE)
	if position.y >= bounds_size.y or position.y <= -bounds_size.y:
		position.y = clampf(-position.y, -bounds_size.y + STEP_SIZE, bounds_size.y - STEP_SIZE)

func _on_area_2d_area_entered(area) -> void:
	match area.name:
		'snake_food':
			food_collected.emit()
			area.get_parent().queue_free()
			grow = true
		'snake_segment_area':
			$Timer.stop()
			self_collided.emit()


func _on_area_2d_2_area_entered(area):
	if area.name == 'snake_food':
		region_rect = head_open_region


func _on_area_2d_2_area_exited(area):
	if area.name == 'snake_food':
		region_rect = head_close_region
