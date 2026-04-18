extends Node2D

const BOUNTY_SCENE_PATH = "res://Scenes/Guild/Bounty.tscn"

var bounty_scene = preload(BOUNTY_SCENE_PATH)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_make_bounties()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _make_bounties():
	var new_bounty = bounty_scene.instantiate()
	var enemy_image_path = str("res://Assets/Enemy/goblin_normal.png")
	
	new_bounty.fit_sprite_to_box(enemy_image_path)
	new_bounty.get_node("Label").text = str(randi_range(1, 5))+"g"
	
	# Random position
	var x = randf_range(320, 1600)
	var y = randf_range(256, 834)
	new_bounty.position = Vector2(x, y)
	
	add_child(new_bounty)

func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://main/Main Menu.tscn")
