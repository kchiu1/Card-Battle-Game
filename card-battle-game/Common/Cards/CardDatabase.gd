

var cards: Dictionary = {}

func _ready():
    load_cards()

func load_cards():
    var file = FileAccess.open("res://data/CardList.csv", FileAccess.READ)
    if not file:
        print("Failed to open CardList.csv")
        return
        
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
            var key = header[i]
            var value = data[i].strip_edges()
            if value.begins_with("[") and value.ends_with("]"):
                var inner = value.substr(1, value.length() - 2)
                if inner == "":
                    card_data[key] = []
                else:
                    card_data[key] = inner.split(";", false)
            else:
                card_data[key] = value
                
        var id = int(card_data["id"])
        cards[id] = card_data
    print(cards)
    file.close()

func get_card(card_id: int) -> Card:
    if not cards.has(card_id):
        print("Card not found: %d" % card_id)
        return null

    var card = cards[card_id]
    return Card.new(
        card["card_name"],
        int(card["min"]),
        int(card["max"]),
        card["type"],
        card["effects"]
    )
