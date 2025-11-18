extends Resource
class_name CardDatabase

@export var csv_path := "res://Data/CardList.csv"

var cards := {}  # Dictionary: id → Card

func _ready():
	load_cards()

func load_cards():
	var file = FileAccess.open(csv_path, FileAccess.READ)
	if not file:
		push_error("Failed to load card CSV at: " + csv_path)
		return

	var header := file.get_csv_line()  # skip header

	while not file.eof_reached():
		var row := file.get_csv_line()
		if row.size() < 7:
			continue

		var c := Card.new()
		c.id = int(row[0])
		c.card_name = row[1]
		c.card_type = row[2]
		c.value_min = int(row[3])
		c.value_max = int(row[4])
		c.effects = row[5].split(";") if row[5] != "" else []
		c.attached_items = row[6].split(";") if row[6] != "" else []

		cards[c.id] = c  # store by ID

	file.close()
	print("Loaded %d cards" % cards.size())

func get_card(id: int) -> Card:
	if not cards.has(id):
		return null
	return cards[id].duplicate()
