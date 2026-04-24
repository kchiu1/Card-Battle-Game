extends Node2D

const CardDB      = preload("res://Common/Cards/CardDatabase.gd")
const CardScene   = preload("res://Common/Cards/Card.tscn")

# How many card slots appear in the shop each visit
const SHOP_SLOTS    : int = 4
# Gold cost to re-roll the shop offerings
const REFRESH_COST  : int = 5

# Base prices per card type
const BASE_PRICES : Dictionary = {
	"attack"  : 10,
	"defense" : 8,
	"util"    : 6,
}

# Per-card price overrides keyed by card id
const PRICE_OVERRIDES : Dictionary = {
	6:  18,   # Gun       — strong attack range
	10: 14,   # M.Missile — defense penetration
	11: 14,   # M.Shield  — attack down effect
	12: 16,   # Fireball  — burn + def pen
	13: 50,   # Gun+      — legendary
}


var card_db : CardDB
# Array of Dictionaries — the cards currently for sale.  
var shop_stock : Array = []


func _ready() -> void:

	card_db = CardDB.new()
	card_db.load_cards()

	$BackButton.pressed.connect(_on_back_pressed)
	$RefreshButton.pressed.connect(_on_refresh_pressed)

	_roll_shop()
	_refresh_ui()


func _roll_shop() -> void:
	shop_stock.clear()

	# Build pool: all card ids
	var pool : Array = []
	for id in card_db.cards.keys():
		if id == 13 and Global.gold < 40:
			continue
		pool.append(id)
	pool.shuffle()

	var count = min(SHOP_SLOTS, pool.size())
	for i in range(count):
		var id       = pool[i]
		var cd       = card_db.cards[id]
		var price    = _price_for(id, cd["type"])
		shop_stock.append({ "card_data": cd, "price": price, "sold": false })

func _price_for(id: int, type: String) -> int:
	if PRICE_OVERRIDES.has(id):
		return PRICE_OVERRIDES[id]
	return BASE_PRICES.get(type, 10)



func _refresh_ui() -> void:
	_update_gold_label()
	_populate_grid()

func _update_gold_label() -> void:
	$GoldLabel.text = "Gold: %d g" % Global.gold

func _populate_grid() -> void:
	var grid = $ShopGrid
	# Clear existing slot nodes.
	for child in grid.get_children():
		child.queue_free()

	for i in range(shop_stock.size()):
		var entry = shop_stock[i]
		grid.add_child(_make_slot(entry, i))

func _make_slot(entry: Dictionary, index: int) -> Control:
	var cd    : Dictionary = entry["card_data"]
	var price : int        = entry["price"]
	var sold  : bool       = entry["sold"]

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(160, 260)

	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)

	# Card visual
	var card_node = CardScene.instantiate()
	card_node.set_script(null)
	card_node.position = Vector2(0, 0)
	card_node.scale    = Vector2(0.7, 0.7)

	if card_node.has_node("AnimationPlayer"):
		var ap = card_node.get_node("AnimationPlayer")
		ap.stop()
		ap.active = false

	var card_img = card_node.get_node("CardImage")
	card_img.show()
	card_img.modulate = Color(1, 1, 1, 1)
	card_img.scale    = Vector2(0.65, 0.65)
	card_img.z_as_relative = false
	card_img.z_index  = 10

	var bg_path = "res://Assets/" + cd["type"] + ".png"
	if FileAccess.file_exists(bg_path):
		card_img.texture = load(bg_path)
	else:
		card_img.texture = load("res://Assets/Card.png")

	if card_node.has_node("WeaponSprite"):
		var ws = card_node.get_node("WeaponSprite")
		ws.show()
		ws.texture = load("res://Assets/Weapons/" + cd["weapon"])
		ws.z_as_relative = false
		ws.z_index = 11

	var n_lab = card_node.get_node("Name")
	n_lab.text = cd["card_name"]
	n_lab.show()
	n_lab.z_as_relative = false
	n_lab.z_index = 12

	var c_lab = card_node.get_node("ClashValue")
	c_lab.show()
	c_lab.z_as_relative = false
	c_lab.z_index = 12
	if cd["min"] != cd["max"]:
		c_lab.text = str(cd["min"]) + "-" + str(cd["max"])
	else:
		c_lab.text = "+" + str(cd["max"])

	vbox.add_child(card_node)

	# Price
	var price_label = Label.new()
	price_label.text            = "%d g" % price
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	price_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(price_label)

	# Buy
	var buy_btn = Button.new()
	if sold:
		buy_btn.text     = "Sold"
		buy_btn.disabled = true
	elif not Global.gold >= price:
		buy_btn.text     = "Can't Afford"
		buy_btn.disabled = true
	else:
		buy_btn.text = "Buy"
		buy_btn.pressed.connect(_on_buy_pressed.bind(index))

	vbox.add_child(buy_btn)

	# Grey out if sold
	if sold:
		panel.modulate = Color(0.4, 0.4, 0.4, 1.0)

	return panel

# Button Callbacks

func _on_buy_pressed(index: int) -> void:
	var entry : Dictionary = shop_stock[index]
	if entry["sold"]:
		return

	var price : int = entry["price"]
	
	_update_gold_label()

	# Add card to player inventory
	var card_id = int(entry["card_data"]["id"])
	Global.add_to_inventory(card_id)

	entry["sold"] = true
	shop_stock[index] = entry

	_refresh_ui()
	print("Bought: %s for %d g — inventory: %s" % [
		entry["card_data"]["card_name"], price, str(Global.player_inventory)
	])

func _on_refresh_pressed() -> void:
	if not Global.gold < REFRESH_COST:
		print("Not enough gold to refresh shop (costs %d g)" % REFRESH_COST)
		return
	_roll_shop()
	_refresh_ui()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main/Main Menu.tscn")

func connect_card_signals(_card) -> void:
	pass
