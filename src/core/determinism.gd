extends Node

## Autoload that provides deterministic RNG and seed state.

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _seed: int = 0
var _state_stack: Array[int] = []

func _ready() -> void:
	_rng.seed = 0
	_rng.state = 0

func initialize(seed_value: int) -> void:
	_seed = seed_value
	_rng.seed = _seed
	_rng.state = 0

func get_seed() -> int:
	return _seed

func randi() -> int:
	return _rng.randi()

func randi_range(from: int, to: int) -> int:
	return _rng.randi_range(from, to)

func randf() -> float:
	return _rng.randf()

func randf_range(from: float, to: float) -> float:
	return _rng.randf_range(from, to)

func rand_weighted(weights: Array[float]) -> int:
	var total: float = 0.0
	for w in weights:
		total += w
	if total <= 0.0:
		return 0
	var roll: float = randf() * total
	var acc: float = 0.0
	for i in range(weights.size()):
		acc += weights[i]
		if roll <= acc:
			return i
	return weights.size() - 1

func push_state() -> void:
	_state_stack.append(_rng.state)

func pop_state() -> void:
	if _state_stack.size() > 0:
		_rng.state = _state_stack.pop_back()

func get_state() -> int:
	return _rng.state

func set_state(state: int) -> void:
	_rng.state = state

func get_rng() -> RandomNumberGenerator:
	return _rng
