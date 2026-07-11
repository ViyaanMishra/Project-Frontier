class_name MemoryRecord
extends RefCounted

## Bounded memory record for NPCs.

enum Category { CRITICAL, RELATIONSHIP, EVENT, TEMPORARY }

var source_id: String = ""
var target_id: String = ""
var category: Category = Category.TEMPORARY
var tags: Array[String] = []
var valence: float = 0.0
var strength: float = 1.0
var created_at: float = 0.0
var relevance: float = 1.0
var decay_policy: float = 0.01

func _init() -> void:
	created_at = Time.get_ticks_msec() / 1000.0

func update(dt: float, current_time: float) -> void:
	var age: float = current_time - created_at
	relevance = maxf(0.0, relevance - decay_policy * dt - 0.001 * age)

func to_dict() -> Dictionary:
	return {
		"source_id": source_id,
		"target_id": target_id,
		"category": category,
		"tags": tags,
		"valence": valence,
		"strength": strength,
		"created_at": created_at,
		"relevance": relevance,
		"decay_policy": decay_policy
	}

func from_dict(d: Dictionary) -> void:
	source_id = d.get("source_id", "")
	target_id = d.get("target_id", "")
	category = d.get("category", Category.TEMPORARY)
	tags.assign(d.get("tags", []))
	valence = d.get("valence", 0.0)
	strength = d.get("strength", 1.0)
	created_at = d.get("created_at", 0.0)
	relevance = d.get("relevance", 1.0)
	decay_policy = d.get("decay_policy", 0.01)
