extends Resource
class_name Card

@export var id: int
@export var card_name: String
@export var card_type: String # "attack" | "defense" | etc
@export var value_min: int
@export var value_max: int
@export var effects: Array = []
@export var attached_items: Array = []

func roll() -> int:
	return randi_range(value_min, value_max)
