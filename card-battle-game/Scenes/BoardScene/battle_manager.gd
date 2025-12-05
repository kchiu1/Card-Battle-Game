extends Node

var battle_timer
var empty_monster_card_slots = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    battle_timer = $"../BattleTimer"
    battle_timer.one_shot = true
    battle_timer.wait_time = 1.0
    
    empty_monster_card_slots.append($"../CardSlots/Enemy Card Slot")
    empty_monster_card_slots.append($"../CardSlots/Enemy Card Slot2")
    empty_monster_card_slots.append($"../CardSlots/Enemy Card Slot3")


func _on_end_turn_pressed() -> void:
    opponent_turn()


func opponent_turn():
    $"../EndTurn".disabled = true
    $"../EndTurn".visible = false
    
    $"../OpponentDeck".draw_card()
    
    # wait 1 second
    battle_timer.start()
    await battle_timer.timeout
    
    # Check if there are open slots
    if empty_monster_card_slots.size() == 0:
        end_opponent_turn()
        return
        
    end_opponent_turn()

func end_opponent_turn():
    # reset player deck draw
    $"../EndTurn".disabled = false
    $"../EndTurn".visible = true
