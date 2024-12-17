extends Area2D
class_name Interactable

var on_interact : Callable 

func interact(player : CharacterBody2D):
	if on_interact:
		on_interact.call(player)
