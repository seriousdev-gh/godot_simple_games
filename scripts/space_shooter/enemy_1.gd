extends Node2D

@export var particles_scene : PackedScene

signal before_kill

func kill():
	before_kill.emit()
	for part in get_node("Parts").get_children():
		part.reparent(get_tree().get_current_scene(), true)
	
	var particles = particles_scene.instantiate()
	particles.position = position
	get_tree().get_current_scene().add_child(particles)
	
	queue_free()


func _on_enemy_area_entered(area):
	print("Entered: " + area.name)
	if area.name == 'PlayerProjectile':
		kill()
