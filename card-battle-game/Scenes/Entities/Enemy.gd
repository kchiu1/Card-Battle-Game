# Enemy.gd
extends Node2D
class_name Enemy

var enemy_id: int
var enemy_name: String
var deck: Array = []
var sprite_path: String

func _ready():
	pass

func apply_sprite():
	print("apply_sprite called: ", sprite_path)
	if sprite_path != "":
		$GoblinNormal.texture = load(sprite_path)
