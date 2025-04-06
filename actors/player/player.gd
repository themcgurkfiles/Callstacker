extends CharacterBody2D

@onready var playerColorRect := $ColorRect
@onready var playerCollider := $CollisionShape2D
@onready var parryRange := $Area2D
@onready var parryTimer := $Timer

@export var Bullet : PackedScene

# States for the player to undergo based on actions
enum GameState { IDLE, MOVING, AIRMOVING }
var current_state := GameState.IDLE

# Actions that the player can perform with p_act action
enum Actions { NONE, FIREPROJ, PARRY, JUMP }
var LevelActions := [Actions.NONE]
var last_used_action

var original_color : Color

# Basic 2D character movement
const SPEED = 350.0
const JUMP_VELOCITY = -600.0

var isParrying := false

func _init() -> void:
	# On level start: populate action list depending on level
	LevelActions.clear() 
	
	LevelActions.append(Actions.FIREPROJ)
	LevelActions.append(Actions.PARRY)
	LevelActions.append(Actions.JUMP)
	LevelActions.append(Actions.FIREPROJ)
	LevelActions.append(Actions.PARRY)
	LevelActions.append(Actions.JUMP)
	
	# Sets starting player color
	if playerColorRect:
		original_color = playerColorRect.color

func _ready() -> void:
	# Sets starting player color (primarily for start of game)
	if playerColorRect:
		original_color = playerColorRect.color

func jump_curve_grav(vel: Vector2):
	if vel.y < 0:
		return get_gravity()
	return get_gravity() * 2

func _physics_process(delta: float) -> void:
	# Apply gravity force
	if not is_on_floor(): 
		velocity += jump_curve_grav(velocity) * delta
		current_state = GameState.AIRMOVING
	
	# Ability input processing
	if Input.is_action_just_pressed("p_act"):
		process_action()
	
	# Input: Jump
	if Input.is_action_just_pressed("p_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_released("p_jump") and velocity.y < 0:
		velocity.y = JUMP_VELOCITY / 4
	
	# Set Velocity
	var direction := Input.get_axis("p_left", "p_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Game state physics management
	if velocity != Vector2.ZERO:
		current_state = GameState.MOVING
	else:
		current_state = GameState.IDLE
	
	move_and_slide()
	
	playerColorRect.color = lerp(playerColorRect.color, original_color, 0.1)

func process_action() -> void:
	var actToDo = null
	if LevelActions.size() > 0:
		actToDo = LevelActions[0]
	
	match actToDo:
		Actions.FIREPROJ:
			print("FIREPROJ ACTION")
			playerColorRect.color = Color.CRIMSON
			var b = Bullet.instantiate()
			b.currOwner = self
			owner.add_child(b)
			b.transform = $Muzzle.global_transform
		Actions.PARRY:
			print("PARRY ACTION")
			playerColorRect.color = Color.GOLD
			isParrying = true
			parryTimer.start()
		Actions.JUMP:
			print("JUMP ACTION")
			playerColorRect.color = Color.GREEN
			velocity.y = JUMP_VELOCITY / 2
		_:
			print("NO ACTIONS REMAINING")
			playerColorRect.color = Color.WEB_GRAY
			
	if actToDo != null:
		last_used_action = LevelActions.pop_front()

func _on_timer_timeout() -> void:
	isParrying = false
