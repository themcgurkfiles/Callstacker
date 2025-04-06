extends Area2D

# Represents what fired the bullet; changes with parry
@export var currOwner : Node2D
var speed = 125

func _physics_process(delta):
	position += transform.x * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body != currOwner and body.is_in_group("mob"):
		queue_free()
		body.queue_free()
