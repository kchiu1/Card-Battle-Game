extends Node2D

const CardDB    = preload("res://Common/Cards/CardDatabase.gd")
const CardScene = preload("res://Common/Cards/Card.tscn")

const SHOP_SLOTS   : int = 4
const REFRESH_COST : int = 5

const BASE_PRICES : Dictionary = {
	"attack"  : 10,
	"defense" : 8,
	"util"    : 6,
}

const PRICE_OVERRIDES : Dictionary = {
	6:  18,
	10: 14,
	11: 14,
	12: 16,
	13: 50,
}

var card_db : CardDB
var shop_stock : Array = []

const CARD_SCALE := Vector2(0.9, 0.9)
const SLOT_W     : float = 180.0
const SLOT_H     : float = 320.0
const SLOT_GAP   : float = 24.0
const TOP_BAR_H  : float = 60.0

func _ready() -> void:
	card_db = CardDB.new()
	card_db.load_cards()
	build_ui()
	
	
	if Global.shop_stock.is_empty():
		roll_shop()
	refresh_ui()

func build_ui() -> void:
	var vp := get_viewport().get_visible_rect().size

	var gl : Label = $GoldLabel
	gl.position = Vector2(20, 16)
	gl.add_theme_font_size_override("font_size", 22)

	var back : Button = $BackButton
	back.position = Vector2(20, 50)
	back.custom_minimum_size = Vector2(160, 34)
	back.pressed.connect(on_back_pressed)

	var refresh : Button = $RefreshButton
	refresh.position = Vector2(20, 90)
	refresh.custom_minimum_size = Vector2(200, 34)
	refresh.pressed.connect(on_refresh_pressed)

	var total_w : float = SHOP_SLOTS * SLOT_W + (SHOP_SLOTS - 1) * SLOT_GAP
	var grid_x  : float = (vp.x - total_w) / 2.0
	var grid_y  : float = TOP_BAR_H + 60.0

	var grid : GridContainer = $ShopGrid
	grid.columns = SHOP_SLOTS
	grid.position = Vector2(grid_x, grid_y)
	grid.add_theme_constant_override("h_separation", int(SLOT_GAP))
	grid.add_theme_constant_override("v_separation", 16)
	

func roll_shop() -> void:
	Global.shop_stock.clear()
	var pool : Array = []
	for id in card_db.cards.keys():
		if id == 13 and Global.gold < 40:
			continue
		pool.append(id)
	pool.shuffle()
	var count = min(SHOP_SLOTS, pool.size())
	for i in range(count):
		var id    = pool[i]
		var cd    = card_db.cards[id]
		var price = price_for(id, cd["type"])
		Global.shop_stock.append({ "card_data": cd, "price": price, "sold": false })

func price_for(id: int, type: String) -> int:
	if PRICE_OVERRIDES.has(id):
		return PRICE_OVERRIDES[id]
	return BASE_PRICES.get(type, 10)

func refresh_ui() -> void:
	$GoldLabel.text = "Gold: %d g" % Global.gold
	populate_grid()

func populate_grid() -> void:
	var grid = $ShopGrid
	for child in grid.get_children():
		child.queue_free()
	for i in range(Global.shop_stock.size()):
		grid.add_child(make_slot(Global.shop_stock[i], i))

func make_slot(entry: Dictionary, index: int) -> Control:
	var cd    : Dictionary = entry["card_data"]
	var price : int        = entry["price"]
	var sold  : bool       = entry["sold"]

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(SLOT_W, SLOT_H)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	panel.add_child(vbox)
	
	var name_label := Label.new()
	name_label.text = cd["card_name"]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(name_label)
	
	var card_wrap := Control.new()
	card_wrap.custom_minimum_size = Vector2(SLOT_W, 200)
	card_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(card_wrap)

	var card_node = CardScene.instantiate()
	card_node.set_script(null)
	card_node.scale    = CARD_SCALE
	card_node.position = Vector2(SLOT_W / 2.0, 100)
	card_wrap.add_child(card_node)

	if card_node.has_node("CardBackImage"):
		card_node.get_node("CardBackImage").hide()

	if card_node.has_node("AnimationPlayer"):
		var ap = card_node.get_node("AnimationPlayer")
		ap.stop()
		ap.active = false

	var card_img = card_node.get_node("CardImage")
	card_img.show()
	card_img.modulate = Color(1, 1, 1, 1)
	var bg_path = "res://Assets/" + cd["type"] + ".png"
	if FileAccess.file_exists(bg_path):
		card_img.texture = load(bg_path)
	else:
		card_img.texture = load("res://Assets/Card.png")

	if card_node.has_node("WeaponSprite"):
		var ws = card_node.get_node("WeaponSprite")
		ws.show()
		ws.texture = load("res://Assets/Weapons/" + cd["weapon"])

	var n_lab = card_node.get_node("Name")
	n_lab.text = cd["card_name"]
	n_lab.show()

	var c_lab = card_node.get_node("ClashValue")
	c_lab.show()
	if cd["min"] != cd["max"]:
		c_lab.text = str(cd["min"]) + "-" + str(cd["max"])
	else:
		c_lab.text = "+" + str(cd["max"])

	var price_label := Label.new()
	price_label.text = "%d g" % price
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	price_label.add_theme_font_size_override("font_size", 20)
	price_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(price_label)

	var buy_btn := Button.new()
	buy_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if sold:
		buy_btn.text     = "Sold"
		buy_btn.disabled = true
	elif Global.gold < price:
		buy_btn.text     = "Can't Afford"
		buy_btn.disabled = true
	else:
		buy_btn.text = "Buy"
		buy_btn.pressed.connect(on_buy_pressed.bind(index))
	vbox.add_child(buy_btn)

	if sold:
		panel.modulate = Color(0.4, 0.4, 0.4, 1.0)

	return panel

func on_buy_pressed(index: int) -> void:
	var entry : Dictionary = Global.shop_stock[index]
	if entry["sold"]:
		return
	var price : int = entry["price"]
	if Global.gold < price:
		refresh_ui()
		return
	Global.gold -= price
	Global.gold_changed.emit()
	var card_id = int(entry["card_data"]["id"])
	Global.add_to_inventory(card_id)
	entry["sold"]     = true
	Global.shop_stock[index] = entry
	refresh_ui()
	print("Bought: %s for %d g — gold remaining: %d" % [entry["card_data"]["card_name"], price, Global.gold])

func on_refresh_pressed() -> void:
	if Global.gold < REFRESH_COST:
		_show_popup("Not enough gold! (Need %d g)" % REFRESH_COST)
		return
	Global.gold -= REFRESH_COST
	Global.gold_changed.emit()
	roll_shop()
	refresh_ui()

func _show_popup(message: String) -> void:
	var popup = AcceptDialog.new()
	popup.dialog_text = message
	popup.title = "Can't Refresh"
	add_child(popup)
	popup.popup_centered()
	popup.confirmed.connect(popup.queue_free)
	popup.canceled.connect(popup.queue_free)

func on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main/Main Menu.tscn")

func connect_card_signals(_card) -> void:
	pass
