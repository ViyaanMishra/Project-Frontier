class_name InventorySlot
extends RefCounted

var item_id: String = ""
var quantity: int = 0
var quality: float = 1.0

func to_dict() -> Dictionary:
	return {
		"item_id": item_id,
		"quantity": quantity,
		"quality": quality
	}

func from_dict(d: Dictionary) -> void:
	item_id = d.get("item_id", "")
	quantity = d.get("quantity", 0)
	quality = d.get("quality", 1.0)
