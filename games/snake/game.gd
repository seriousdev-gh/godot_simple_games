extends Node

@export var snake_food_scene: PackedScene

var current_score = 0
var score_increment = 100
var width = 24
var height = 24
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
	
	call_deferred("try_to_instantiate_food")

func try_to_instantiate_food():
	var food = snake_food_scene.instantiate()
	var any_spatial_node = get_node('SnakeHead')
	var space_state = any_spatial_node.get_world_2d().direct_space_state
	var random_position
	var query = PhysicsPointQueryParameters2D.new()
	
	for i in 100:
		random_position = to_world(randi_range(1, width - 2), randi_range(1, height - 2))
		query.collide_with_areas = true
		query.position = random_position
		if !space_state.intersect_point(query):
			break
		else:
			print("Free space not found in: " + str(random_position))
		
	food.position = random_position
	add_child(food)
	
