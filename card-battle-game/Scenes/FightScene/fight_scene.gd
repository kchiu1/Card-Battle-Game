extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var bg_id = Global.background_id 
	var texture = load("res://assets/backgrounds/" + Global.background_id)
	$Background.texture = texture
	#$Loss.visible = false
	_toggle_battle_ui(true)
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://main/Main Menu.tscn")


func _toggle_battle_ui(is_visible: bool):
	$"Enemy Health".visible = is_visible
	$"Player Health".visible = is_visible
	$"Main Menu".visible = is_visible
	$Board.visible = is_visible
	$Enemy.visible = is_visible
