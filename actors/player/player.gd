extends CharacterBody2D

@onready var playerColorRect = $ColorRect
@onready var playerCollider = $CollisionShape2D

# States for the player to undergo based on actions
enum GameState { IDLE, MOVING, AIRMOVING }
var current_state := GameState.IDLE

# Actions that the player can perform with p_act action
enum Actions { NONE, FIREPROJ, PARRY, JUMP }
var LevelActions := [Actions.NONE]
var last_used_action

var original_color := Color.MIDNIGHT_BLUE

# Basic 2D character movement
const SPEED = 350.0
const JUMP_VELOCITY = -600.0

func _init() -> void:
	# On level start: populate action list depending on level
	LevelActions.clear() 
	LevelActions.append(Actions.FIREPROJ)
	LevelActions.append(Actions.PARRY)
	LevelActions.append(Actions.JUMP)
	
	# Sets starting player color
	if playerColorRect:
		playerColorRect.color = original_color

func _ready() -> void:
	# Sets starting player color (primarily for start of game)
	if playerColorRect:
		playerColorRect.color = original_color

func jump_curve_grav(velocity: Vector2):
	if velocity.y < 0:
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
	
	# print(current_state)

func process_action() -> void:
	var actToDo = null
	if LevelActions.size() > 0:
		actToDo = LevelActions[0]
	
	match actToDo:
		Actions.FIREPROJ:
			print("FIREPROJ ACTION")
			playerColorRect.color = Color.CRIMSON
		Actions.PARRY:
			print("PARRY ACTION")
			playerColorRect.color = Color.GOLD
		Actions.JUMP:
			print("JUMP ACTION")
		_:
			print("NO ACTIONS REMAINING")
			
	if actToDo != null:
		last_used_action = LevelActions.pop_front()
