extends CharacterBody2D

@onready var playerColorRect = $ColorRect
@onready var playerCollider = $CollisionShape2D

# States for the player to undergo based on actions
enum GameState { IDLE, MOVING, AIRMOVING }
var current_state := GameState.IDLE

# Actions that the player can perform with p_act action
enum Actions { NONE, FIREPROJ, PARRY, JUMP }
var LevelActions := [Actions.NONE]
var next_action
var used_action

# Basic 2D character movement
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _init() -> void:
	# On level start: populate action list depending on level
	LevelActions.clear() 
	LevelActions.append(Actions.FIREPROJ)
	LevelActions.append(Actions.PARRY)
	LevelActions.append(Actions.JUMP)
	
	# Next action to be used is set here:
	if LevelActions.size() > 0:
		next_action = LevelActions[0]
	
	# Sets starting player color
	if playerColorRect:
		playerColorRect.color = Color.MIDNIGHT_BLUE

func _physics_process(delta: float) -> void:
	# Apply gravity force
	if not is_on_floor(): 
		velocity += get_gravity() * delta
		current_state = GameState.AIRMOVING
	
	# Input: Jump
	if Input.is_action_just_pressed("p_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
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
