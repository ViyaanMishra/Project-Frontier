class_name EventService
extends RefCounted

## Delivers story, dynamic, NPC, and world events.

var active_events: Array[Dictionary] = []
var event_history: Array[Dictionary] = []
var _continuum_pressure: float = 0.0

func trigger(event_id: String, params: Dictionary = {}) -> void:
	var event: Dictionary = {
		"id": event_id,
		"time": Time.get_ticks_msec() / 1000.0,
		"params": params
	}
	active_events.append(event)
	event_history.append(event)

func close_event(event_id: String) -> void:
	for i in range(active_events.size() - 1, -1, -1):
		if active_events[i].id == event_id:
			active_events.remove_at(i)

func update(delta: float, world: WorldService, colony: ColonyService, factions: FactionService) -> void:
	_continuum_pressure += delta * 0.001
	if _continuum_pressure > 1.0:
		_continuum_pressure = 0.0
		trigger("continuum_pulse", {"pressure": _continuum_pressure})
	# Escalate raids based on time and pressure.
	if active_events.size() == 0 and Determinism.randf() < 0.0001 * delta:
		trigger("raid_warning", {"target": "colony"})

func get_continuum_pressure() -> float:
	return _continuum_pressure

func to_dict() -> Dictionary:
	return {
		"active_events": active_events,
		"event_history": event_history,
		"continuum_pressure": _continuum_pressure
	}

func from_dict(d: Dictionary) -> void:
	active_events = d.get("active_events", [])
	event_history = d.get("event_history", [])
	_continuum_pressure = d.get("continuum_pressure", 0.0)
