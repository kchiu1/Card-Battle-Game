extends Node2D
class_name Card

# Card properties
@export var card_name: String = "Strike"
@export var min: int = 0
@export var max: int = 0
@export var type: String = "Attack" # Can be "Attack", "Defense", "Magic", etc.
@export var effects: Array = []  
@export var attached_items: Array = [] # Items that can be used with this card

#initialization
func _init( _card_name: String = "Strike", _min: int = 0, _max: int = 0, _type: String = "Attack", _effects: Array = []):
	card_name = card_name

	min = _min
	max = _max
	
	type = _type
	effects = _effects.duplicate()
	attached_items = []
	
func roll() -> int:
	return randi() % (max - min + 1) + min
