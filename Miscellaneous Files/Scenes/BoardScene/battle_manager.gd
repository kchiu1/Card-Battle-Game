extends Node

const SMALL_CARD_SCALE = 1
const CARD_MOVE_SPEED = 0.2

const GOLD_REWARD_WIN  = 20   # Gold awarded for winning the battle
const GOLD_REWARD_DRAW = 5    # Gold awarded for a draw

var is_enemy_turn = false
var e_def_mod = 0
var e_atk_mod = 0
var p_def_mod = 0
var p_atk_mod = 0
var battle_over = false

var battle_timer

var enemy_card_slots = []
var player_card_slots = []

var player_health_bar
var enemy_health_bar
var player_number_labels = []
var enemy_number_labels = []
var clash_labels = []
signal ended_turn()

const EnemyDB_Script = preload("res://Scenes/Entities/EnemyDatabase.gd") 
var enemy_db
var enemy_scene = preload("res://Scenes/Entities/Enemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerWallet.init()  # Load saved gold
	player_health_bar = $"../../Player Health"
	enemy_health_bar  = $"../../Enemy Health"
 
	battle_timer = $"../BattleTimer"
	battle_timer.one_shot = true
	battle_timer.wait_time = 0.5
 
	enemy_card_slots.append($"../CardSlots/Enemy Card Slot")
	$"../CardSlots/Enemy Card Slot".pos = 1
	enemy_card_slots.append($"../CardSlots/Enemy Card Slot2")
	$"../CardSlots/Enemy Card Slot2".pos = 2
	enemy_card_slots.append($"../CardSlots/Enemy Card Slot3")
	$"../CardSlots/Enemy Card Slot3".pos = 3
	player_card_slots.append($"../CardSlots/Card Slot")
	$"../CardSlots/Card Slot".pos = 1
	player_card_slots.append($"../CardSlots/Card Slot2")
	$"../CardSlots/Card Slot2".pos = 2
	player_card_slots.append($"../CardSlots/Card Slot3")
	$"../CardSlots/Card Slot3".pos = 3
	enemy_number_labels.append($"../CardSlots/Enemy Number1")
	player_number_labels.append($"../CardSlots/Player Number1")
	clash_labels.append($"../CardSlots/Clash 1")
	clash_labels.append($"../CardSlots/Clash 2")
	clash_labels.append($"../CardSlots/Clash 3")
	enemy_db = EnemyDB_Script.new()
	enemy_db.load_enemies()
	spawn_enemy(1)
	enemy_turn()
 
 
func _on_end_turn_pressed() -> void:
	for lane in range(len(player_card_slots)):
		var player_card = player_card_slots[lane].card
		var enemy_card  = enemy_card_slots[lane].card
		await clash(player_card, enemy_card, lane)
 
	emit_signal("ended_turn")
 
	# check if battle ended after all clashes
	if _check_battle_over():
		return
 
	battle_timer.start()
	await battle_timer.timeout
 
	enemy_turn()
 
 
func enemy_turn():
	is_enemy_turn = true
	$"../EndTurn".disabled = true
	$"../EndTurn".visible  = false
 
	$"../EnemyDeck".draw_card()
	$"../EnemyDeck".draw_card()
 
	battle_timer.start()
	await battle_timer.timeout
 
	var starting_size = randi_range(1, enemy_card_slots.size())
	for i in range(starting_size):
		await play_cards()
 
	end_opponent_turn()
 
func play_cards():
	var enemy_hand = $"../EnemyHand".enemy_hand
	if enemy_hand.size() == 0:
		end_opponent_turn()
		return
	var random_enemy_card_slot = get_random_empty_enemy_slot()
 
	var selected_card = enemy_hand[0]
 
	var tween  = get_tree().create_tween()
	tween.tween_property(selected_card, "position", random_enemy_card_slot.position, CARD_MOVE_SPEED)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(selected_card, "scale", Vector2(SMALL_CARD_SCALE, SMALL_CARD_SCALE), CARD_MOVE_SPEED)
	selected_card.get_node("WeaponSprite").visible = true
	selected_card.get_node("AnimationPlayer").play("card_flip")
 
	$"../EnemyHand".remove_card_from_hand(selected_card, CARD_MOVE_SPEED)
	random_enemy_card_slot.card = selected_card
 
	battle_timer.start()
	await battle_timer.timeout
	return selected_card
 
func end_opponent_turn():
	$"../Deck".draw_card()
	$"../Deck".draw_card()
 
	is_enemy_turn = false
	$"../EndTurn".disabled = false
	$"../EndTurn".visible  = true
 
func lanewait():
	battle_timer.start()
	await battle_timer.timeout
 
func clash(player_card, enemy_card, lane):
	if player_card == null and enemy_card == null:
		pass
	elif player_card == null and enemy_card != null:
		resolve(enemy_card, player_health_bar, enemy_card.roll(), lane)
		await lanewait()
	elif player_card != null and enemy_card == null:
		resolve(player_card, enemy_health_bar, player_card.roll(), lane)
		await lanewait()
	else:
		var p_roll = player_card.roll()
		var e_roll = enemy_card.roll()
		print("proll %d, eroll %d" % [p_roll, e_roll])
		await lanewait()
		if p_roll < e_roll:
			resolve(enemy_card, player_health_bar, e_roll, lane)
		elif e_roll < p_roll:
			resolve(player_card, enemy_health_bar, p_roll, lane)
		else:
			clash_labels[lane].text = "0"
			clash_labels[lane].visible = true
			print("same roll")
		await lanewait()
 
func resolve(card, health_bar, roll, lane):
	if card.type == "attack":
		print("hit")
		clash_labels[lane].text = str(roll)
		clash_labels[lane].visible = true
		health_bar.value = max(health_bar.value - roll, 0)
		print(health_bar.value)
	elif card.type == "util":
		pass
	elif card.type == "defense":
		clash_labels[lane].text = "DEFENDED"
		clash_labels[lane].visible = true
		print("DEFENDED")
 
func get_random_empty_enemy_slot():
	var empty_slots = enemy_card_slots.filter(func(s): return s.card == null)
	if empty_slots.is_empty():
		return null
	return empty_slots.pick_random()
 
func spawn_enemy(id: int):
	var enemy_data = enemy_db.get_enemy(id)
	if enemy_data == null:
		return
	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.enemy_id   = enemy_data.enemy_id
	enemy_instance.enemy_name = enemy_data.enemy_name
	enemy_instance.deck       = enemy_data.deck
	enemy_instance.global_position = Vector2(800, 300)
	get_parent().add_child(enemy_instance)
 
# currency reward functions
 
func _check_battle_over() -> bool:
	"""Returns true if the battle has ended and handles rewards."""
	if battle_over:
		return true
 
	var player_hp = player_health_bar.value
	var enemy_hp  = enemy_health_bar.value
 
	if player_hp <= 0 and enemy_hp <= 0:
		battle_over = true
		_award_gold(GOLD_REWARD_DRAW)
		_show_battle_result("DRAW! You earned %d gold." % GOLD_REWARD_DRAW)
		return true
	elif enemy_hp <= 0:
		battle_over = true
		_award_gold(GOLD_REWARD_WIN)
		_show_battle_result("VICTORY! You earned %d gold!" % GOLD_REWARD_WIN)
		return true
	elif player_hp <= 0:
		battle_over = true
		_show_battle_result("DEFEAT... Better luck next time.")
		return true
 
	return false
 
func _award_gold(amount: int) -> void:
	PlayerWallet.add_gold(amount)
	print("Awarded %d gold. Total: %d" % [amount, PlayerWallet.gold])
 
func _show_battle_result(message: String) -> void:
	"""
	Displays the battle result. 
	Add a Label node called 'BattleResultLabel' to the Board scene,
	or replace this with your own UI logic.
	"""
	print(message)
 
	# Disable end turn button
	$"../EndTurn".disabled = true
	$"../EndTurn".visible  = false
 
	# Show result in UI if the label exists
	if has_node("../BattleResultLabel"):
		$"../BattleResultLabel".text = message
		$"../BattleResultLabel".visible = true
 
	# Wait 3 seconds then return to main menu
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://main/Main Menu.tscn")
