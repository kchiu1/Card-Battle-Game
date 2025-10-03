extends Node2D

const COLLISION_MASK_CARD = 1

var card_being_dragged
var screen_size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    screen_size=  get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if card_being_dragged:
        var mouse_pos = get_global_mouse_position()
        card_being_dragged.position = Vector2(
            clamp(mouse_pos.x, 30, screen_size.x-30), 
            clamp(mouse_pos.y, 47, screen_size.y-47))
        
func _input(event):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.is_pressed():
            var card = raycast_check_for_card()
            if card:
                card_being_dragged = card
        else:
            card_being_dragged = null

func raycast_check_for_card():
    var space_state = get_world_2d().direct_space_state
    var parameters = PhysicsPointQueryParameters2D.new()
    parameters.position = get_global_mouse_position()
    parameters.collide_with_areas = true
    parameters.collision_mask = COLLISION_MASK_CARD
    var result= space_state.intersect_point(parameters)
    if result.size() > 0:
        return result[0].collider.get_parent()
    return null
