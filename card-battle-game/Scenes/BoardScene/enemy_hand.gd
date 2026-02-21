extends Node2D

const CARD_WIDTH = 120
const DEFAULT_CARD_MOVE_SPEED = 0.1

var hand_y_position
var enemy_hand = []
var center_screen_x

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    center_screen_x = get_viewport_rect().size.x / 2
    hand_y_position = get_viewport_rect().size.y / 8
    
        
func add_card_to_hand(card, speed):
    if card not in enemy_hand:
        enemy_hand.insert(0, card)
        update_hand_positions(speed)
    else:
        animate_card_to_position(card, card.hand_position, DEFAULT_CARD_MOVE_SPEED)
    
func update_hand_positions(speed):
    for i in range(enemy_hand.size()):
        #Get new card pos based on index
        var new_position = Vector2(calculate_card_position(i), hand_y_position)
        var card = enemy_hand[i]
        card.hand_position = new_position
        animate_card_to_position(card, new_position, speed)
        
func calculate_card_position(index):
    var total_width = (enemy_hand.size() - 1) * CARD_WIDTH
    var x_offset = center_screen_x + total_width / 2 - index * CARD_WIDTH
    return x_offset
    
func animate_card_to_position(card, new_position, speed):
    var tween = get_tree().create_tween()
    tween.tween_property(card, "position", new_position, speed)

func remove_card_from_hand(card, speed):
    if card in enemy_hand:
        enemy_hand.erase(card)
        update_hand_positions(speed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
