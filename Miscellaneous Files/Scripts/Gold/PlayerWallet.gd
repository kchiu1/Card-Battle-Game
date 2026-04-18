extends RefCounted
class_name PlayerWallet

# Usage from any script:
#   PlayerWallet.init()          # call once in your first scene _ready()
#   PlayerWallet.add_gold(20)
#   PlayerWallet.spend_gold(15)  # returns false if broke
#   PlayerWallet.gold            # read current balance

const SAVE_PATH = "user://wallet.save"
const STARTING_GOLD = 50

static var gold: int = STARTING_GOLD
static var _loaded: bool = false

# ── Call once in your first scene's _ready() ────────────────────────
static func init() -> void:
	if not _loaded:
		load_wallet()
		_loaded = true

# ── Public API ──────────────────────────────────────────────────────

static func add_gold(amount: int) -> void:
	gold += amount
	save_wallet()

static func spend_gold(amount: int) -> bool:
	if amount > gold:
		return false
	gold -= amount
	save_wallet()
	return true

static func can_afford(amount: int) -> bool:
	return gold >= amount

# ── Persistence ─────────────────────────────────────────────────────

static func save_wallet() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(gold)
		file.close()

static func load_wallet() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		gold = STARTING_GOLD
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		gold = file.get_var()
		file.close()

static func reset_wallet() -> void:
	gold = STARTING_GOLD
	save_wallet()
