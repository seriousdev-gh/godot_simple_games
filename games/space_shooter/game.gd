extends Node2D

@export var enemy_scenes : Array[PackedScene]
var levels : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	seed(123456)
	
	#setup()
	setup_level1()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setup():
	var tween = get_tree().create_tween()
	# level 1
	tween.tween_callback(
		func():
			print("TWEEN: spawn")
			var enemy = enemy_scenes[0].instantiate()
			enemy.position = line_random_point($Spawners/Top)
			add_child(enemy)
	).set_delay(0.8)
	tween.set_loops(5)
	tween.tween_interval(1)
	tween.stop()
	await tween.finished
	tween.tween_callback(
		func():
			print("WEEN: after spawn")
	)
	
func setup_level1():
	print("wave 1")
	for i in 10:
		var enemy = enemy_scenes[0].instantiate()
		enemy.position = line_random_point($Spawners/Top)
		add_child(enemy)
		await get_tree().create_timer(0.5).timeout
	await get_tree().create_timer(3).timeout
	
	print("wave 2")
	for i in 5:
		var enemy = enemy_scenes[0].instantiate()
		enemy.position = line_random_point($Spawners/Top)
		add_child(enemy)
		await get_tree().create_timer(0.3).timeout
	await get_tree().create_timer(3).timeout

func line_random_point(line) -> Vector2:
	var p1 = line.get_point_position(0)
	var p2 = line.get_point_position(1)
	return line.position + Vector2(randf_range(p1.x, p2.x),randf_range(p1.y, p2.y))
