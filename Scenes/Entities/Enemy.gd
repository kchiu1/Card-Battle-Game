extends Node2D
class_name Enemy

var enemy_id: int
var enemy_name: String
var deck: Array = []

func _init(_id: int, _name: String, _deck: Array):
	enemy_id = _id
	enemy_name = _name
	deck = _deck # This contains the IDs from slot_1 to slot_9extends Node
