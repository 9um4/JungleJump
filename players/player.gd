extends CharacterBody2D

# DEFAULT SPEED
const DEFAULT_RUN_SPEED: float = 100.0
const DEFAULT_JUMP_VELOCITY: float = -300.0

# DEFAULT MULTIPLIER
const CROUCH_RUN_MULTIPLIER: float = 0.3
const WALK_MULTIPLIER: float = 0.7
const CROUCH_JUMP_MULTIPLIER: float = 1.5

# DEFAULT MAX CASTING TIME
const MAX_CROUCH_CHARGING_TIME: float = 1


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# state variables
var canHighJump: bool = false
var currentHorizontalMultiplier: float = 1.0
var currentVerticalMultiplier: float = 1.0
var currentCrouchChargingTime: float = 0.0

# child nodes
@onready var sprite: AnimationPlayer = get_node("Sprite")
@onready var rawSprite: AnimatedSprite2D  = get_node("RawSprite")

func _physics_process(delta):
	var direction: int = Input.get_axis("ui_left", "ui_right")
	if direction > 0:
		rawSprite.flip_h = false
	elif direction < 0:
		rawSprite.flip_h = true
	
	if is_on_floor():
		velocity.y = 0
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
	if Input.is_action_pressed("ui_down"):
		currentHorizontalMultiplier = CROUCH_RUN_MULTIPLIER
	elif Input.is_action_pressed("control_dash"):
		currentHorizontalMultiplier = WALK_MULTIPLIER
	else:
		currentHorizontalMultiplier = 1.0
		
	if Input.is_action_pressed("ui_down") and is_on_floor():
		sprite.play("crouch")
		if !canHighJump:
			currentCrouchChargingTime += delta
			if currentCrouchChargingTime >= MAX_CROUCH_CHARGING_TIME:
				currentCrouchChargingTime = MAX_CROUCH_CHARGING_TIME
				canHighJump = true
				currentVerticalMultiplier *= CROUCH_JUMP_MULTIPLIER
				rawSprite.modulate.r8 = 0
				
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y += DEFAULT_JUMP_VELOCITY * currentVerticalMultiplier
		sprite.play("jump")
		if canHighJump:
			currentVerticalMultiplier /= CROUCH_JUMP_MULTIPLIER
			canHighJump = false
		currentCrouchChargingTime = 0.0
		rawSprite.modulate.r8 = 255

	if !Input.is_action_pressed("ui_down"):
		currentCrouchChargingTime = 0.0
		if canHighJump:
			canHighJump = false
			currentVerticalMultiplier /= CROUCH_JUMP_MULTIPLIER
		rawSprite.modulate.r8 = 255
		
	if Input.is_action_just_released("ui_down"):
		currentHorizontalMultiplier /= CROUCH_RUN_MULTIPLIER
		
	velocity.x = direction * DEFAULT_RUN_SPEED * currentHorizontalMultiplier

	move_and_slide()
