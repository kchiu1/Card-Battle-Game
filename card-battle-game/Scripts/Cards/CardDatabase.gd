extends Node2D
class_name CardDatabase

var cards: Dictionary = {}

func _ready():
	var file = FileAccess.open("res://Data/CardList.csv", FileAccess.READ)
	if file:
		var header = file.get_line().strip_edges().split(",")
		while not file.eof_reached():
			var line = file.get_line().strip_edges()
			if line == "":
				continue
			var data = line.split(",")
			if data.size() < header.size():
				continue
			var card_data = {}
			for i in range(header.size()):
				card_data[header[i]] = data[i]
			var id = int(card_data["id"])
			cards[id] = card_data
		file.close()
	else:
		print("Failed to open CardList.csv")

func get_card(card_id: int) -> Card:
	if not cards.has(card_id):
		print("Card not found: %d" % card_id)
		return null

	var card = cards[card_id]
	#print card and stats
	#print("Loaded card: %s" % card["card_name"], " Min:", card["value_min"], " Max:", card["value_max"], " Type:", card["type"], " Effects:", card["effects"])

	return Card.new(
		card["card_name"],
		int(card["value_min"]),
		int(card["value_max"]),
		card["type"],
		card["effects"].split(";", false)
	)
