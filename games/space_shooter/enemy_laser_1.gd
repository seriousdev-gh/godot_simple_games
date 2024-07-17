extends Node2D

@export var speed = 450

func _process(delta):
	translate(Vector2.from_angle(rotation) * speed * delta)

func _on_area_2d_area_entered(area):
	if area.name != "EnemyArea":
		queue_free()
