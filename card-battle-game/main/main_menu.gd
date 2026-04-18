extends Node2D

const EnemyDB_Script = preload("res://Scenes/Entities/EnemyDatabase.gd")
var enemy_db

func _ready():
	enemy_db = EnemyDB_Script.new()
	enemy_db.load_enemies()
	
	var dropdown = $"Enemy Select"
	dropdown.clear()
	var keys = enemy_db.enemies.keys()
	keys.sort()
	for id in keys:
		dropdown.add_item(str(id), id)
	
	for i in range(dropdown.get_item_count()):
		if dropdown.get_item_id(i) == Global.selected_enemy_id:
			dropdown.select(i)
			break
	dropdown.connect("item_selected", _on_enemy_selected)
	
	var bg_dropdown = $"Background Select"
	bg_dropdown.clear()

	var dir = DirAccess.open("res://assets/backgrounds/")
	var bg_files = []
	dir.list_dir_begin()
	var file = dir.get_next()
	while file != "":
		if file.ends_with(".png"):
			bg_files.append(file)
		file = dir.get_next()
	dir.list_dir_end()

	bg_files.sort()
	for i in bg_files.size():
		bg_dropdown.add_item(bg_files[i], i)  # filename as label, index as ID

	for i in range(bg_dropdown.get_item_count()):
		if bg_dropdown.get_item_text(i) == Global.background_id:
			bg_dropdown.select(i)
			break

	bg_dropdown.connect("item_selected", _on_bg_selected)

func _on_enemy_selected(index):
	var id = $"Enemy Select".get_item_id(index)
	Global.selected_enemy_id = id
	
func _on_bg_selected(index):
	var id = $"Background Select".get_item_text(index)
	Global.background_id = id

func _on_quit_pressed():
	get_tree().quit()

func _on_explore_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/FightScene/FightScene.tscn")


func _on_guild_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Guild/Bounty Board.tscn")
