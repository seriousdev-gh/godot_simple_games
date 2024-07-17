extends Node2D

@export var projectile_scene : PackedScene

func _on_timer_timeout():
	var projectile = projectile_scene.instantiate()
	projectile.position = global_position
	get_tree().get_current_scene().add_child(projectile)

