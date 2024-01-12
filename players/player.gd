extends CharacterBody2D

# DEFAULT SPEED
const DEFAULT_MOVE_VELOCITY: float = 150.0
const DEFAULT_JUMP_VELOCITY: float = -300.0

# Default Horizontal Move Multiplier
const MOVE_CROUCH_MULTIPLIER: float = 0.3
const MOVE_WALK_MULTIPLIER: float = 0.7
const MOVE_DASH_MULTIPLIER: float = 1.5

# Default Vertical Move Multiplier
const JUMP_CROUCH_MULTIPLIER: float = 1.5

# DEFAULT MAX CASTING TIME
const JUMP_CROUCH_CHARGING_TIME: float = 1

# Player Move Multiplier
var horizontalMultiplier: float = 1.0
var verticalMultiplier: float = 1.0

# player charging time
var jumpChargingTime: float = 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# state variables
var canHighJump: bool = false
var jumpCount: int = 0
@export var maxJumpCount: int = 2



# child nodes
@onready var sprite: AnimationPlayer = get_node("Sprite")
@onready var rawSprite: AnimatedSprite2D  = get_node("RawSprite")

func _physics_process(delta):
	# Player Facing
	var direction: int = Input.get_axis("ui_left", "ui_right")
	if direction > 0:
		rawSprite.flip_h = false
	elif direction < 0:
		rawSprite.flip_h = true
	
	# Player Default Animation
	if is_on_floor():
		velocity.y = 0
		jumpCount = 0
		if velocity.x != 0:
			sprite.play("run")
		else:
			sprite.play("idle")
	else:
		velocity.y += gravity * delta;
		if velocity.y > 0:
			sprite.play("fall")
		elif velocity.y < 0:
			sprite.play("jump")
			
	# Run Multiplier
	if Input.is_action_pressed("control_crouch"):
		horizontalMultiplier = MOVE_CROUCH_MULTIPLIER
	elif Input.is_action_pressed("control_walk"):
		horizontalMultiplier = MOVE_WALK_MULTIPLIER
	elif Input.is_action_pressed("control_dash"):
		horizontalMultiplier = MOVE_DASH_MULTIPLIER
	else:
		horizontalMultiplier = 1.0
		
	if Input.is_action_pressed("ui_down") and is_on_floor():
		sprite.play("crouch")
		if !canHighJump:
			jumpChargingTime += delta
			if jumpChargingTime >= JUMP_CROUCH_CHARGING_TIME:
				jumpChargingTime = JUMP_CROUCH_CHARGING_TIME
				canHighJump = true
				verticalMultiplier *= JUMP_CROUCH_MULTIPLIER
				rawSprite.modulate.r8 = 0
				
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or jumpCount < maxJumpCount):
		jumpCount += 1
		velocity.y = DEFAULT_JUMP_VELOCITY * verticalMultiplier
		sprite.play("jump")
		if canHighJump:
			verticalMultiplier /= JUMP_CROUCH_MULTIPLIER
			canHighJump = false
		jumpChargingTime = 0.0
		rawSprite.modulate.r8 = 255

	if !Input.is_action_pressed("ui_down"):
		jumpChargingTime = 0.0
		if canHighJump:
			canHighJump = false
			verticalMultiplier /= JUMP_CROUCH_MULTIPLIER
		rawSprite.modulate.r8 = 255
		
	if Input.is_action_just_released("ui_down"):
		horizontalMultiplier /= MOVE_CROUCH_MULTIPLIER
		
	velocity.x = direction * DEFAULT_MOVE_VELOCITY * horizontalMultiplier

	move_and_slide()
