extends CharacterBody2D

signal game_over

@export var speed = 500.0
@export var projectile: PackedScene
@export var health = 3

func get_input():
	velocity = Vector2.ZERO
	if Input.is_action_pressed('right'):
		velocity.x = 1
	if Input.is_action_pressed('left'):
		velocity.x = -1
	if Input.is_action_pressed('up'):
		velocity.y = -1
	if Input.is_action_pressed('down'):
		velocity.y = 1
	
	velocity = velocity.normalized() * speed


func _physics_process(_delta):
	get_input()
	move_and_slide()
	
func damage():
	health -= 1
	print("Took damage. Current health: " + str(health))
	if health == 0:
		game_over.emit()
		queue_free()

func _on_player_area_area_entered(area):
	if area.name == 'EnemyProjectile' || area.name == 'Enemy':
		damage()
