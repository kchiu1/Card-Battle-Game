extends Node2D

func _input(event):
	if event is InputEventMouseButton and event.pressed and self.visible == true:
		TransitionScene.transition_to("res://main/Main Menu.tscn")
