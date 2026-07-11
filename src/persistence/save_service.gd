class_name SaveService
extends RefCounted

## Coordinates versioned, incremental saves.

signal save_completed(slot: int, success: bool)
signal load_completed(slot: int, success: bool)

var _manifest: Dictionary = {}
var _base_dir: String = "user://saves/"

func _init() -> void:
	_ensure_dirs()

func _ensure_dirs() -> void:
	var dir: DirAccess = DirAccess.open("user://")
	if dir != null:
		dir.make_dir_recursive("saves")

func save(slot: int, world: WorldService, colony: ColonyService, factions: FactionService, economy: EconomyService, events: EventService, player: EntityRecord, clock: SimulationClock, extra: Dictionary = {}) -> bool:
	var slot_dir: String = _base_dir + "slot_%d/" % slot
	var temp_dir: String = slot_dir + "temp/"
	DirAccess.make_dir_recursive_absolute(temp_dir)
	var manifest: Dictionary = {
		"version": Constants.VERSION_MAJOR,
		"subversion": Constants.VERSION_MINOR,
		"patch": Constants.VERSION_PATCH,
		"timestamp": Time.get_unix_time_from_system(),
		"seed": world._seed,
		"world_chunks": []
	}
	# Write dirty chunks.
	for id in world.chunks:
		var chunk: WorldChunk = world.chunks[id]
		if chunk.dirty or chunk.state == WorldChunk.TierState.ACTIVE:
			var path: String = temp_dir + "chunk_%s.json" % id.replace(",", "_")
			var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
			file.store_string(JSON.stringify(chunk.to_dict()))
			manifest.world_chunks.append(id)
	# Write colony/factions/economy/events.
	_write_record(temp_dir + "colony.json", colony)
	_write_record(temp_dir + "factions.json", factions)
	_write_record(temp_dir + "economy.json", economy)
	_write_record(temp_dir + "events.json", events)
	_write_record(temp_dir + "player.json", player)
	_write_record(temp_dir + "clock.json", clock)
	for key in extra:
		var record: RefCounted = extra[key]
		_write_record(temp_dir + key + ".json", record)
	# Write manifest.
	var manifest_file: FileAccess = FileAccess.open(temp_dir + "manifest.json", FileAccess.WRITE)
	manifest_file.store_string(JSON.stringify(manifest))
	# Atomic move.
	var target_dir: String = slot_dir + "data/"
	if DirAccess.dir_exists_absolute(target_dir):
		_remove_dir(target_dir)
	var err: Error = DirAccess.rename_absolute(temp_dir, target_dir)
	if err != OK:
		save_completed.emit(slot, false)
		return false
	_manifest = manifest
	for id in world.chunks:
		world.chunks[id].clear_dirty()
	colony.clear_dirty()
	factions.clear_dirty()
	player.clear_dirty()
	save_completed.emit(slot, true)
	return true

func _write_record(path: String, record: RefCounted) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	var text: String = JSON.stringify({})
	if record.has_method("to_dict"):
		text = JSON.stringify(record.to_dict())
	file.store_string(text)

func _remove_dir(path: String) -> void:
	var dir: DirAccess = DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var f: String = dir.get_next()
	while f != "":
		if not dir.current_is_dir():
			DirAccess.remove_absolute(path + "/" + f)
		f = dir.get_next()
	dir.list_dir_end()
	DirAccess.remove_absolute(path)

func load(slot: int) -> Dictionary:
	var slot_dir: String = _base_dir + "slot_%d/" % slot + "data/"
	if not DirAccess.dir_exists_absolute(slot_dir):
		load_completed.emit(slot, false)
		return {}
	var manifest_path: String = slot_dir + "manifest.json"
	var manifest: Dictionary = _load_json(manifest_path)
	var data: Dictionary = {"manifest": manifest}
	var chunks_arr: Array[Dictionary] = []
	for chunk_id in manifest.get("world_chunks", []):
		var path: String = slot_dir + "chunk_%s.json" % chunk_id.replace(",", "_")
		var chunk_data: Dictionary = _load_json(path)
		data["chunk_" + chunk_id.replace(",", "_")] = chunk_data
		chunks_arr.append(chunk_data)
	data["world"] = {"seed": manifest.get("seed", 0), "chunks": chunks_arr}
	data["colony"] = _load_json(slot_dir + "colony.json")
	data["factions"] = _load_json(slot_dir + "factions.json")
	data["economy"] = _load_json(slot_dir + "economy.json")
	data["events"] = _load_json(slot_dir + "events.json")
	data["player"] = _load_json(slot_dir + "player.json")
	data["clock"] = _load_json(slot_dir + "clock.json")
	# Load any extra records.
	var dir: DirAccess = DirAccess.open(slot_dir)
	if dir != null:
		dir.list_dir_begin()
		var f: String = dir.get_next()
		while f != "":
			if f.ends_with(".json") and f != "manifest.json" and not f.begins_with("chunk_"):
				var key: String = f.get_basename()
				if not data.has(key):
					data[key] = _load_json(slot_dir + f)
			f = dir.get_next()
		dir.list_dir_end()
	load_completed.emit(slot, true)
	return data

func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var text: String = file.get_as_text()
	var json: JSON = JSON.new()
	var err: Error = json.parse(text)
	if err != OK:
		return {}
	return json.data as Dictionary

func list_autosaves() -> Array[int]:
	return [1, 2, 3]

func list_manual_saves() -> Array[int]:
	return [1, 2, 3, 4, 5]
