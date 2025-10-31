extends Node2D

const CARD_SCENE_PATH = "res://Common/Cards/TestCard.tscn"
const CARD_DRAW_SPEED = 0.5

var player_deck = ["Bot", "Bot", "Bot"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


func draw_card():
    
    var card_scene = preload(CARD_SCENE_PATH)
    
    var new_card = card_scene.instantiate()
    $"../CardManager".add_child(new_card)
    new_card.name = "Card"
    $"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
