extends CanvasLayer

@onready var small_hacking_puzzle_1 = preload("res://small_hacking_puzzle_1.tscn")
@onready var small_hacking_puzzle_2 = preload("res://small_hacking_puzzle_2.tscn")
@onready var small_hacking_puzzle_3 = preload("res://small_hacking_puzzle_3.tscn")
@onready var small_hacking_puzzle_4 = preload("res://small_hacking_puzzle_4.tscn")
@onready var medium_hacking_puzzle_1 = preload("res://medium_hacking_puzzle_1.tscn")
@onready var medium_hacking_puzzle_2 = preload("res://medium_hacking_puzzle_2.tscn")

@export var things: Array[Node2D]

var puzzles
var puzzle_locations

# Called when the node enters the scene tree for the first time.
func _ready():
	puzzles = [small_hacking_puzzle_1, small_hacking_puzzle_2, small_hacking_puzzle_3, small_hacking_puzzle_4]
	puzzle_locations = get_children()
	Dialogic.signal_event.connect(_on_dialogic_signal)
	pass # Replace with function body.
var wait_time = 5.0
var wait_timer = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for thing in things:
		if thing.can_see:
			wait_timer += delta
	if wait_timer > wait_time:
		wait_timer = 0.0
		var puzzle = puzzles[randi_range(0, puzzles.size() - 1)].instantiate()
		puzzle.scale = Vector2(0.5, 0.5)
		var location = puzzle_locations[randi_range(0, puzzle_locations.size() - 1)]
		if location.get_child_count() == 0:
			location.add_child(puzzle)
	pass

func _on_dialogic_signal(argument):
	if argument == "puzzle":
		var puzzle = puzzles[randi_range(0, puzzles.size() - 1)].instantiate()
		puzzle.scale = Vector2(0.5, 0.5)
		var location = puzzle_locations[randi_range(0, puzzle_locations.size() - 1)]
		location.add_child(puzzle)
		
