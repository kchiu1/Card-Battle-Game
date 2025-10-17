extends Node2D
class_name Battle

# Reference to the card database (autoload or scene reference)
@export var card_database: CardDatabase

# Basic card-vs-card battle
func battle_cards(card_a: Card, card_b: Card) -> int:

	if card_a == null:
		return card_b.roll()

	if card_b == null:
		return card_a.roll()

	var roll_a = card_a.roll()
	var roll_b = card_b.roll()

	while(roll_a == roll_b):
		roll_a = card_a.roll()
		roll_b = card_b.roll()
		if(roll_a > roll_b):
			return roll_a
		elif(roll_b > roll_a):
			return roll_b
	return 0

func testBattle():

	var deck1_ids = [1,1,1,2,2,10,10,10]
	var deck2_ids = [1,1,2,2,2,2,12,12]

	var deck1 = []
	var deck2 = []

	var p1_hp = 30
	var p2_hp = 30

	for id in deck1_ids:
		var card = card_database.get_card(id)
		if card:
			deck1.append(card)
	for id in deck2_ids:
		var card = card_database.get_card(id)
		if card:
			deck2.append(card)

	while p1_hp > 0 and p2_hp > 0 and deck1.size() > 0 and deck2.size() > 0:
		var card1 = deck1.pop_front()
		var card2 = deck2.pop_front()
		var result = battle_cards(card1, card2)
		if result == 0:
			print("Draw! Both players lose 1 HP")
			p1_hp -= 1
			p2_hp -= 1
		elif result == card1.roll():
			print("Player 1 wins the round! Player 2 loses 2 HP")
			p2_hp -= 2
		else:
			print("Player 2 wins the round! Player 1 loses 2 HP")
			p1_hp -= 2

		print("Player 1 HP: %d, Player 2 HP: %d" % [p1_hp, p2_hp])

		if(deck1.size() == 0):
			deck1_ids = [1,1,1,2,2,10,10,10]
			deck2_ids = [1,1,2,2,2,2,12,12]

func _ready():
	testBattle()
