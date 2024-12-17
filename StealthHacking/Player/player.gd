extends CharacterBody2D

# Shape cast for checking if there is room for the player to stand up after crouching.
@onready var stand_cast : ShapeCast2D= $StandCast

@export var run_speed : float = 600
@export var crouch_speed : float = 150

@export var jump_height : float = 200
@export var jump_peak_time : float = 0.3
@export var jump_fall_time : float = 0.2
@export var coyote_time : float = 0.1

@onready var jump_velocity : float = (2.0 * jump_height) / jump_peak_time * (-1.0)
@onready var jump_gravity : float = (2.0 * jump_height) / (jump_peak_time * jump_peak_time)
@onready var fall_gravity : float = (2.0 * jump_height) / (jump_fall_time * jump_fall_time)

@onready var animation_tree = $AnimationTree
@onready var sprite = $Sprite

const HIT_TIME = 0.3
var hit_timeout = 0.0

@onready var interaction_area = $InteractionArea

var crouching := false
var jumping := false
var jump_available := true
var coyote_timer := 0.0


func hit(damage := 10):
	animation_tree.set("parameters/OneShot 2/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	Global.health -= damage
	hit_timeout = HIT_TIME

func handle_crouch():
	if Input.is_action_just_pressed("crouch"):
		if (crouching and stand_cast.is_colliding()) or !is_on_floor():
			return
		crouching = !crouching

func get_player_gravity():
	return jump_gravity if velocity.y < 0.0 else fall_gravity

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
		velocity.y = jump_velocity
		jumping = true

func handle_movement(delta):
	var direction = Input.get_axis("move left", "move right")
	if direction:
		sprite.flip_h = direction < 0
		if crouching:
			velocity.x = direction * crouch_speed * 60 *  delta
		else:
			velocity.x = direction * run_speed * 60 *delta
		interaction_area.position.x = abs(interaction_area.position.x) * (1 if direction > 0 else -1)
	else:
		velocity.x = move_toward(velocity.x, 0, run_speed * 60 * delta)

func update_health(delta):
	if $"../Puzzles":
		for i in $"../Puzzles".get_children():
			if i.get_child_count() > 0:
				Global.health -= 3 * delta
	Global.health += 1 * delta
	
	animation_tree.set("parameters/infection_level/blend_position", remap(Global.health, 100.0, 0.0, 0.0, 2.0))

func handle_interactions():
	if Input.is_action_just_pressed("interact"):
		animation_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		var closest_body = null
		var closest_distance := Vector2.INF
		for body in interaction_area.get_overlapping_areas():
			if body.has_method("interact"):
				if interaction_area.global_position.distance_to(body.position) < interaction_area.global_position.distance_to(closest_distance) or body.is_in_group("enemy"):
					closest_body = body
					closest_distance = body.position
		if closest_body != null:
			closest_body.interact(self)
func _physics_process(delta):
	if !Global.enabled_player:
		return
	if hit_timeout > 0.0:
		hit_timeout -= delta
		return
	handle_crouch()
	handle_gravity(delta)
	handle_jump()
	handle_movement(delta)
	move_and_slide()
	update_health(delta)
	handle_interactions()
