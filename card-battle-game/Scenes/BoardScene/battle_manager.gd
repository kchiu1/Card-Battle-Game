extends Node

const SMALL_CARD_SCALE = 1
const CARD_MOVE_SPEED = 0.2
const PLAYER_ID = 1
const ENEMY_ID = 2

var is_enemy_turn = false
var e_def_mod = 0
var e_atk_mod = 0
var p_def_mod = 0
var p_atk_mod = 0

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
	player_health_bar = $"../../Player Health"
	enemy_health_bar =$"../../Enemy Health"
	
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
	#enemy_number_labels.append($"../CardSlots/Enemy Number2")
	#enemy_number_labels.append($"../CardSlots/Enemy Number3")
	player_number_labels.append($"../CardSlots/Player Number1")
	#player_number_labels.append($"../CardSlots/Player Number2")
	#player_number_labels.append($"../CardSlots/Player Number3")
	clash_labels.append($"../CardSlots/Clash 1")
	clash_labels.append($"../CardSlots/Clash 2")
	clash_labels.append($"../CardSlots/Clash 3")
	enemy_db = EnemyDB_Script.new()
	enemy_db.load_enemies()
	spawn_enemy(Global.selected_enemy_id)
	enemy_turn()
	
func spawn_enemy(id: int):
	var enemy_data = enemy_db.get_enemy(id)
	if enemy_data.is_empty(): return
	print(get_tree().get_root().get_children())
	print(get_path())
	var enemy_instance = get_node("/root/Fight Scene/Enemy")
	enemy_instance.enemy_id = int(enemy_data["id"])
	enemy_instance.enemy_name = enemy_data["enemy_list"]
	enemy_instance.deck = enemy_data["deck"]
	enemy_instance.sprite_path = enemy_data["sprite_path"]
	enemy_instance.apply_sprite()
	
	get_parent().get_node("EnemyDeck").setup(enemy_data["deck"])
	
	
func _on_end_turn_pressed() -> void:
	$"../EndTurn".disabled = true
	$"../EndTurn".visible = false
	#resolve function that calculates the roll, takes the higher one, and subtracts it from the player/enemy HP bar
	#see card manager for discard
	
	# Clash
	#check for defense cards to taunt attacks (do later)
	for lane in range(len(player_card_slots)):
		var player_card = player_card_slots[lane].card
		var enemy_card = enemy_card_slots[lane].card
		await clash(player_card, enemy_card, lane)
	
	emit_signal("ended_turn")
	
	# wait 1 second
	battle_timer.start()
	await battle_timer.timeout
	
	e_def_mod = 0
	e_atk_mod = 0
	p_def_mod = 0
	p_atk_mod = 0
	
	enemy_turn()


func enemy_turn():
	is_enemy_turn = true
	$"../EndTurn".disabled = true
	$"../EndTurn".visible = false
	
	await $"../EnemyDeck".draw_card()
	await $"../EnemyDeck".draw_card()
	
	# wait 1 second, clear lane numbers
	battle_timer.start()
	clash_labels[0].visible = false
	clash_labels[1].visible = false
	clash_labels[2].visible = false
	await battle_timer.timeout
	
	# Play Enemy cards
	var starting_size = randi_range(1,enemy_card_slots.size())
	for i in range(starting_size):
		await play_cards()

	end_opponent_turn()

func play_cards():
	var enemy_hand = $"../EnemyHand".enemy_hand
	if enemy_hand.size() == 0:
		end_opponent_turn()
		return
	var random_card_slot = randi_range(1, enemy_card_slots.size())-1
	var random_enemy_card_slot = get_random_empty_enemy_slot()
	
	var selected_card = enemy_hand[0]
	
	var tween = get_tree().create_tween()
	tween.tween_property(selected_card, "position", random_enemy_card_slot.position, CARD_MOVE_SPEED)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(selected_card, "scale", Vector2(SMALL_CARD_SCALE, SMALL_CARD_SCALE), CARD_MOVE_SPEED)
	selected_card.get_node("WeaponSprite").visible = true
	selected_card.get_node("AnimationPlayer").play("card_flip")
	
	$"../EnemyHand".remove_card_from_hand(selected_card, CARD_MOVE_SPEED)
	random_enemy_card_slot.card = selected_card
	
	# wait 1 second
	battle_timer.start()
	await battle_timer.timeout
	return selected_card
	
