extends Node2D

const CARD_SCENE_PATH = "res://Common/Cards/EnemyCard.tscn"
const CARD_DRAW_SPEED = 0.3
const PLAYER_HAND_SIZE = 3

var player_deck = [1, 1, 1, 1, 2, 2, 2, 3, 4]
var discard = []
var card_database_reference
var card_scene = preload(CARD_SCENE_PATH)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    player_deck.shuffle()
    var CardDatabase = preload("res://Common/Cards/CardDatabase.gd")
    card_database_reference = CardDatabase.new()
    card_database_reference.load_cards()
    draw_card()


func draw_card():
    
    while($"../EnemyHand".player_hand.size() < PLAYER_HAND_SIZE):
        if(player_deck.is_empty()):
            discard.shuffle()
            player_deck.append_array(discard)
            discard.clear()
        
        var card_drawn = player_deck[0]
        discard.append(player_deck.pop_front())
        
        var new_card = card_scene.instantiate()
        var card_image_path = str("res://Assets/" + card_database_reference.cards[card_drawn]["card_name"] + "Card.png")
        new_card.get_node("CardImage").texture = load(card_image_path)
        new_card.get_node("ClashValue").text = str(card_database_reference.cards[card_drawn]["min"]) + "-" + str(card_database_reference.cards[card_drawn]["max"])
        new_card.get_node("Name").text = card_database_reference.cards[card_drawn]["card_name"]
        
        $"../CardManager".add_child(new_card)
        new_card.name = "Card"
        
        $"../EnemyHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
    
