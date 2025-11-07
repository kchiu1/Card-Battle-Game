extends Resource
class_name Card

# Card properties
@export var card_name: String = "Strike"
@export var lower: int = 0
@export var upper: int = 0
@export var type: String = "attack" # Can be "Attack", "Defense", "Magic", etc.
@export var effects: Array = []  
@export var attached_items: Array = [] # Items that can be used with this card

#initialization
func _init( _card_name: String = "", _lower: int = 0, _upper: int = 0, _type: String = "Attack", _effects: Array = []):
	card_name = _card_name

	lower = _lower
	upper = _upper
	
	type = _type
	effects = _effects.duplicate()
	attached_items = []
	
func roll() -> int:
	return randi() % (upper - lower + 1) + lower
