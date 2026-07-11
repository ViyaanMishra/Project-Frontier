# Game Design Document

## Genre and Setting

Project Frontier is a top-down real-time survival RPG set on a post-collapse sci-fi frontier. A 512×512 deterministic world is influenced from the run start by the Continuum Array, an ancient pre-collapse system that progressively destabilizes the world.

## Core Loops

1. **Survival** — gather resources, manage hunger, stamina, health, temperature, and equipment.
2. **Colony** — recruit settlers, assign priorities, build structures, and maintain morale.
3. **Production** — craft, farm, smelt, research, and trade.
4. **Exploration** — move across biomes, discover ruins, anomalies, and faction territories.
5. **Combat** — defend the colony from raiders, warlords, anomaly creatures, and the final threat.
6. **Meta** — limited legacy progression carries achievements, unlocks, and discovered technologies across seeded runs.

## World

- 512×512 tiles in 32×32 chunks.
- Six biomes: Safe Start, Wasteland, Forest, Desert, Mountain, Anomaly.
- Resource regions, settlements, enemy territories, ruins, anomaly zones, gated regions, landmarks, boss regions, and a final-threat region.
- Tiered simulation ensures distant chunks still progress at reduced fidelity.

## Survival Systems

- Health, stamina, hunger, temperature, equipment slots, death penalties, respawn.
- Player death preserves the colony; only critical colony failure ends the run.
- Tool-gated resources, quality variation, depletion, and regeneration.

## Colonists

- Utility AI chooses actions from: Need + Colony Priority + Relationship + Morale + Threat + Directive + Environment.
- Round-robin evaluation budget, forced reevaluation for emergencies.
- Memory: critical, relationship, event, and temporary records with decay, merge, and caps.
- Schedules, roles, zones, policies, production targets, and emergency directives.

## Factions

- Frontier Settlers, Industrial Recovery, Technology Preservationists, Raider/Warlord factions, and anomaly-influenced groups.
- Trade, quests, hostility, events, and beliefs progressively reveal the collapse.

## Research

Four tiers: Survival, Industrial Recovery, Advanced Recovery, Experimental Pre-Collapse.

## Continuum Array

A persistent global system from run start. It continuously affects anomalies, weather, faction behavior, economy, exploration hazards, ruins, and escalating events. The final encounter is the climax.

## Events

- Story, dynamic, NPC, and world quests.
- Weather, raids, shortages, disasters, morale shocks, disease, anomalies, and event chains.
- Disease affects work efficiency, morale, relationships, productivity, resource consumption, and research.

## UI

Functional main menu, settings, save/load, HUD, inventory, crafting, build, colony, research, quest, statistics, NPC, map, and debug interfaces.

## Modding

Base definitions are loaded from `res://data`; JSON mods from `user://mods/<id>/` with manifest validation, dependency checks, and schema validation.
