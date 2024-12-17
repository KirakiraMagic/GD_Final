extends Node

var health = 100.0
var cures_held = 0
signal win_puzzle
signal got_cure

var enabled_player = true

# Called when the node enters the scene tree for the first time.
func _ready():
	Dialogic.signal_event.connect(_on_dialogic_signal)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if health <= 0.0:
		health = 100.0
		cures_held = 0
		get_tree().reload_current_scene()
	
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	pass

func _on_dialogic_signal(argument: String):
	if argument == "enable_player":
		enabled_player = true
	if argument == "disable_player":
		enabled_player = false