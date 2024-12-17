extends Node2D

var starters = []

signal win_puzzle

var active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	for node in get_children():
		if node.starter_id == 0:
			node.starter_id = starters.size() + 1
			starters.append(node)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var complete = true
	for starter in starters:
		if starter.starters_connected.size() < starters.size():
			complete = false
			break

	if complete:

		for child in get_children():
			child.completed = true
		await get_tree().create_timer(0.1).timeout
		for child in get_children():
			var tween = create_tween()
			tween.tween_property(child, "scale", Vector2(0, 0), 0.5)
		await get_tree().create_timer(0.5).timeout
		queue_free()
		Global.win_puzzle.emit()
