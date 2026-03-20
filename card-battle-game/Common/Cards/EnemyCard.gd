extends Node2D

var hand_position
var in_card_slot = false

@export var id: int
@export var card_name: String
@export var type: String # "attack" | "defense" | etc
@export var min: int
@export var max: int
@export var effects: Array = []
@export var attached_items: Array = []

#initialization
func _init( _card_name: String = "", _min: int = 0, _max: int = 0, _type: String = "", _effects: Array = []):
	card_name = card_name

	min = _min
	max = _max
	
	type = _type
	effects = _effects.duplicate()
	attached_items = []

func roll() -> int:
	return randi_range(min, max)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().connect_card_signals(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
