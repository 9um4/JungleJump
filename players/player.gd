extends CharacterBody2D

const CROUCH_SPEED: float = 100.0
const RUN_SPEED: float = 300.0

const DEFAULT_JUMP_VELOCITY: float = -400.0
const CROUCHED_JUMP_VELOCITY: float = -1000.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# child nodes
@onready var sprite: AnimationPlayer = get_node("Sprite")
@onready var rawSprite: AnimatedSprite2D  = get_node("RawSprite")


func _physics_process(delta):
	if velocity.length() == 0:
		if Input.is_action_pressed("ui_down"):
			sprite.play("crouch")
			rawSprite.modulate.r += delta * 10
			rawSprite.modulate.g += delta * 10
			rawSprite.modulate.b += delta * 10
			
			rawSprite.modulate.r = min(100.0, rawSprite.modulate.r)
			rawSprite.modulate.g = min(100.0, rawSprite.modulate.g)
			rawSprite.modulate.b = min(100.0, rawSprite.modulate.b)
		else:
			rawSprite.modulate.r = 1.0
			rawSprite.modulate.g = 1.0
			rawSprite.modulate.b = 1.0
			sprite.play("idle")
	else:
		rawSprite.modulate.r = 1.0
		rawSprite.modulate.g = 1.0
		rawSprite.modulate.b = 1.0
	
	if velocity.x < 0: # facing left
		rawSprite.flip_h = true
	elif velocity.x > 0: # facing right
		rawSprite.flip_h = false
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y < 0: # jumping
			sprite.play("jump")
		elif velocity.y > 0: # falling
			sprite.play("fall")

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = DEFAULT_JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * RUN_SPEED
		if is_on_floor():
			sprite.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, RUN_SPEED)

	move_and_slide()
