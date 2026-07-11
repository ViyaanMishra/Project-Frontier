class_name EconomyService
extends RefCounted

## Simulates supply/demand pricing and trading.

var prices: Dictionary = {}
var supply: Dictionary = {}
var demand: Dictionary = {}

func _init() -> void:
	reset()

func reset() -> void:
	for id in DataService.get_all_items().keys():
		prices[id] = 1.0
		supply[id] = 10.0
		demand[id] = 10.0

func get_price(item_id: String) -> float:
	return prices.get(item_id, 1.0)

func update_trade(item_id: String, bought: int, sold: int) -> void:
	demand[item_id] = maxf(0.0, demand[item_id] + bought)
	supply[item_id] = maxf(0.0, supply[item_id] + sold)
	_reprice(item_id)

func _reprice(item_id: String) -> void:
	var base: float = 1.0
	var ratio: float = demand[item_id] / maxf(1.0, supply[item_id])
	prices[item_id] = clampf(base * ratio, 0.1, 10.0)

func simulate_step(delta: float) -> void:
	for id in prices:
		demand[id] = maxf(0.0, demand[id] - 0.05 * delta)
		supply[id] = maxf(0.0, supply[id] - 0.02 * delta)
		_reprice(id)

func to_dict() -> Dictionary:
	return {
		"prices": prices,
		"supply": supply,
		"demand": demand
	}

func from_dict(d: Dictionary) -> void:
	prices = d.get("prices", {})
	supply = d.get("supply", {})
	demand = d.get("demand", {})
