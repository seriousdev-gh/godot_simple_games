extends Sprite2D

var destroyed = true
var rotation_speed = 0
var move_direction = Vector2.ZERO

@export var move_speed = 25
@export var max_rotation_speed = 1
@export var fade_duration = 1

func _process(delta):
	if destroyed:
		rotation += rotation_speed * delta
		position += move_direction * move_speed * delta

func _on_node_2d_before_kill():
	destroyed = true
	rotation_speed = randf_range(-max_rotation_speed, max_rotation_speed)
	move_direction = position.rotated(randf_range(-0.1, 0.1)).normalized()
	
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "modulate", Color.TRANSPARENT, fade_duration)
	tween.parallel().tween_property(self, "scale", Vector2(0.5, 0.5), fade_duration)
	tween.tween_callback(self.queue_free)
