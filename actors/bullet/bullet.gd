extends Area2D

var speed = 75
@export var Shooter : Node2D

func _physics_process(delta):
	position += transform.x * speed * delta

func _on_body_entered(body: Node2D) -> void:
	queue_free()
	if body != Shooter and body.is_in_group("mob"):
		body.queue_free()
