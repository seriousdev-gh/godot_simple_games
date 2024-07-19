extends Node2D

@export var enemy_scenes : Array[PackedScene]
var is_game_over = false 

func seconds(secs):
	await get_tree().create_timer(secs).timeout

func _ready():
	seed(123456)
	setup_level1()
	
func setup_level1():
	print("wave 1")
	for i in 10:
		var enemy = enemy_scenes[0].instantiate()
		enemy.position = line_random_point($Spawners/Top)
		add_child(enemy)
		await seconds(0.5)
	await seconds(3)
	if is_game_over:
		return
	
	print("wave 2")
	for i in 10:
		var enemy = enemy_scenes[0].instantiate()
		enemy.position = line_random_point($Spawners/Top)
		add_child(enemy)
		await seconds(0.3)
	await seconds(3)
	if is_game_over:
		return

func line_random_point(line) -> Vector2:
	var p1 = line.get_point_position(0)
	var p2 = line.get_point_position(1)
	return line.position + Vector2(randf_range(p1.x, p2.x),randf_range(p1.y, p2.y))


func _on_player_game_over():
	is_game_over = true
	$Player.set_process(false)
	$Background/AnimationPlayer.stop()

# is there a better way to free subtree of nodes where `node` is located?
func free_node_spawned_in_game(node):
	var immediate_parent = node.get_parent()
	while immediate_parent.get_parent().name != 'Game':
		immediate_parent = immediate_parent.get_parent()
	immediate_parent.queue_free()

# destroy anything that leaves game area
func _on_free_on_exit_zone_area_exited(area):
	free_node_spawned_in_game(area)
