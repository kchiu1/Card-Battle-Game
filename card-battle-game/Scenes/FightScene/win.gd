extends Node2D

func _ready():
	$"New Battle".pressed.connect(_on_new_battle)
	$"Main Menu".pressed.connect(_on_main_menu)

func _disable_buttons():
	$"New Battle".disabled = true
	$"Main Menu".disabled = true

func _on_new_battle():
	_disable_buttons()
	TransitionScene.transition_to("res://Scenes/FightScene/FightScene.tscn")

func _on_main_menu():
	_disable_buttons()
	TransitionScene.transition_to("res://main/Main Menu.tscn")
