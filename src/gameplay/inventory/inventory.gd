class_name Inventory
extends RefCounted

## Item inventory with stack/weight rules and equipment slots.

var slots: Array[InventorySlot] = []
var max_slots: int = 32
var max_weight: float = 100.0
var current_weight: float = 0.0

func _init(p_max_slots: int = 32, p_max_weight: float = 100.0) -> void:
	max_slots = p_max_slots
	max_weight = p_max_weight

func add_item(item_id: String, quantity: int = 1, quality: float = 1.0) -> bool:
	var def: ItemDefinition = DataService.get_item(item_id)
	if def == null:
		return false
	var remaining: int = quantity
	for slot in slots:
		if slot.item_id == item_id and slot.quality == quality:
			var space: int = def.max_stack - slot.quantity
			if space > 0:
				var to_add: int = mini(space, remaining)
				slot.quantity += to_add
				remaining -= to_add
				_recalc_weight()
			if remaining <= 0:
				return true
	while remaining > 0:
		if slots.size() >= max_slots:
			return false
		var weight_per: float = def.weight * quality
		if current_weight + weight_per > max_weight + 0.001:
			return false
		var slot: InventorySlot = InventorySlot.new()
		slot.item_id = item_id
		slot.quality = quality
		slot.quantity = mini(remaining, def.max_stack)
		slots.append(slot)
		remaining -= slot.quantity
		_recalc_weight()
	return true

func remove_item(item_id: String, quantity: int = 1) -> bool:
	var needed: int = quantity
	var to_remove: Array[InventorySlot] = []
	for slot in slots:
		if slot.item_id == item_id:
			var take: int = mini(slot.quantity, needed)
			slot.quantity -= take
			needed -= take
			if slot.quantity <= 0:
				to_remove.append(slot)
			if needed <= 0:
				break
	for slot in to_remove:
		slots.erase(slot)
	_recalc_weight()
	return needed <= 0

func has_item(item_id: String, quantity: int = 1) -> bool:
	return count_item(item_id) >= quantity

func count_item(item_id: String) -> int:
	var total: int = 0
	for slot in slots:
		if slot.item_id == item_id:
			total += slot.quantity
	return total

func _recalc_weight() -> void:
	current_weight = 0.0
	for slot in slots:
		var def: ItemDefinition = DataService.get_item(slot.item_id)
		if def != null:
			current_weight += def.weight * slot.quantity * slot.quality

func to_dict() -> Dictionary:
	var arr: Array[Dictionary] = []
	for slot in slots:
		arr.append(slot.to_dict())
	return {
		"max_slots": max_slots,
		"max_weight": max_weight,
		"current_weight": current_weight,
		"slots": arr
	}

func from_dict(d: Dictionary) -> void:
	max_slots = d.get("max_slots", 32)
	max_weight = d.get("max_weight", 100.0)
	current_weight = d.get("current_weight", 0.0)
	slots.clear()
	for sd in d.get("slots", []):
		var slot: InventorySlot = InventorySlot.new()
		slot.from_dict(sd)
		slots.append(slot)
