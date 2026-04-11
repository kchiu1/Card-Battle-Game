extends Node2D

const CARD_SCENE_PATH = "res://Common/Cards/Card.tscn"
const CARD_DRAW_SPEED = 0.35
const STARTING_PLAYER_HAND_SIZE = 3
const MAX_HAND_SIZE = 7
const DECK_X = 360
const DECK_Y = 760

var player_deck = [1, 1, 1, 1, 2, 2, 2, 3, 4]
var deck_cards = []
var discard = []
var hand
var card_database_reference
var card_scene = preload(CARD_SCENE_PATH)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	discard = $"../Discard"
	hand = $"../PlayerHand"
	player_deck.shuffle()
	var CardDatabase = preload("res://Common/Cards/CardDatabase.gd")
	card_database_reference = CardDatabase.new()
	card_database_reference.load_cards()
		
	populate_deck(player_deck)
	
	while(hand.player_hand.size() < STARTING_PLAYER_HAND_SIZE):
		draw_card()

func populate_deck(deck_ids):
	if deck_cards.size() != 0:
		deck_cards.clear()
	for card_id in deck_ids:
		var new_card = card_scene.instantiate()
		var card_image_path = str("res://Assets/" + card_database_reference.cards[card_id]["card_name"] + "Card.png")
		new_card.get_node("CardImage").texture = load(card_image_path)
		new_card.get_node("WeaponSprite").texture = load("res://Assets/Weapons/" + card_database_reference.cards[card_id]["weapon"])
		if card_database_reference.cards[card_id]["min"] != card_database_reference.cards[card_id]["max"]:
			new_card.get_node("ClashValue").text = str(card_database_reference.cards[card_id]["min"]) + "-" + str(card_database_reference.cards[card_id]["max"])
		else:
			new_card.get_node("ClashValue").text =  "+" + str(card_database_reference.cards[card_id]["max"])
		new_card.get_node("Name").text = card_database_reference.cards[card_id]["card_name"]
		new_card.id = card_database_reference.cards[card_id]["id"]
		new_card.type = card_database_reference.cards[card_id]["type"]
		new_card.min = card_database_reference.cards[card_id]["min"]
		new_card.max = card_database_reference.cards[card_id]["max"]
		if not new_card.is_inside_tree():
			$"../CardManager".add_child(new_card)
			new_card.name = "Card_" + str(new_card.id)
		new_card.get_node("Area2D/CollisionShape2D").disabled = true
		
		deck_cards.append(new_card)
	
func add_card_to_deck(card, speed):
	var new_position = Vector2(DECK_X, DECK_Y)
	hand.animate_card_to_position(card, new_position, speed)

func draw_card():
	if hand.player_hand.size() < MAX_HAND_SIZE:
		if(deck_cards.is_empty()):
			var discard_size = discard.discard_pile.size()
			for i in discard_size:
				var card = discard.discard_pile.pop_back()
				card.z_index = 0
				deck_cards.append(card)
				card.get_node("AnimationPlayer").play("reshuffle")
				add_card_to_deck(card, CARD_DRAW_SPEED)
				await get_tree().create_timer(CARD_DRAW_SPEED/2).timeout
			deck_cards.shuffle()
			for i in deck_cards.size():
				deck_cards[i].z_index = -10 + i
			
		var card_drawn = deck_cards.pop_back()
		card_drawn.z_index = 0
			
		hand.add_card_to_hand(card_drawn, CARD_DRAW_SPEED)
		card_drawn.get_node("AnimationPlayer").play("card_flip")
		
		await card_drawn.get_node("AnimationPlayer").animation_finished
		card_drawn.get_node("Area2D/CollisionShape2D").disabled = false
	
