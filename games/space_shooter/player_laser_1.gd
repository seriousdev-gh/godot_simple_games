extends Sprite2D

@export var speed = 600

func _process(delta):
	position.y -= speed * delta

func _on_area_2d_area_entered(_area):
	queue_free()
