class_name FactionService
extends Record

## Tracks factions and their relationships.

class FactionData:
	var id: String
	var name: String
	var hostility: float = 0.0
	var trust: float = 0.0
	var beliefs: Array[String] = []
	var territory: Array[String] = []

	func _init(p_id: String, p_name: String):
		id = p_id
		name = p_name

	func to_dict() -> Dictionary:
		return {
			"id": id,
			"name": name,
			"hostility": hostility,
			"trust": trust,
			"beliefs": beliefs,
			"territory": territory
		}

	func from_dict(d: Dictionary) -> void:
		id = d.get("id", "")
		name = d.get("name", "")
		hostility = d.get("hostility", 0.0)
		trust = d.get("trust", 0.0)
		beliefs.assign(d.get("beliefs", []))
		territory.assign(d.get("territory", []))

var factions: Dictionary = {}

func _init(p_id: String = "factions") -> void:
	super(p_id)
	_create_default_factions()

func _create_default_factions() -> void:
	_register("frontier_settlers", "Frontier Settlers")
	_register("industrial_recovery", "Industrial Recovery")
	_register("tech_preservationists", "Technology Preservationists")
	_register("raiders", "Raider Warlords")
	_register("anomaly_cult", "Anomaly-Influenced")

func _register(id: String, name: String) -> void:
	var f: FactionData = FactionData.new(id, name)
	factions[id] = f

func get_faction(id: String) -> FactionData:
	return factions.get(id, null)

func set_relation(id: String, hostility: float, trust: float) -> void:
	var f: FactionData = get_faction(id)
	if f == null:
		return
	f.hostility = hostility
	f.trust = trust
	mark_dirty()

func to_dict() -> Dictionary:
	var d: Dictionary = super()
	var arr: Array[Dictionary] = []
	for id in factions:
		arr.append(factions[id].to_dict())
	d["factions"] = arr
	return d

func from_dict(d: Dictionary) -> void:
	super(d)
	factions.clear()
	for fd in d.get("factions", []):
		var f: FactionData = FactionData.new("", "")
		f.from_dict(fd)
		factions[f.id] = f
