extends Node2D

const BOUNTY_SCENE_PATH = "res://Scenes/Guild/Bounty.tscn"

var bounty_scene = preload(BOUNTY_SCENE_PATH)

var bounties = []
const MIN_DISTANCE = 160

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_make_bounties("res://Assets/Enemy/goblin_normal.png", 1, 0)
	_make_bounties("res://Assets/Enemy/Slime_Dog.png", 2, 3)
	_make_bounties("res://Assets/Enemy/knight_of_dark.png", 3, 6)
	_make_bounties("res://Assets/Enemy/knight_of_fire.png", 4, 9)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _make_bounties(sprite_path, id, gold_mod):
	var new_bounty = bounty_scene.instantiate()
	
	var gold = randi_range(1, 5)+gold_mod
	new_bounty.id = id
	new_bounty.fit_sprite_to_box(str(sprite_path))
	new_bounty.get_node("Label").text = str(gold)+"g"
	new_bounty.bounty = gold
	
	# Random position
	var valid_position = false
	var pos = Vector2.ZERO
	
	while not valid_position:
		pos.x = randf_range(320, 1600)
		pos.y = randf_range(256, 834)
		
		valid_position = true
		
		for bounty in bounties:
			if pos.distance_to(bounty.position) < MIN_DISTANCE:
				valid_position = false
				break
	
	new_bounty.position = pos
	add_child(new_bounty)
	bounties.append(new_bounty)

func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://main/Main Menu.tscn")
