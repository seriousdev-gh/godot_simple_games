extends Node2D

@export var speed = 450

func _process(delta):
	translate(Vector2.from_angle(rotation) * speed * delta)

func _on_enemy_projectile_area_entered(_area):
	queue_free()
