@tool
extends Sprite2D
class_name Hacking_Hexagon

var unconnected_image : Texture2D
var connected_image : Texture2D
var completed_image : Texture2D

@export var starter_id = -1

var starters_connected = []

@export var node_prongs : Array[bool]= [false, false, false, false ,false, false]:
	set = set_prongs

var completed = false

var target_rotation = 0.0

func set_prongs(new_value):
	node_prongs = new_value
	if Engine.is_editor_hint():
		for i in range(0, $ConnectionArea.get_child_count()):
			pass
			if node_prongs[i]:
				$ConnectionArea.get_child(i).show()
			else:
				$ConnectionArea.get_child(i).hide()

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint():
		return
	for child in $ConnectionArea.get_children():
		if child.visible == false:
			child.queue_free()
	var path = texture.get_path()
	var connected_path = path.replace("Unconnected", "Connected")
	var completed_path = path.replace("Unconnected", "Completed")
	unconnected_image = load(path)
	connected_image = load(connected_path)
	completed_image = load(completed_path)
	if starter_id != -1:
		starters_connected.append(starter_id)
	pass
	target_rotation = rotation


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		return
	if completed:
		texture = completed_image
		return
	var starters = []
	if starter_id > 0:
		starters.append(starter_id)
	for area in $ConnectionArea.get_overlapping_areas():
		for starter in area.get_parent().starters_connected:
			if !starters.has(starter):
				starters.append(starter)
	starters_connected = starters

	if starters_connected.size() > 0:
		texture = connected_image
	else:
		texture = unconnected_image

	if rotation != target_rotation:
		rotation = lerp(rotation, target_rotation, 0.2)
		if abs(rotation - target_rotation) < 0.01:
			rotation = target_rotation
	pass

var turning = false

func _on_click_area_input_event(viewport:Node, event:InputEvent, shape_idx:int):
	print("click")
	if starter_id != -1:
		return
	if completed:
		return
	if event.is_action_pressed("click"):
		target_rotation += PI/3

func _input(event):
	if starter_id != -1:
		return
	if completed:
		return
	if event.is_action_pressed("click"):
		if get_rect().has_point(to_local(event.position)):
			target_rotation += PI/3
	pass
		

func on_win_puzzle():
	texture = completed_image
	pass
