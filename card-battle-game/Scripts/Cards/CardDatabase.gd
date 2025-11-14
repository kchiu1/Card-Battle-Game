extends Node2D
class_name CardDatabase

var cards := {}  # id → Card

# Your exact path:
@export var csv_path := "res://Data/CardList.csv"

func _ready():
	load_cards()


func load_cards():
	var file = FileAccess.open(csv_path, FileAccess.READ)
	if not file:
		push_error("Failed to load card CSV at: " + csv_path)
		return

	var header := file.get_csv_line() # skip the header row

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

		c.effects = parse_array_string(row[5])
		c.attached_items = parse_array_string(row[6])

		cards[c.id] = c

	file.close()
	print("Loaded %d cards" % cards.size())


func parse_array_string(s: String) -> Array:
	s = s.strip_edges()

	if s == "" or s == "[]":
		return []

	s = s.trim_prefix("[").trim_suffix("]")  # remove []
	var parts = s.split(",")
	var cleaned = []

	for p in parts:
		p = p.strip_edges()
		if p != "":
			cleaned.append(p)

	return cleaned


func get_card(id: int) -> Card:
	if not cards.has(id):
		return null

	# Duplicate so battle does not mutate the original reference
	return cards[id].duplicate()
