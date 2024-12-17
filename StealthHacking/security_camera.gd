extends Node2D

@onready var sight_cast = $SightCast
@onready var sprite = $Sprite2D
@onready var detection_area = $DetectionArea
@onready var raycast = $RayCast2D
@export var target : CharacterBody2D
@onready var light = $DetectionArea/PointLight2D
var in_area = false
var can_see = false
@export var speed = 50
@export var roam_distance = 100
var start_position = Vector2()

@export var start_degrees = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	detection_area.rotation = deg_to_rad(start_degrees)
	start_position = global_position
	pass # Replace with function body.

@export var turn_direction = 1
@export var move_direction = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if can_see:
		light.color = Color(1, 0, 0)
	else:
		light.color = Color(1, 1, 1)
	
	detection_area.rotation += turn_direction * delta * 0.5
	if abs(detection_area.rotation) > deg_to_rad(45):
		turn_direction *= -1

	position.x += move_direction * speed * delta
	if abs(position.x - start_position.x) > roam_distance:
		move_direction *= -1
		sprite.flip_h = move_direction < 0
	
	raycast.target_position = target.global_position - (global_position + Vector2(0, 40))

	if in_area:
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			if collider.is_in_group("player"):
				can_see = true
			else:
				can_see = false
		else:
			can_see = false
	else:
		can_see = false
	pass

func _on_detection_area_body_entered(body):
	print("body entered")
	if body.is_in_group("player"):
		print("player entered")
		in_area = true

func _on_detection_area_body_exited(body):
	print("body exited")
	if body.is_in_group("player"):
		print("player exited")
		in_area = false

