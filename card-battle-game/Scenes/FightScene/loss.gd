extends Node2D

func _ready():
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	if visible:
		get_parent()._toggle_battle_ui(false)

func _input(event):
	if event is InputEventMouseButton and event.pressed and self.visible == true:
		TransitionScene.transition_to("res://main/Main Menu.tscn")
