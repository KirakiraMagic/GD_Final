extends CharacterBody2D

const MAX_HEALTH = 100
var health = 100.0

const RUN_SPEED = 600.0
const CROUCH_SPEED = 150.0
const JUMP_VELOCITY = -400.0

@onready var stand_collider = $StandCollider
@onready var crouch_collider = $CrouchCollider
@onready var stand_cast = $StandCast
@onready var standOccluder = $StandOccluder
@onready var crouchOccluder = $CrouchOccluder

@export var jump_height : float = 100
@export var jump_peak_time : float = 0.2
@export var jump_fall_time : float = 0.1
@export var coyote_time : float = 0.1

@onready var jump_velocity : float = (2.0 * jump_height) / jump_peak_time * (-1.0)
@onready var jump_gravity : float = (2.0 * jump_height) / (jump_peak_time * jump_peak_time)
@onready var fall_gravity : float = (2.0 * jump_height) / (jump_fall_time * jump_fall_time)

var crouching = false
var jumping = false
var jump_available = true
var coyote_timer = 0.0

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

func get_player_gravity():
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func _physics_process(delta):
	handle_crouch()
	handle_gravity(delta)
	handle_jump()
	handle_movement(delta)
	handle_animation()
	move_and_slide()
	update_health(delta)

func handle_crouch():
	if Input.is_action_just_pressed("crouch"):
		if crouching and stand_cast.is_colliding():
			return
		crouching = !crouching
		if crouching:
			standOccluder.visible = false
			crouchOccluder.visible = true
			crouch_collider.disabled = false
			stand_collider.disabled = true
		else:
			standOccluder.visible = true
			crouchOccluder.visible = false
			crouch_collider.disabled = true
			stand_collider.disabled = false

func handle_gravity(delta):
	if not is_on_floor():
		if jump_available:
			coyote_timer += delta
			if coyote_timer >= coyote_time:
				jump_available = false
		velocity.y += get_player_gravity() * delta
	else:
		coyote_timer = 0.0
		jump_available = true
		jumping = false

func handle_jump():
	if Input.is_action_just_pressed("move up") and jump_available:
		if crouching and stand_cast.is_colliding():
			return
		crouching = false
		standOccluder.visible = true
		crouchOccluder.visible = false
		crouch_collider.disabled = true
		stand_collider.disabled = false
		velocity.y = jump_velocity
		sprite.play("Jump")
		jumping = true

func handle_movement(delta):
	var direction = Input.get_axis("move left", "move right")
	if direction:
		sprite.flip_h = direction < 0
		if crouching:
			velocity.x = direction * CROUCH_SPEED * 60 * delta
		else:
			velocity.x = direction * RUN_SPEED * 60 * delta
	else:
		velocity.x = move_toward(velocity.x, 0, RUN_SPEED * 60 * delta)

func handle_animation():
	if not jumping:
		if crouching:
			play_animation("Crouch Walk", "Crouch Idle", CROUCH_SPEED)
		else:
			play_animation("Run", "Idle", RUN_SPEED)

func play_animation(run_anim, idle_anim, run_speed):
	if abs(velocity.x) >= run_speed:
		play_and_sync_animation(run_anim)
	else:
		sprite.play(idle_anim)

func play_and_sync_animation(animation_name):
	var current_frame = sprite.get_frame()
	var current_progress = sprite.get_frame_progress()
	if sprite.animation in ["Idle", "Crouch Idle"]:
		sprite.play(animation_name)
	else:
		sprite.play(animation_name)
		sprite.set_frame_and_progress(current_frame, current_progress)

func update_health(delta):
	for i in $"../CanvasLayer".get_children():
		if i.get_child_count() > 0:
			health -= 2 * delta
	health += 1 * delta
