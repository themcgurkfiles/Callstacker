extends Area2D

# Represents what fired the bullet; changes with parry
@export var currOwner : Node2D
var speed = 125
var currArea : Area2D
var justParried : Area2D

func _ready() -> void:
	set_process(false)

func _physics_process(delta):
	position += transform.x * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body != currOwner and body.is_in_group("mob"):
		queue_free()
		body.queue_free()
	#else:
	#	speed = -speed * 1.3

# Process function is only enabled when bullet is within a parry area
func _on_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area.owner and area.is_in_group("parry"):
		currArea = area
		set_process(true)

func _on_area_shape_exited(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area.owner and area.is_in_group("parry"):
		currArea = null
		justParried = null
		set_process(false)

func _process(_delta: float) -> void:
	if currArea.owner.isParrying == true and justParried != currArea and currArea != null and currArea.owner != currOwner:
		speed = -speed * 1.3
		currOwner = currArea.owner
		justParried = currArea
