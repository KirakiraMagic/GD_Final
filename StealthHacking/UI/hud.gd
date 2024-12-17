extends CanvasLayer

@onready var health_bar = $HealthBar
@onready var cure_bar = $CureBar

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	health_bar.value = Global.health
	match Global.cures_held:
		0:
			cure_bar.value = 0
		1:
			cure_bar.value = 35
		2:
			cure_bar.value = 50
		3:
			cure_bar.value = 100

	pass
