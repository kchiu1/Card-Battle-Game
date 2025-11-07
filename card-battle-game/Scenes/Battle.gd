extends Node2D

@onready var battle: CardBattle = $BattleManager   # <-- change here

func _ready():
	# Make sure card_database is assigned
	if battle.card_database == null:
		battle.card_database = $CardDatabase   # adjust path if needed

	var deck1 = [1, 1, 2]
	var deck2 = [1, 2, 1]

	var state = battle.start_battle(deck1, deck2, 30)
	state.deck1_ids = deck1
	state.deck2_ids = deck2

	while not battle.is_battle_over(state):
		state = battle.play_turn(state)
		print("Turn result:", state.turn_result)
		print("HP => P1:", state.p1_hp, " P2:", state.p2_hp)

	print("Winner:", battle.get_winner(state))
