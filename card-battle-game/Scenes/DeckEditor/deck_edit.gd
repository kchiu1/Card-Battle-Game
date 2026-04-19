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
		if Global.player_deck.size() == 9:
			get_tree().change_scene_to_file("res://main/Main Menu.tscn")
		else:
			print("Deck must have 9 cards!")
	)

func _refresh_available():
	var grid = $VBoxContainer/AvailablePanel/AvailableVBox/ScrollContainer/CardGrid
	for child in grid.get_children():
		child.queue_free()
	
	var is_deck_full = Global.player_deck.size() >= MAX_DECK
	
	var deck_counts = {}
	for id in Global.player_deck:
		var int_id = int(id)
		deck_counts[int_id] = deck_counts.get(int_id, 0) + 1

	for id in Global.player_inventory.keys():
		var total_owned = Global.player_inventory[id]
		var used_in_deck = deck_counts.get(int(id), 0)
		var remaining = total_owned - used_in_deck
		
		var card_data = card_db.cards[int(id)]
		var card_slot = _make_card_instance(card_data, false, remaining)
		
		if remaining <= 0 or is_deck_full:
			card_slot.modulate = Color(0.3, 0.3, 0.3, 1)
			card_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE 
			
		grid.add_child(card_slot)

func _refresh_deck():
	var grid = $VBoxContainer/DeckPanel/DeckVBox/ScrollContainer/DeckGrid
	for child in grid.get_children():
		child.queue_free()
	for card_id in Global.player_deck:
		var card_data = card_db.cards[int(card_id)]
		grid.add_child(_make_card_instance(card_data, true))
	$VBoxContainer/DeckPanel/DeckVBox/DeckLabel.text = "Deck: %d/9" % Global.player_deck.size()

func _add_to_deck(card_data: Dictionary):
	clear_clicks = 0
	if Global.player_deck.size() >= MAX_DECK:
		return
	Global.player_deck.append(int(card_data["id"]))
	_refresh_deck()
	_refresh_available()

func _remove_from_deck(card_data: Dictionary):
	clear_clicks = 0
	var id = int(card_data["id"])
	Global.player_deck.erase(id)
	_refresh_deck()
	_refresh_available()

var clear_clicks = 0

func _on_clear_button_pressed() -> void:
	clear_clicks += 1
	Global.player_deck.clear()
	
	if clear_clicks >= 10:
		# Unlock 99 copies of everything in the database
		for id in card_db.cards.keys():
			Global.player_inventory[int(id)] = 99
		print("Cheat Active: All cards unlocked")
		clear_clicks = 0 # reset
		
	_refresh_deck()
	_refresh_available()

func _make_card_instance(card_data: Dictionary, in_deck: bool, count: int = -1) -> Control:
	var wrapper = CardWrapper.new()
	wrapper.custom_minimum_size = WRAPPER_SIZE
	wrapper.mouse_filter = Control.MOUSE_FILTER_STOP

	var card = CardScene.instantiate()
	card.position = CARD_OFFSET
	
	if card.has_node("AnimationPlayer"):
		var ap = card.get_node("AnimationPlayer")
		ap.stop()
		ap.active = false


	var card_img = card.get_node("CardImage")
	card_img.show()
	card_img.modulate = Color(1, 1, 1, 1)
	card_img.scale = Vector2(0.65, 0.65)
	
	card_img.z_as_relative = false
	card_img.z_index = 10

	var bg_path = "res://Assets/" + card_data["type"] + ".png"
	if FileAccess.file_exists(bg_path):
		card_img.texture = load(bg_path)
	else:
		card_img.texture = load("res://Assets/Card.png")

	if card.has_node("WeaponSprite"):
		var ws = card.get_node("WeaponSprite")
		ws.show()
		ws.modulate = Color(1, 1, 1, 1)
		ws.z_as_relative = false
		ws.z_index = 11 
		ws.texture = load("res://Assets/Weapons/" + card_data["weapon"])

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

	if not in_deck and count != -1:
		var count_label = Label.new()
		count_label.text = "x" + str(count)
		count_label.add_theme_font_size_override("font_size", 18)
		count_label.add_theme_color_override("font_outline_color", Color.BLACK)
		count_label.add_theme_constant_override("outline_size", 6)
		
		count_label.position = Vector2(95, 155) 
		count_label.z_index = 20 # Ensure it is on top of everything
		wrapper.add_child(count_label)
		
		if count <= 0:
			wrapper.modulate = Color(0.3, 0.3, 0.3, 1)

	wrapper.add_child(card)
	
	wrapper.on_click = func():
		if in_deck: 
			_remove_from_deck(card_data)
		else: 
			if count > 0:
				_add_to_deck(card_data)
			else:
				print("No more copies of this card available!")

	return wrapper
