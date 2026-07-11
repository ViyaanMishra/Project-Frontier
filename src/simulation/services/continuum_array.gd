class_name ContinuumArray
extends RefCounted

## Persistent global system from run start. Drives final threat and anomalies.

var pressure: float = 0.0
var awakened: bool = false
var final_encounter_ready: bool = false

func update(delta: float, world: WorldService, events: EventService) -> void:
	pressure += delta * 0.0005
	if pressure > 0.2 and Determinism.randf() < 0.0001 * delta:
		events.trigger("anomaly_surge", {"pressure": pressure})
	if pressure > 0.5 and not awakened:
		awakened = true
		events.trigger("continuum_awakening", {"pressure": pressure})
	if pressure > 0.9 and not final_encounter_ready:
		final_encounter_ready = true
		events.trigger("final_threat", {"pressure": pressure})

func get_pressure() -> float:
	return pressure

func to_dict() -> Dictionary:
	return {
		"pressure": pressure,
		"awakened": awakened,
		"final_encounter_ready": final_encounter_ready
	}

func from_dict(d: Dictionary) -> void:
	pressure = d.get("pressure", 0.0)
	awakened = d.get("awakened", false)
	final_encounter_ready = d.get("final_encounter_ready", false)