func end_opponent_turn():
	# reset player deck draw
	await $"../Deck".draw_card()
	await $"../Deck".draw_card()
		
	is_enemy_turn = false
	$"../EndTurn".disabled = false
	$"../EndTurn".visible = true

func lanewait():
	battle_timer.start()
	await battle_timer.timeout
# TODO -V
# work on individual card numbers
func clash(player_card, enemy_card, lane):
	if(player_card==null and enemy_card == null):
		return
	elif(player_card==null):
		resolve(enemy_card, player_health_bar, _get_roll(enemy_card, ENEMY_ID), lane, ENEMY_ID)
		await lanewait()
	elif(enemy_card == null):
		resolve(player_card, enemy_health_bar, _get_roll(player_card, PLAYER_ID), lane, PLAYER_ID)
		await lanewait()
	else: #clash
		var p_roll = _get_roll(player_card, PLAYER_ID)
		var e_roll = _get_roll(enemy_card, ENEMY_ID)
		#print("proll %d, eroll %d" %[p_roll, e_roll])
		#player_number_labels[lane].text = str(p_roll)
		#player_number_labels[lane].visible = true
		#await lanewait()
		#enemy_number_labels[lane].text = str(e_roll)
		#enemy_number_labels[lane].visible = true
		#await lanewait()
		if player_card.type == "util":
			resolve(player_card, null, p_roll, lane, PLAYER_ID)
		if enemy_card.type == "util":
			resolve(enemy_card, null, e_roll, lane, ENEMY_ID)
		
		if player_card.type != "util" and enemy_card.type != "util":
			if p_roll > e_roll:
				resolve(player_card, enemy_health_bar, p_roll, lane, PLAYER_ID)
			elif e_roll > p_roll:
				resolve(enemy_card, player_health_bar, e_roll, lane, ENEMY_ID)
			else:
				if player_card.type == "defense" or enemy_card.type == "defense":
					clash_labels[lane].text = "DEFENDED"
				else:
					clash_labels[lane].text = "0"
				clash_labels[lane].visible = true
		elif player_card.type != "util":
			resolve(player_card, enemy_health_bar, p_roll, lane, PLAYER_ID)
		elif enemy_card.type != "util":
			resolve(enemy_card, player_health_bar, e_roll, lane, ENEMY_ID)

		#player_number_labels[lane].visible = false
		#enemy_number_labels[lane].visible = false
		await lanewait()

func resolve(card, health_bar, roll, lane, user):
	# determine color of clash winner
	if user == PLAYER_ID:
		clash_labels[lane].add_theme_color_override("font_color", Color(0, 0.5, 1)) # blue
	else:
		clash_labels[lane].add_theme_color_override("font_color", Color(1, 0.2, 0.2)) # red
	match card.type:
		"attack":
			clash_labels[lane].text = str(roll)
			clash_labels[lane].visible = true
			health_bar.value = max(health_bar.value - roll, 0)
		"defense":
			clash_labels[lane].text = "DEFENDED"
			clash_labels[lane].visible = true
		"util":
			_apply_util_effect(card, roll, user)
		
func _get_roll(card, user: int) -> int:
	var base = card.roll()
	print("base:\n",base)
	match card.type:
		"attack":
			if user == PLAYER_ID:
				base += p_atk_mod
			else:
				base += e_atk_mod
		"defense":
			if user == PLAYER_ID:
				base += p_def_mod
			else:
				base += e_def_mod
	print(base)
	return base

func _apply_util_effect(card, roll: int, user: int) -> void:
	print("Apply util:\n",p_atk_mod)
	match card.id:
		3: # atk up
			if user == PLAYER_ID: 
				p_atk_mod += roll
			else: 
				e_atk_mod += roll
		4: # def up
			if user == PLAYER_ID: 
				p_def_mod += roll
			else: 
				e_def_mod += roll
	
	print(p_atk_mod)

func next_empty_slot():
	for card_slot in player_card_slots:
		if not card_slot.card_in_slot:
			return card_slot
	return null

func get_random_empty_enemy_slot():
	var empty_slots = enemy_card_slots.filter(func(s): return s.card == null)
	if empty_slots.is_empty():
		return null
	return empty_slots.pick_random()
