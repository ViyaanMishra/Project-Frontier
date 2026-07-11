class_name Record
extends RefCounted

## Base class for versioned, dirty-tracked records.

var id: String
var version: int = 1
var revision: int = 0
var dirty: bool = true
var deleted: bool = false
var created_at: float = 0.0
var modified_at: float = 0.0

func _init(p_id: String = "") -> void:
	id = p_id
	created_at = Time.get_ticks_msec() / 1000.0
	modified_at = created_at

func mark_dirty() -> void:
	if not dirty:
		dirty = true
		revision += 1
		modified_at = Time.get_ticks_msec() / 1000.0

func clear_dirty() -> void:
	dirty = false

func mark_deleted() -> void:
	deleted = true
	mark_dirty()

func to_dict() -> Dictionary:
	return {
		"id": id,
		"version": version,
		"revision": revision,
		"dirty": dirty,
		"deleted": deleted,
		"created_at": created_at,
		"modified_at": modified_at
	}

func from_dict(d: Dictionary) -> void:
	id = d.get("id", "")
	version = d.get("version", 1)
	revision = d.get("revision", 0)
	dirty = d.get("dirty", true)
	deleted = d.get("deleted", false)
	created_at = d.get("created_at", 0.0)
	modified_at = d.get("modified_at", 0.0)
