extends Resource
class_name CardBattle

@export var card_database: CardDatabase

var player_hp: int
var enemy_hp: int

var player_deck: Array = []
var enemy_deck: Array = []

var player_hand: Array = []
var enemy_hand: Array = []

var player_discard: Array = []
var enemy_discard: Array = []


func start_battle(player_ids: Array, enemy_ids: Array, starting_hp := 30):
	player_hp = starting_hp
	enemy_hp = starting_hp

	player_discard.clear()
	enemy_discard.clear()

	player_deck = build_deck(player_ids)
	enemy_deck = build_deck(enemy_ids)

	player_hand = get_hand(player_deck, 5)
	enemy_hand = get_enemy_hand(3)


func build_deck(card_ids: Array) -> Array:
	var deck := []
	for id in card_ids:
		var card = card_database.get_card(id)
		if card:
			deck.append(card)
	return deck


func pick_card(deck: Array, index := 0):
	if deck.is_empty():
		return null
	if index < 0 or index >= deck.size():
		return null

	var card = deck[index] 
	deck.remove_at(index)      
	return card                



func get_hand(deck: Array, size: int) -> Array:
	var h: Array = []
	for i in range(size):
		var c = pick_card(deck)
		if c:
			h.append(c)
	return h


func get_enemy_hand(size: int) -> Array:
	var h: Array = []
	for i in range(size):
		var c = pick_card(enemy_deck)
		if c:
			h.append(c)
	return h


func battle_cards(card_a, card_b) -> Dictionary:
	if card_a == null and card_b == null:
		return {"winner": 0, "damage": 0}

	if card_a == null:
		return {"winner": 1, "damage": card_b.roll()}

	if card_b == null:
		return {"winner": 2, "damage": card_a.roll()}

	var ra = card_a.roll()
	var rb = card_b.roll()

	while ra == rb:
		ra = card_a.roll()
		rb = card_b.roll()

	var w = (1 if ra > rb else 2)
	return {"winner": w, "damage": max(ra, rb), "ra": ra, "rb": rb}


func play_turn(player_indexes: Array) -> Dictionary:
	# 1. Enemy draws 3
	enemy_hand = get_enemy_hand(3)

	# 2. Player picks chosen cards
	var chosen_cards = []
	for idx in player_indexes:
		var c = pick_card(player_hand, idx)
		chosen_cards.append(c)

	# pad to 3
	while chosen_cards.size() < 3:
		chosen_cards.append(null)

	# 3. Resolve all 3 duels
	var results = []
	for i in range(3):
		var ph = chosen_cards[i]
		var eh = enemy_hand[i]
		var out = battle_cards(ph, eh)
		results.append(out)

		if out.winner == 1:
			enemy_hp -= out.damage
		elif out.winner == 2:
			player_hp -= out.damage

	# 4. Discard used cards
	for c in chosen_cards:
		if c:
			player_discard.append(c)

	for c in enemy_hand:
		if c:
			enemy_discard.append(c)

	# 5. Refill player hand to minimum 5
	refill_player_hand()

	return {
		"enemy_hand": enemy_hand,
		"player_cards": chosen_cards,
		"results": results,
		"player_hp": player_hp,
		"enemy_hp": enemy_hp
	}


func refill_player_hand():
	while player_hand.size() < 5:
		if player_deck.is_empty():
			if enemy_discard.is_empty():
				break
			player_deck = player_discard.duplicate()
			player_discard.clear()
		var c = pick_card(player_deck)
		if c:
			player_hand.append(c)
