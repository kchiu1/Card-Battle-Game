extends Node2D
class_name ConsoleBattle

@export var card_database: CardDatabase
@export var battle: CardBattle

# Mode:
# true = interactive (player chooses cards)
# false = auto-play (random selection)
var interactive_mode := true


func run_console_battle():
	print("=== CARD BATTLE START ===")

	# Example decks for testing (replace with real IDs)
	var player_ids = [1,2,10,11,12]
	var enemy_ids = [1,2,10,11,12]

	# Start the battle
	battle.start_battle(player_ids, enemy_ids)

	var turn = 1
	while not battle.is_battle_over():
		print("\n--- TURN %d ---" % turn)
		print("Player HP:", battle.player_hp, " Enemy HP:", battle.enemy_hp)
		
		# Enemy draws 3 cards
		var enemy_cards = battle.get_enemy_hand(3)
		print("Enemy has played 3 cards.")

		# Player chooses cards
		var chosen_indexes: Array = []

		if interactive_mode:
			_print_player_hand()
			print("Select 0–3 cards to play (space-separated indexes, Enter to pass):")
			var input = OS.read_string_from_stdin().strip_edges()

			if input != "":
				for s in input.split(" "):
					var idx = int(s)
					if idx >= 0 and idx < battle.player_hand.size():
						chosen_indexes.append(idx)
		else:
			# Auto pick up to 3 random cards
			var hand_size = battle.player_hand.size()
			var num_to_play = randi_range(0, min(3, hand_size))
			chosen_indexes = []
			var available_indexes = []
			for i in range(hand_size):
				available_indexes.append(i)
			available_indexes.shuffle()
			for i in range(num_to_play):
				chosen_indexes.append(available_indexes[i])
			print("Auto-selected cards:", chosen_indexes)

		# Execute turn
		var turn_result = battle.play_turn(chosen_indexes)

		# Show results
		for i in range(3):
			var p = turn_result.player_cards[i]
			var e = turn_result.enemy_hand[i]
			var r = turn_result.results[i]

			var p_name = p.card_name if p else "None"
			var e_name = e.card_name if e else "None"
			var winner = r.winner
			var dmg = r.damage

			if winner == 0:
				print("Slot %d: Tie (%s vs %s)" % [i+1, p_name, e_name])
			elif winner == 1:
				print("Slot %d: Player wins! (%s vs %s) deals %d damage" % [i+1, p_name, e_name, dmg])
			elif winner == 2:
				print("Slot %d: Enemy wins! (%s vs %s) deals %d damage" % [i+1, p_name, e_name, dmg])

		print("End of Turn %d: Player HP=%d Enemy HP=%d" % [turn, battle.player_hp, battle.enemy_hp])
		turn += 1

	# Battle over
	var winner = battle.get_winner()
	if winner == 1:
		print("\n=== PLAYER WINS! ===")
	elif winner == 2:
		print("\n=== ENEMY WINS! ===")
	else:
		print("\n=== DRAW ===")


func _print_player_hand():
	print("Your Hand:")
	for i in range(battle.player_hand.size()):
		var c = battle.player_hand[i]
		print("%d: %s (%d-%d)" % [i, c.card_name, c.value_min, c.value_max])
