extends Node2D

@export var speed = 500.0
@export var projectile: PackedScene

const DIRECTIONS = {
	'up': Vector2.UP, 
	'down': Vector2.DOWN, 
	'left': Vector2.LEFT, 
	'right': Vector2.RIGHT
}

var direction_hit = {}

func _process(delta_time):
	moving(delta_time)
	
func moving(delta_time):
	var move_direction = Vector2.ZERO
	for dir in DIRECTIONS:
		if Input.is_action_pressed(dir) and not direction_hit.get(dir, false):
			move_direction += DIRECTIONS[dir]

	position += move_direction.normalized() * speed * delta_time

func _on_area_2d_area_entered(area):
	for dir in DIRECTIONS:
		if area.name == 'Boundary' + dir.capitalize():
			direction_hit[dir] = true


func _on_area_2d_area_exited(area):
	for dir in DIRECTIONS:
		if area.name == 'Boundary' + dir.capitalize():
			direction_hit[dir] = false
