extends Interactable

func interact(character : CharacterBody2D):
	if Global.cures_held < 3:
		Global.cures_held += 1
		Global.got_cure.emit()
		queue_free()
		print("cure")
