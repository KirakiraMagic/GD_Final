extends Interactable

@export var level_number = 1
@onready var scene = load("res://level" + str(level_number) + ".tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func interact(player : CharacterBody2D):
	Global.health = 100
	Global.cures_held = 0
	get_tree().change_scene_to_packed(scene)
