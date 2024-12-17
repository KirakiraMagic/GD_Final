extends CharacterBody2D

var health =3 
var speed = 300
@export var patrol_distance = 1000
var attack_speed = 800
@export var target : CharacterBody2D
var direction = 1
var start_position = Vector2()
@onready var detection_area = $DetectionArea
@onready var sight_light = $DetectionArea/PointLight2D
@onready var raycast = $RayCast2D
@onready var sprite = $AnimatedSprite2D
var dash_timeout = 0.0
var dash_direction = Vector2.ZERO
var after_attack = false
var hit_timeout = 0.0
@onready var hit_area : Interactable = $HitArea
var active = true

var in_area = false
var can_see = false

func _ready():
	start_position = global_position
	hit_area.on_interact = on_hit


func _physics_process(delta):
	if !active:
		return
	can_see = target_in_sight()

	if can_see:
		sight_light.color = Color(1, 0, 0)
	else:
		sight_light.color = Color(1, 1, 1)

	if health <= 0:
		active = false
		can_see = false
		sight_light.visible = false
		sprite.play("fly")
		var tween = create_tween()
		tween.tween_property(self, "position", $Perch.global_position, 1.0)
		await tween.finished
		sprite.play("idle")
		sprite.flip_h = false
		$"../Area2D".monitoring = true
		$"../SecretDoor".queue_free()
		$"../Puzzles".queue_free()
		return
	
	if hit_timeout > 0.0:
		hit_timeout -= delta
		sprite.play("hit")
		return
	
	if global_position.distance_to(target.global_position) > 500 and after_attack:
		after_attack = false
	
	if can_see or dash_timeout > 0.0: dash_timeout -= delta
	if dash_timeout > 0.0 and !after_attack:
		velocity = dash_direction * attack_speed
		sprite.play("dash")
		var collison = move_and_collide(velocity * delta)
		if collison and can_see:
			for body in hit_area.get_overlapping_bodies():
				if body.is_in_group("player"):
					sprite.play("attack")
					after_attack = true
					body.hit()
			#if collison.get_collider().is_in_group("player"):
			#	sprite.play("attack")
			#	after_attack = true
			#	collison.get_collider().hit()

	elif !after_attack and can_see and dash_timeout <= -0.4:
		dash_direction = global_position.direction_to(target.global_position - Vector2(0, 100)).normalized()
		dash_timeout = 1.0
	
	else:
		if sprite.get_animation() == "attack" and sprite.frame != 2:
			return
		velocity.x = speed * direction
		velocity.y = start_position.y - global_position.y
		velocity = velocity.normalized() * speed

		sprite.play("fly")
		if move_and_collide(velocity * delta):
			direction *= -1

	if velocity.x < 0:
		sprite.flip_h = false
		var tween = create_tween()
		tween.tween_property(detection_area, "rotation", 0, 0.3)
	elif velocity.x > 0:
		sprite.flip_h = true
		var tween = create_tween()
		tween.tween_property(detection_area, "rotation", -2.1, 0.3)

func target_in_sight() -> bool:
	if in_area:
		raycast.target_position = target.global_position - global_position
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			if collider.is_in_group("player"):
				return true
	return false

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

func _on_detection_area_body_exited(body:Node2D):
	if body.is_in_group("player"):
		in_area = false


func _on_detection_area_body_entered(body:Node2D):
	if body.is_in_group("player"):
		in_area = true


func _on_area_2d_body_entered(body:Node2D):
	if body.is_in_group("player"):
		Dialogic.start("level1_after")
		$"../Area2D".monitoring = false
	pass # Replace with function body.
