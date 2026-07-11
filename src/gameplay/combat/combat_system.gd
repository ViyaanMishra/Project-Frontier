class_name CombatSystem
extends RefCounted

## Melee/ranged combat, status effects, and damage resolution.

class DamageEvent:
	var source_id: String
	var target_id: String
	var damage: float
	var damage_type: String
	var status: Array[StatusEffect]

class StatusEffect:
	var id: String
	var duration: float
	var strength: float

func resolve_attack(source: EntityRecord, target: EntityRecord, weapon: Dictionary = {}) -> DamageEvent:
	var event: DamageEvent = DamageEvent.new()
	event.source_id = source.id
	event.target_id = target.id
	var base_damage: float = weapon.get("damage", 5.0)
	var multiplier: float = 1.0
	if source.equipment.has("main_hand"):
		var item_id: String = source.equipment.main_hand
		var item: ItemDefinition = DataService.get_item(item_id)
		if item != null:
			base_damage += 3.0
		multiplier = 1.0 + (source.stamina / 100.0) * 0.5
	event.damage = base_damage * multiplier
	event.damage_type = weapon.get("damage_type", "physical")
	return event

func apply_damage(event: DamageEvent, target: EntityRecord) -> void:
	if target.is_dead:
		return
	target.health -= event.damage
	if target.health <= 0.0:
		target.health = 0.0
		target.is_dead = true
		GameSession.events.publish("entity_died", [target.id, "combat"])

func heal(target: EntityRecord, amount: float) -> void:
	if target.is_dead:
		return
	target.health = minf(target.max_health, target.health + amount)

func update_status_effects(target: EntityRecord, delta: float) -> void:
	# Placeholder for status tick effects.
	pass
