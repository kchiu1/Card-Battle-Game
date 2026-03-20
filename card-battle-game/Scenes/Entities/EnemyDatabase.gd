extends Node
var enemies: Dictionary = {}

func _ready():
	load_enemies()

func load_enemies():
	var file = FileAccess.open("res://data/EnemyInfo.csv", FileAccess.READ)
	if not file:
		print("Failed to open EnemyInfo.csv")
		return
		
	var header = file.get_line().strip_edges().split(",")
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line == "": continue
		
		var data = line.split(",")
		if data.size() < header.size(): continue
		
		var enemy_info = {}
		var deck_slots = []
		
		for i in range(header.size()):
			var key = header[i]
			var value = data[i].strip_edges()
			
			if key.begins_with("slot_"):
				deck_slots.append(int(value))
			else:
				enemy_info[key] = value
				
		var id = int(enemy_info["id"])
		enemy_info["deck"] = deck_slots
		enemies[id] = enemy_info
		
	file.close()

func create_enemy(enemy_id: int) -> Enemy:
	if not enemies.has(enemy_id):
		print("Enemy ID %d not found!" % enemy_id)
		return null
		
	var data = enemies[enemy_id]
	return Enemy.new(
		int(data["id"]),
		data["enemy_list"],
		data["deck"]
	)
