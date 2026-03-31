extends Node2D
class_name Mage
# THIS IS AN EXAMPLE CLASS BASED ON WHAT I WROTE IN THE WIKI, THIS IS NOT THE FINAL FORM OF A CLASS BUT AN EXAMPLE OF HOW TO MAKE ONE
# Basic stats
@export var className: String = "Mage"
@export var hp: int = 40
@export var baseAttack: int = 5
@export var baseDefense: int = 3

# Passives - WE WILL CHANGE THIS TO LIKE JUST AN ID FOR PASSIVE AND CALL PASSIVE IDs LATER
@export var passives: Array = [
	"Magic Mastery I: +2 to [Magic] card rolls",
    "Basic Mana Search: +1 draw per turn"
]

# Base Deck - SIMILARLY WILL BE CALLING CARD IDs RATHER THAN ACTUAL CARDS
@export var baseDeck: Array = []

# Description
@export var description: String = "Basic magic class learned through the magic academy"

# Initialization
func _init():
	# Fill the deck with cards
	baseDeck.append(Card.new(3, "Magic Missile", "Attack", ["3-5 atk", "Pierces 1 defense"]))
	baseDeck.append(Card.new(3, "Magic Missile", "Attack", ["3-5 atk", "Pierces 1 defense"]))
	baseDeck.append(Card.new(3, "Magic Missile", "Attack", ["3-5 atk", "Pierces 1 defense"]))
	baseDeck.append(Card.new(3, "Magic Missile", "Attack", ["3-5 atk", "Pierces 1 defense"]))
	baseDeck.append(Card.new(3, "Magic Missile", "Attack", ["3-5 atk", "Pierces 1 defense"]))
	
	baseDeck.append(Card.new(5, "Mana Shield", "Defense", ["5 defense", "Enemy attack -1 for 2 turns"]))
	baseDeck.append(Card.new(5, "Mana Shield", "Defense", ["5 defense", "Enemy attack -1 for 2 turns"]))
	baseDeck.append(Card.new(5, "Mana Shield", "Defense", ["5 defense", "Enemy attack -1 for 2 turns"]))
	baseDeck.append(Card.new(5, "Mana Shield", "Defense", ["5 defense", "Enemy attack -1 for 2 turns"]))
