extends Label

# Attach to a Label node in any scene (Board, Main Menu, etc.)

var _last_gold: int = -1

func _ready() -> void:
	PlayerWallet.init()

func _process(_delta: float) -> void:
	if PlayerWallet.gold != _last_gold:
		_last_gold = PlayerWallet.gold
		text = "Gold: %d" % PlayerWallet.gold
