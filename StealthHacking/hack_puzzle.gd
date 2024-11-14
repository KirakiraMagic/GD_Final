extends Node2D

var starters = []

signal win_puzzle

# Called when the node enters the scene tree for the first time.
func _ready():
	for node in get_children():
		if node.starter_id == 0:
			node.starter_id = starters.size() + 1
			starters.append(node)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if starters[0].starters_connected.size() == starters.size():
		for child in get_children():
			child.completed = true
