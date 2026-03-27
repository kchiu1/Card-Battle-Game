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
	if sprite_path != "":
		var tex = load(sprite_path)
		print("texture loaded: ", tex)
		$Sprite.texture = tex
