extends Node2D

@onready var camera = $Player/Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	Dialogic.start("level1_before")
	Dialogic.signal_event.connect(_on_dialogic_signal)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_dialogic_signal(argument: String):
	if argument == "pan_camera":
		var tween = create_tween()
		tween.tween_property(camera, "global_position", Vector2(600, 400), 0.5)
	
	if argument == "pan_camera_back":
		var tween = create_tween()
		tween.tween_property(camera, "position", Vector2(0, 0), 0.5)
