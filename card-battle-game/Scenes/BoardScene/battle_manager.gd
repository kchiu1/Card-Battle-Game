extends Node

const SMALL_CARD_SCALE = 1
const CARD_MOVE_SPEED = 0.2

var is_enemy_turn = false

var battle_timer
var enemy_card_slots = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    battle_timer = $"../BattleTimer"
    battle_timer.one_shot = true
    battle_timer.wait_time = 1.0
    
    enemy_card_slots.append($"../CardSlots/Enemy Card Slot")
    enemy_card_slots.append($"../CardSlots/Enemy Card Slot2")
    enemy_card_slots.append($"../CardSlots/Enemy Card Slot3")
    
    enemy_turn()


func _on_end_turn_pressed() -> void:
    #resolve function that calculates the roll, takes the higher one, and subtracts it from the player/enemy HP bar
    
    # wait 1 second
    battle_timer.start()
    await battle_timer.timeout
    
    enemy_turn()


func enemy_turn():
    is_enemy_turn = true
    $"../EndTurn".disabled = true
    $"../EndTurn".visible = false
    
    $"../EnemyDeck".draw_card()
    
    # wait 1 second
    battle_timer.start()
    await battle_timer.timeout
    
    # Play cards
    var starting_size = randi_range(1,enemy_card_slots.size())
    for i in range(starting_size):
        await play_cards()
    
    end_opponent_turn()
    
func play_cards():
    var enemy_hand = $"../EnemyHand".enemy_hand
    if enemy_hand.size() == 0:
        end_opponent_turn()
        return
    var random_enemy_card_slot = enemy_card_slots[randi_range(1, enemy_card_slots.size())-1]
    enemy_card_slots.erase(random_enemy_card_slot)
    
    var selected_card = enemy_hand[0]
    
    var tween = get_tree().create_tween()
    tween.tween_property(selected_card, "position", random_enemy_card_slot.position, CARD_MOVE_SPEED)
    var tween2 = get_tree().create_tween()
    tween2.tween_property(selected_card, "scale", Vector2(SMALL_CARD_SCALE, SMALL_CARD_SCALE), CARD_MOVE_SPEED)
    selected_card.get_node("AnimationPlayer").play("card_flip")
    $"../EnemyHand".remove_card_from_hand(selected_card, CARD_MOVE_SPEED)
        
    # wait 1 second
    battle_timer.start()
    await battle_timer.timeout
    
func end_opponent_turn():
    # reset player deck draw
    $"../Deck".draw_card()
    is_enemy_turn = false
    $"../EndTurn".disabled = false
    $"../EndTurn".visible = true
