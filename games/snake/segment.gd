extends AnimatedSprite2D

@export var next: AnimatedSprite2D

func update_segment(previous):
	var will_become_tail = next.next == null
	if will_become_tail:
		play("tail")
		rotation = (position - previous.position).angle() - PI/2.0
		next.queue_free()
		next = null
	else:
		next.update_segment(self)
