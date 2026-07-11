class_name ItemDefinition
extends RefCounted

var id: String = ""
var display_name: String = ""
var description: String = ""
var weight: float = 0.1
var max_stack: int = 64
var category: String = "misc"
var tags: Array[String] = []
var equip_slot: String = ""
var durability: float = 100.0
var use_effects: Array[Dictionary] = []

func to_dict() -> Dictionary:
	return {
		"id": id,
		"display_name": display_name,
		"description": description,
		"weight": weight,
		"max_stack": max_stack,
		"category": category,
		"tags": tags,
		"equip_slot": equip_slot,
		"durability": durability,
		"use_effects": use_effects
	}

func from_dict(d: Dictionary) -> void:
	id = d.get("id", "")
	display_name = d.get("display_name", "")
	description = d.get("description", "")
	weight = d.get("weight", 0.1)
	max_stack = d.get("max_stack", 64)
	category = d.get("category", "misc")
	tags.assign(d.get("tags", []))
	equip_slot = d.get("equip_slot", "")
	durability = d.get("durability", 100.0)
	use_effects.assign(d.get("use_effects", []))
