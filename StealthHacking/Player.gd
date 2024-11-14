extends CharacterBody2D


const WALK_SPEED = 300.0
const RUN_SPEED = 600.0
const CROUCH_SPEED = 150.0

const JUMP_VELOCITY = -400.0

@export var jump_height : float = 100
@export var jump_peak_time : float = 0.2
@export var jump_fall_time : float = 0.1
@export var coyote_time : float = 0.1

@onready var jump_velocity : float = (2.0 * jump_height) / jump_peak_time * (-1.0)
@onready var jump_gravity : float = (2.0 * jump_height) / (jump_peak_time * jump_peak_time)
@onready var fall_gravity : float = (2.0 * jump_height) / (jump_fall_time * jump_fall_time)


var crouching := false
var jumping := false

var jump_available := true
var coyote_timer := 0.0

@onready var sprite : AnimatedSprite2D= $AnimatedSprite2D

func get_player_gravity():
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func _physics_process(delta):
	if Input.is_action_just_pressed("crouch"):
		crouching = !crouching

	# Add the gravity.
	if not is_on_floor():
		if jump_available:
			coyote_timer += delta
			if coyote_timer >= coyote_time:
				jump_available = false
		velocity.y += get_player_gravity() * delta
	else:
		coyote_timer = 0.0
		jump_available =true 
		jumping = false

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and jump_available:
		crouching = false
		velocity.y = jump_velocity
		sprite.play("Jump")
		jumping = true


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		sprite.flip_h = direction < 0
		
		if Input.is_action_pressed("run"):
			crouching = false
			velocity.x = direction * RUN_SPEED
		elif crouching:
			velocity.x = direction * CROUCH_SPEED
		else:
			velocity.x = direction * RUN_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, WALK_SPEED)

	if not jumping:
		if crouching:
			if abs(velocity.x) >= CROUCH_SPEED:
				var current_frame = sprite.get_frame()
				var current_progress = sprite.get_frame_progress()
				if sprite.animation == "Idle" or sprite.animation == "Crouch Idle":
					sprite.play("Crouch Walk")
				else:
					sprite.play("Crouch Walk")
					sprite.set_frame_and_progress(current_frame, current_progress)
			else:
				sprite.play("Crouch Idle")
		else:
			if abs(velocity.x) >= RUN_SPEED:
				var current_frame = sprite.get_frame()
				var current_progress = sprite.get_frame_progress()
				if sprite.animation == "Idle" or sprite.animation == "Crouch Idle":
					sprite.play("Run")
				else:
					sprite.play("Run")
					sprite.set_frame_and_progress(current_frame, current_progress)
			elif abs(velocity.x) >= WALK_SPEED:
				var current_frame = sprite.get_frame()
				var current_progress = sprite.get_frame_progress()
				if sprite.animation == "Idle" or sprite.animation == "Crouch Idle":
					sprite.play("Walk")
				else:
					sprite.play("Walk")
					sprite.set_frame_and_progress(current_frame, current_progress)
			else:
				sprite.play("Idle")

	move_and_slide()
