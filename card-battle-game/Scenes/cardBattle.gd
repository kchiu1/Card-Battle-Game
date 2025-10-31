extends Node
class_name Battle

@export var card_database: CardDatabase

# Initializes battle state
func start_battle(deck1_ids: Array, deck2_ids: Array, starting_hp := 30) -> Dictionary:
	return {
		"p1_hp": starting_hp,
		"p2_hp": starting_hp,
		"deck1": build_deck(deck1_ids),
		"deck2": build_deck(deck2_ids),
	}

# Build deck from card IDs
func build_deck(card_ids: Array) -> Array:
	var deck := []
	for id in card_ids:
		var card = card_database.get_card(id)
		if card:
			deck.append(card)
	return deck

# Shuffle deck
func shuffle(deck: Array) -> Array:
	var new_deck = deck.duplicate()
	new_deck.shuffle()
	return new_deck

# Draw a card from the top (returns card and new deck)
func draw_card(deck: Array) -> Dictionary:
	if deck.is_empty():
		return {"card": null, "deck": deck}
	var card = deck.pop_front()
	return {"card": card, "deck": deck}

# Core card-vs-card logic
func battle_cards(card_a: Card, card_b: Card) -> Dictionary:
	if card_a == null and card_b == null:
		return {"winner": 0, "damage": 0}
	if card_a == null:
		return {"winner": 1, "damage": card_b.roll()}
	if card_b == null:
		return {"winner": 2, "damage": card_a.roll()}

	var roll_a = card_a.roll()
	var roll_b = card_b.roll()

	while roll_a == roll_b:
		roll_a = card_a.roll()
		roll_b = card_b.roll()

	var winner = (1 if roll_a > roll_b else 2)
	var damage = max(roll_a, roll_b)

	return {
		"winner": winner,
		"damage": damage,
		"roll_a": roll_a,
		"roll_b": roll_b
	}

# Process a single turn — returns new game state and event info
func play_turn(state: Dictionary) -> Dictionary:
	if state.deck1.is_empty():
		state.deck1 = shuffle(build_deck(state.deck1_ids))
	if state.deck2.is_empty():
		state.deck2 = shuffle(build_deck(state.deck2_ids))

	var draw1 = draw_card(state.deck1)
	var draw2 = draw_card(state.deck2)
	state.deck1 = draw1.deck
	state.deck2 = draw2.deck

	var result = battle_cards(draw1.card, draw2.card)
	var event = {
		"card1": draw1.card,
		"card2": draw2.card,
		"winner": result.winner,
		"damage": result.damage,
		"roll_a": result.roll_a,
		"roll_b": result.roll_b
	}

	if result.winner == 1:
		if draw1.card.card_type == "Attack":
			state.p2_hp -= result.damage
		elif draw1.card.card_type == "Defense":
			state.p1_hp += result.damage
	elif result.winner == 2:
		if draw2.card.card_type == "Attack":
			state.p1_hp -= result.damage
		elif draw2.card.card_type == "Defense":
			state.p2_hp += result.damage

	state.turn_result = event
	return state

# Check if battle is over
func is_battle_over(state: Dictionary) -> bool:
	return state.p1_hp <= 0 or state.p2_hp <= 0

# Get winner
func get_winner(state: Dictionary) -> int:
	if state.p1_hp <= 0:
		return 2
	elif state.p2_hp <= 0:
		return 1
	return 0
