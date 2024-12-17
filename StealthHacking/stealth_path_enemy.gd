extends PathFollow2D

@export var target : CharacterBody2D
@onready var detection_cast = $RayCast2D
@onready var light = $PointLight2D

var can_see = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	progress += delta * 300

	# Cast to the target and see if it is detected
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
			
	pass
