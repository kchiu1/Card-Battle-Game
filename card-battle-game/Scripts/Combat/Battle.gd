extends Node2D
class_name Battle

# Reference to the card database (autoload or scene reference)
@export var card_database: CardDatabase

# Basic card-vs-card battle
func battle_cards(card_a_id: int, card_b_id: int) -> void:
	if card_database == null:
		print("No CardDatabase assigned!")
		return

	var card_a: Card = card_database.get_card(card_a_id)
	var card_b: Card = card_database.get_card(card_b_id)

	if card_a = null:
		# card b instant wins
		print("Card A not found, Card B wins by default!")
		return