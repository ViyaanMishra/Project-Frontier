class_name EntityRecord
extends Record

## Canonical record for any entity in the world.

enum Type { PLAYER, NPC, ENEMY, ANIMAL, ITEM_DROP, BUILDING, RESOURCE }

var type: Type = Type.NPC
var display_name: String = ""
var position: Vector2i = Vector2i.ZERO
var chunk_id: String = ""
var faction_id: String = ""
var health: float = 100.0
var max_health: float = 100.0
var stamina: float = 100.0
var hunger: float = 100.0
var temperature: float = 20.0
var equipment: Dictionary = {}
var inventory: Inventory = Inventory.new()
var memories: Array[MemoryRecord] = []
var current_task: Dictionary = {}
var is_demoted: bool = false
var is_dead: bool = false

func _init(p_id: String = "") -> void:
	super(p_id)

func to_dict() -> Dictionary:
	var d: Dictionary = super()
	d["type"] = type
	d["display_name"] = display_name
	d["position"] = { "x": position.x, "y": position.y }
	d["chunk_id"] = chunk_id
	d["faction_id"] = faction_id
	d["health"] = health
	d["max_health"] = max_health
	d["stamina"] = stamina
	d["hunger"] = hunger
	d["temperature"] = temperature
	d["equipment"] = equipment
	d["inventory"] = inventory.to_dict()
	d["memories"] = []
	for m in memories:
		d["memories"].append(m.to_dict())
	d["current_task"] = current_task
	d["is_demoted"] = is_demoted
	d["is_dead"] = is_dead
	return d

func from_dict(d: Dictionary) -> void:
	super(d)
	type = d.get("type", Type.NPC)
	display_name = d.get("display_name", "")
	position = Vector2i(d.position.x, d.position.y)
	chunk_id = d.get("chunk_id", "")
	faction_id = d.get("faction_id", "")
	health = d.get("health", 100.0)
	max_health = d.get("max_health", 100.0)
	stamina = d.get("stamina", 100.0)
	hunger = d.get("hunger", 100.0)
	temperature = d.get("temperature", 20.0)
	equipment = d.get("equipment", {})
	inventory = Inventory.new()
	inventory.from_dict(d.get("inventory", {}))
	memories.clear()
	for md in d.get("memories", []):
		var m: MemoryRecord = MemoryRecord.new()
		m.from_dict(md)
		memories.append(m)
	current_task = d.get("current_task", {})
	is_demoted = d.get("is_demoted", false)
	is_dead = d.get("is_dead", false)
