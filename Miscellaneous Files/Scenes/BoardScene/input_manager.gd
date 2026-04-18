extends Node2D

signal left_mouse_button_clicked
signal left_mouse_button_released

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_DECK = 4

var card_manager_reference
var deck_reference

func _ready() -> void:
    card_manager_reference = $"../CardManager"
    deck_reference = $"../Deck"
    

func _input(event):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.is_pressed():
            emit_signal("left_mouse_button_clicked")
            raycast_at_cursor()
        else:
            emit_signal("left_mouse_button_released")

func raycast_at_cursor():
    var space_state = get_world_2d().direct_space_state
    var parameters = PhysicsPointQueryParameters2D.new()
    parameters.position = get_global_mouse_position()
    parameters.collide_with_areas = true
    var result= space_state.intersect_point(parameters)
    #print(result)
    if result.size() > 0:
        var card_found: Node = null
        #var deck_found: Node = null

        for hit in result:
            var mask = hit.collider.collision_mask
            if mask == COLLISION_MASK_CARD:
                # Prefer the card that’s visually on top
                var candidate = hit.collider.get_parent()
                if card_found == null or candidate.z_index > card_found.z_index:
                    card_found = candidate
            #elif mask == COLLISION_MASK_CARD_DECK:
                #deck_found = hit.collider.get_parent()
        if card_found and not $"../BattleManager".is_enemy_turn:
            #print("card clicked")
            card_manager_reference.start_drag(card_found)
        #elif deck_found:
            ##print("deck clicked")
            #deck_reference.draw_card()
            
