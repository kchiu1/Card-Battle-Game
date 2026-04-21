extends Node

var selected_enemy_id: int = 1
var background_id: String = "0 Field.png"  

var player_deck = [1, 1, 1, 1, 2, 2, 2, 3, 4]

var player_inventory = {
	13: 99
}

var gold: int = 0;

func _ready():
	for card_id in player_deck:
		add_to_inventory(card_id)

func add_to_inventory(card_id: int):
	if player_inventory.has(card_id):
		player_inventory[card_id] += 1
	else:
		player_inventory[card_id] = 1
