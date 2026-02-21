extends Node2D

const CARD_STACK_OFFSET = Vector2(0, 0)
const DEFAULT_CARD_MOVE_SPEED = 0.1
const DISCARD_SCALE = Vector2(1, 1)

var discard_pile = []

func move_to_discard(card, speed := DEFAULT_CARD_MOVE_SPEED):
    if card in discard_pile:
        return

    discard_pile.append(card)

    # Disable hand / slot state
    card.in_card_slot = false

    # Stack position
    var target_position = global_position + CARD_STACK_OFFSET * discard_pile.size()

    card.z_index = -discard_pile.size()
    card.scale = DISCARD_SCALE

    animate_card_to_position(card, target_position, speed)

func animate_card_to_position(card, new_position, speed):
    var tween = get_tree().create_tween()
    tween.tween_property(card, "global_position", new_position, speed)
