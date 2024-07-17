extends Node2D

@export var particles_scene : PackedScene
@export var projectile_scene : PackedScene
@export var speed = 250

signal before_kill

func _ready():
	logic()

func _process(delta):
	position.y += speed * delta

func logic():
	await get_tree().create_timer(1).timeout
	var projectile = projectile_scene.instantiate()
	var player = get_tree().get_current_scene().get_node("Player")
	projectile.position = position
	projectile.look_at(player.position)
	get_tree().get_current_scene().add_child(projectile)
	

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
