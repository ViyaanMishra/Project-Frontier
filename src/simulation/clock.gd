class_name SimulationClock
extends RefCounted

## Simulation clock with pause, time scale, and debug step.

var time: float = 0.0
var day: int = 0
var day_time: float = 0.0
var day_length: float = 1200.0
var time_scale: Constants.TimeScale = Constants.TimeScale.NORMAL
var paused: bool = false
var step_requested: bool = false

var _accumulated: float = 0.0

func advance(delta: float) -> float:
	if paused:
		if step_requested:
			step_requested = false
			return delta
		return 0.0
	var scaled: float = delta * float(time_scale)
	time += scaled
	_accumulated += scaled
	day_time += scaled
	while day_time >= day_length:
		day_time -= day_length
		day += 1
	return scaled

func request_step() -> void:
	step_requested = true

func set_time_scale(scale: Constants.TimeScale) -> void:
	time_scale = scale
	paused = (scale == Constants.TimeScale.PAUSED)

func get_time() -> float:
	return time

func get_day_time() -> float:
	return day_time

func get_day() -> int:
	return day

func to_dict() -> Dictionary:
	return {
		"time": time,
		"day": day,
		"day_time": day_time,
		"day_length": day_length,
		"time_scale": time_scale,
		"paused": paused
	}

func from_dict(d: Dictionary) -> void:
	time = d.get("time", 0.0)
	day = d.get("day", 0)
	day_time = d.get("day_time", 0.0)
	day_length = d.get("day_length", 1200.0)
	time_scale = d.get("time_scale", Constants.TimeScale.NORMAL)
	paused = d.get("paused", false)


