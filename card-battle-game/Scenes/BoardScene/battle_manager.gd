extends Node

const SMALL_CARD_SCALE = 1
const CARD_MOVE_SPEED = 0.2

var is_enemy_turn = false

var battle_timer

var enemy_card_slots = []
var player_card_slots = []

var player_health_bar
var enemy_health_bar

signal ended_turn()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    player_health_bar = $"../../Player Health"
    enemy_health_bar =$"../../Enemy Health"
    
    battle_timer = $"../BattleTimer"
    battle_timer.one_shot = true
    battle_timer.wait_time = 1.0
    
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
    
    enemy_turn()


func _on_end_turn_pressed() -> void:
    #resolve function that calculates the roll, takes the higher one, and subtracts it from the player/enemy HP bar
    #see card manager for discard
    
    # Clash
    #check for defense cards to taunt attacks (do later)
    for lane in range(len(player_card_slots)):
        var player_card = player_card_slots[lane].card
        var enemy_card = enemy_card_slots[lane].card
        clash(player_card, enemy_card)
    
    emit_signal("ended_turn")
    
    # wait 1 second
    battle_timer.start()
    await battle_timer.timeout
    
    enemy_turn()


func enemy_turn():
    is_enemy_turn = true
    $"../EndTurn".disabled = true
    $"../EndTurn".visible = false
    
    $"../EnemyDeck".draw_card()
    $"../EnemyDeck".draw_card()
    
    # wait 1 second
    battle_timer.start()
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
    selected_card.get_node("AnimationPlayer").play("card_flip")
    
    $"../EnemyHand".remove_card_from_hand(selected_card, CARD_MOVE_SPEED)
    random_enemy_card_slot.card = selected_card
    
    # wait 1 second
    battle_timer.start()
    await battle_timer.timeout
    return selected_card
    
func end_opponent_turn():
    # reset player deck draw
    $"../Deck".draw_card()
    $"../Deck".draw_card()
        
    is_enemy_turn = false
    $"../EndTurn".disabled = false
    $"../EndTurn".visible = true

func clash(player_card, enemy_card):
    if(player_card==null and enemy_card == null):
        pass
    elif(player_card==null and enemy_card != null):
        resolve(enemy_card, player_health_bar, enemy_card.roll())
    elif(player_card!=null and enemy_card == null):
        resolve(player_card, enemy_health_bar, player_card.roll())
    else:
        var p_roll = player_card.roll()
        var e_roll = enemy_card.roll()
        print("proll %d, eroll %d" %[p_roll, e_roll])
        if(p_roll < e_roll):
            resolve(enemy_card, player_health_bar, e_roll)
        elif(e_roll < p_roll):
            resolve(player_card, enemy_health_bar, p_roll)
        else:
            print("same roll")
            pass    

func resolve(card, health_bar, roll):
    if card.type == "attack":
        print("hit")
        health_bar.value = max(health_bar.value - roll, 0) # Prevent negative
        print(health_bar.value)
    elif card.type == "util":
        #code later
        pass
    elif card.type == "defense":
        print("DEFENDED")

func get_random_empty_enemy_slot():
    var empty_slots = enemy_card_slots.filter(func(s): return s.card == null)
    if empty_slots.is_empty():
        return null
    return empty_slots.pick_random()
