extends Node

var enemies: Dictionary = {}

func _ready():
	load_enemies()

func load_enemies():
	var file = FileAccess.open("res://data/EnemyInfo.csv", FileAccess.READ)
	if not file:
		print("Failed to open EnemInfo.csv")
		return
		
	var header = file.get_line().strip_edges().split(",")
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line == "": continue
		var data = line.split(",")
		if data.size() < header.size(): continue
		
		var enemy_data = {}
		var deck_slots = []
		for i in range(header.size()):
			var key = header[i]
			var value = data[i].strip_edges()
			if key.begins_with("slot_"):
				deck_slots.append(int(value))
			else:
				enemy_data[key] = value
				
		var id = int(enemy_data["id"])
		enemy_data["deck"] = deck_slots
		enemies[id] = enemy_data
		enemy_data["sprite_path"] = "res://Assets/Enemy/" + enemy_data["sprite_path"]
	file.close()

func get_enemy(enemy_id: int) -> Dictionary:
	if not enemies.has(enemy_id):
		print("Enemy not found: %d" % enemy_id)
		return {}
	return enemies[enemy_id]
