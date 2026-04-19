extends Node2D

const MAX_DECK = 9
const CardDB = preload("res://Common/Cards/CardDatabase.gd")
const CardScene = preload("res://Common/Cards/Card.tscn")
const CardWrapper = preload("res://Scenes/DeckEditor/deck_card_wrapper.gd")

const WRAPPER_SIZE = Vector2(130, 185)
const CARD_OFFSET = Vector2(65, 92)

var card_db

func _ready():
	card_db = CardDB.new()
	card_db.load_cards()
	_refresh_available()
	_refresh_deck()
	$BackButton.pressed.connect(func():
		get_tree().change_scene_to_file("res://main/Main Menu.tscn")
	)


func _refresh_available():
	var grid = $VBoxContainer/AvailablePanel/AvailableVBox/ScrollContainer/CardGrid
	for child in grid.get_children():
		child.queue_free()
	for id in card_db.cards.keys():
		var card_data = card_db.cards[id]
		grid.add_child(_make_card_instance(card_data, false))

func _refresh_deck():
	var grid = $VBoxContainer/DeckPanel/DeckVBox/ScrollContainer/DeckGrid
	for child in grid.get_children():
		child.queue_free()
	for card_id in Global.player_deck:
		var card_data = card_db.cards[int(card_id)]
		grid.add_child(_make_card_instance(card_data, true))
	$VBoxContainer/DeckPanel/DeckVBox/DeckLabel.text = "Deck: %d/9" % Global.player_deck.size()

func _add_to_deck(card_data: Dictionary):
	if Global.player_deck.size() >= MAX_DECK:
		return
	Global.player_deck.append(int(card_data["id"]))
	_refresh_deck()

func _remove_from_deck(card_data: Dictionary):
	var id = int(card_data["id"])
	Global.player_deck.erase(id)
	_refresh_deck()



func _make_card_instance(card_data: Dictionary, in_deck: bool) -> Control:
	var wrapper = CardWrapper.new()
	wrapper.custom_minimum_size = WRAPPER_SIZE
	wrapper.mouse_filter = Control.MOUSE_FILTER_STOP

	var card = CardScene.instantiate()
	card.position = CARD_OFFSET
	
	# 1. COMPLETELY DISABLE THE ANIMATOR
	if card.has_node("AnimationPlayer"):
		var ap = card.get_node("AnimationPlayer")
		ap.stop()
		ap.active = false

	# 2. BACKGROUND FIX
	var card_img = card.get_node("CardImage")
	card_img.show()
	card_img.modulate = Color(1, 1, 1, 1)
	card_img.scale = Vector2(0.65, 0.65)
	
	# FORCE it to render on top of the UI layer
	card_img.z_as_relative = false
	card_img.z_index = 10 # Higher than the Deck Editor background

	var bg_path = "res://Assets/" + card_data["type"] + ".png"
	if FileAccess.file_exists(bg_path):
		card_img.texture = load(bg_path)
	else:
		card_img.texture = load("res://Assets/Card.png")

	# 3. WEAPON FIX (Set even higher than background)
	if card.has_node("WeaponSprite"):
		var ws = card.get_node("WeaponSprite")
		ws.show()
		ws.modulate = Color(1, 1, 1, 1)
		ws.z_as_relative = false
		ws.z_index = 11 
		ws.texture = load("res://Assets/Weapons/" + card_data["weapon"])

	# 4. TEXT FIX (Set highest)
	var n_lab = card.get_node("Name")
	n_lab.text = card_data["card_name"]
	n_lab.show()
	n_lab.modulate = Color(1, 1, 1, 1)
	n_lab.z_as_relative = false
	n_lab.z_index = 12
	
	var c_lab = card.get_node("ClashValue")
	c_lab.show()
	c_lab.modulate = Color(1, 1, 1, 1)
	c_lab.z_as_relative = false
	c_lab.z_index = 12
	
	if card_data["min"] != card_data["max"]:
		c_lab.text = str(card_data["min"]) + "-" + str(card_data["max"])
	else:
		c_lab.text = "+" + str(card_data["max"])

	wrapper.add_child(card)
	
	wrapper.on_click = func():
		if in_deck: _remove_from_deck(card_data)
		else: _add_to_deck(card_data)

	return wrapper
