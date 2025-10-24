extends Node2D
class_name Battle

# Reference to the card database (autoload or scene reference)
@export var card_database: CardDatabase

# Basic card-vs-card battle
func battle_cards(card_a: Card, card_b: Card) -> Array:

	if card_a == null:
		return [1, card_b.roll()]

	if card_b == null:
		return [2, card_a.roll()]
		
	print ("player 1 used %s" % card_a.card_name)
	print ("player 2 used %s" % card_b.card_name)

	var roll_a = card_a.roll()
	var roll_b = card_b.roll()

	
	print ("Card A rolled: %d, Card B rolled: %d" % [roll_a, roll_b])
	if(roll_a > roll_b):
		return [1, roll_a]
	elif(roll_b > roll_a):
		return [2, roll_b]
	while(roll_a == roll_b):
		roll_a = card_a.roll()
		roll_b = card_b.roll()
		print ("Card A rolled: %d, Card B rolled: %d" % [roll_a, roll_b])
		if(roll_a > roll_b):
			return [1, roll_a]
		elif(roll_b > roll_a):
			return [2, roll_b]
	return [0, 0] #should never hit here to begin with.

func buildDeck(card_ids: Array) -> Array:
	var deck = []

	for id in card_ids:
		print ("Building deck, adding card ID: %d" % id)
		var card = card_database.get_card(id)
		if card:
			deck.append(card)
			print("Added card to deck: %s" % card.card_name)
	return deck

func shuffle (deck: Array) -> Array:
	var shuffled_deck = deck.duplicate()
	shuffled_deck.shuffle()
	return shuffled_deck

func testBattle():

	var deck1_ids = [1,1,1,2,2,10,10,10]
	var deck2_ids = [1,1,2,2,2,2,12,12]

	var deck1 = []
	var deck2 = [] # allows duplicate cards

	var p1_hp = 30
	var p2_hp = 30

	deck1 = buildDeck(deck1_ids)
	deck2 = buildDeck(deck2_ids)

	deck1 = shuffle(deck1)
	deck2 = shuffle(deck2)

	while p1_hp > 0 and p2_hp > 0:
		if(deck1.size() == 0):
			deck1_ids = [1,1,1,2,2,10,10,10]
			deck1 = buildDeck(deck1_ids)
			deck1 = shuffle(deck1)
		if(deck2.size() == 0):
			deck2_ids = [1,1,2,2,2,2,12,12]
			deck2 = buildDeck(deck2_ids)
			deck2 = shuffle(deck2)
		var card1 = deck1.pop_front()
		var card2 = deck2.pop_front()
		var result = battle_cards(card1, card2)
		
		var winner = result[0]
		var damage = result[1]

		if winner == 1:
			print("Player 1 wins the round! Player 2 loses %d HP" % damage)
			p2_hp -= damage
		elif winner == 2:
			print("Player 2 wins the round! Player 1 loses %d HP" % damage)
			p1_hp -= damage 
		print()

		print("Player 1 HP: %d, Player 2 HP: %d" % [p1_hp, p2_hp])

	print("Battle Over! Player 1 HP: %d, Player 2 HP: %d" % [p1_hp, p2_hp] )
	if p1_hp <= 0:
		print("Player 2 Wins!")
	else:
		print("Player 1 Wins!")


func _ready():
	card_database = CardDatabase.new()
	card_database._ready() # initialize manually
	testBattle()
