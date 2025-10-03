extends Node
class_name Card

# Card properties
@export var value: int = 0
@export var cardName: String = "Strike"
@export var type: String = "Attack"  
@export var effects: Array = []  

#initialization
func _init(_value: int = 0, _cardName: String = "Strike", _type: String = "Attack", _effects: Array = []):
	value = _value
	cardName = _cardName
	type = _type
	effects = _effects.duplicate()
