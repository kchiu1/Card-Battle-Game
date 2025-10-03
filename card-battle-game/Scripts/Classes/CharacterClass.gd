extends Node
class_name CharacterClass

# Basic stats
@export var className: String = "No Class"
@export var hp: int = 0
@export var baseAttack: int = 0
@export var baseDefense: int = 0

# Abilities and deck
@export var passives: Array = []       # List of passive IDs to call
@export var baseDeck: Array = []       # Array of Card IDs

# description
@export var description: String = ""

# Initialization
func _init(_className: String = "No Class", _hp: int = 0, _baseAttack: int = 0, _baseDefense: int = 0, _passives: Array = [], _baseDeck: Array = [], _description: String = ""):
	
	className = _className
	hp = _hp
	baseAttack = _baseAttack
	baseDefense = _baseDefense
	passives = _passives.duplicate()
	baseDeck = _baseDeck.duplicate()
	description = _description
