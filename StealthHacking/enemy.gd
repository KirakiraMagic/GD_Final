extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var health := 3

@export var target : CharacterBody2D
@onready var detection_cast = $RayCast2D
@onready var light = $PointLight2D

var can_see = false

@onready var hit_area : Interactable = $HitArea
@onready var sprite = $AnimatedSprite2D


var hit_timeout = 0.0

func _ready():
	hit_area.on_interact = on_hit

func _physics_process(delta):
	hit_timeout -= delta
	if hit_timeout > 0.0:
		sprite.play("hit")
	else:
		sprite.play("idle")

	handle_detection()
	pass

func on_hit(player : CharacterBody2D):
	if hit_timeout > 0.0:
		return

	if Global.cures_held <= 0:
		return
	var player_position = player.global_position
	var facing_direction = sprite.flip_h

	if (not facing_direction and player_position.x > global_position.x) or (facing_direction and player_position.x < global_position.x):
		sprite.play("hit")
		hit_timeout = 0.5
		Global.cures_held -= 1
		health -= 1
	else:
		print("Cannot hit from the front!")

func handle_detection():
	detection_cast.global_position = global_position
	detection_cast.target_position = target.global_position - global_position + Vector2(0, -90)
	if detection_cast.is_colliding():
		var collider = detection_cast.get_collider()
		if collider.is_in_group("player") and Vector2.ZERO.distance_to(detection_cast.target_position) < 500:
			can_see = true
		else:
			can_see = false
	
	if can_see:
		light.color = Color.RED
	else:
		light.color = Color.WHITE