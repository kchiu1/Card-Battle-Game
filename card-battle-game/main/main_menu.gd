extends Node2D

const EnemyDB_Script = preload("res://Scenes/Entities/EnemyDatabase.gd")
var enemy_db

func _ready():
	enemy_db = EnemyDB_Script.new()
	enemy_db.load_enemies()
	
	var dropdown = $OptionButton
	dropdown.clear()
	var keys = enemy_db.enemies.keys()
	keys.sort()  # make sure order is consistent
	for id in keys:
		dropdown.add_item(str(id), id)
	
	# Set dropdown to match current global selection
	for i in range(dropdown.get_item_count()):
		if dropdown.get_item_id(i) == Global.selected_enemy_id:
			dropdown.select(i)
			break
	
	dropdown.connect("item_selected", _on_enemy_selected)

func _on_enemy_selected(index):
	var id = $OptionButton.get_item_id(index)
	Global.selected_enemy_id = id

func _on_quit_pressed():
	get_tree().quit()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/FightScene/FightScene.tscn")
