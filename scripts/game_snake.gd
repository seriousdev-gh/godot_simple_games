extends Node

@export var snake_food_scene: PackedScene

var current_score = 0
var score_increment = 100
var width = 64
var height = 32
var cell_size = 4

func to_world(x, y) -> Vector2:
	return Vector2(x * cell_size - width/2.0 * cell_size, y * cell_size - height/2.0 * cell_size)

func _ready():
	$GameOverLabel.visible = false
	$Bounds.size = Vector2(width * cell_size, height * cell_size)
	$Bounds.position = to_world(0, 0)


func _on_snake_head_self_collided():
	$GameOverLabel.visible = true
	$SnakeHead.set_process(false)


func _on_snake_head_food_collected():
	current_score += score_increment
	$ScoreLabelValue.text = str(current_score)
	
	var food = snake_food_scene.instantiate()
	food.position = to_world(randi_range(1, width - 2), randi_range(1, height - 2))
	call_deferred("add_child", food)
	
