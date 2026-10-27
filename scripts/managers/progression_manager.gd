class_name ProgressionManagerClass
extends Node

## Manages permanent meta-progression across runs
## Saves and loads from user://emberfall_progression.json

signal shards_changed(new_amount: int)
signal upgrade_purchased(upgrade_id: String, new_level: int)

const SAVE_PATH: String = "user://emberfall_progression.json"

var shards: int = 50 # Start with some initial shards for testing upgrades
var vitality_level: int = 0      # +20 Max HP per level (Base 100)
var damage_level: int = 0        # +15% Melee Damage per level
var burst_level: int = 0         # +25% Ember Burst Damage per level
var dash_recovery_level: int = 0 # -15% Dash Cooldown per level

const BASE_UPGRADE_COSTS: Dictionary = {
	"vitality": 20,
	"damage": 25,
	"burst": 30,
	"dash_recovery": 20
}

const MAX_UPGRADE_LEVELS: Dictionary = {
	"vitality": 5,
	"damage": 5,
	"burst": 5,
	"dash_recovery": 3
}

func _ready() -> void:
	load_progression()

func get_upgrade_level(upgrade_id: String) -> int:
	match upgrade_id:
		"vitality": return vitality_level
		"damage": return damage_level
		"burst": return burst_level
		"dash_recovery": return dash_recovery_level
	return 0

func get_upgrade_cost(upgrade_id: String) -> int:
	var level = get_upgrade_level(upgrade_id)
	var max_lvl = MAX_UPGRADE_LEVELS.get(upgrade_id, 5)
	if level >= max_lvl:
		return -1 # Maxed out
	var base_cost = BASE_UPGRADE_COSTS.get(upgrade_id, 20)
	return int(base_cost * (1.0 + level * 0.75))

func can_afford(upgrade_id: String) -> bool:
	var cost = get_upgrade_cost(upgrade_id)
	if cost < 0:
		return false
	return shards >= cost

func purchase_upgrade(upgrade_id: String) -> bool:
	if not can_afford(upgrade_id):
		return false
	var cost = get_upgrade_cost(upgrade_id)
	shards -= cost
	match upgrade_id:
		"vitality": vitality_level += 1
		"damage": damage_level += 1
		"burst": burst_level += 1
		"dash_recovery": dash_recovery_level += 1
		_: return false
	
	save_progression()
	shards_changed.emit(shards)
	upgrade_purchased.emit(upgrade_id, get_upgrade_level(upgrade_id))
	return true

func add_shards(amount: int) -> void:
	if amount > 0:
		shards += amount
		save_progression()
		shards_changed.emit(shards)

func get_max_hp_bonus() -> float:
	return float(vitality_level * 20.0)

func get_damage_multiplier() -> float:
	return 1.0 + (damage_level * 0.15)

func get_burst_multiplier() -> float:
	return 1.0 + (burst_level * 0.25)

func get_dash_cooldown_multiplier() -> float:
	return maxf(0.5, 1.0 - (dash_recovery_level * 0.15))

func save_progression() -> void:
	var data: Dictionary = {
		"shards": shards,
		"vitality_level": vitality_level,
		"damage_level": damage_level,
		"burst_level": burst_level,
		"dash_recovery_level": dash_recovery_level
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_str = JSON.stringify(data, "\t")
		file.store_string(json_str)
		file.close()

func load_progression() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_str = file.get_as_text()
		file.close()
		var json = JSON.new()
		var parse_result = json.parse(json_str)
		if parse_result == OK and json.data is Dictionary:
			var d: Dictionary = json.data
			shards = int(d.get("shards", shards))
			vitality_level = int(d.get("vitality_level", vitality_level))
			damage_level = int(d.get("damage_level", damage_level))
			burst_level = int(d.get("burst_level", burst_level))
			dash_recovery_level = int(d.get("dash_recovery_level", dash_recovery_level))
			shards_changed.emit(shards)

func reset_progression() -> void:
	shards = 0
	vitality_level = 0
	damage_level = 0
	burst_level = 0
	dash_recovery_level = 0
	save_progression()
	shards_changed.emit(shards)
