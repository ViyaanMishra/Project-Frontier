class_name Constants
extends RefCounted

const WORLD_SIZE: int = 512
const CHUNK_SIZE: int = 32
const CHUNK_COUNT: int = WORLD_SIZE / CHUNK_SIZE
const MAX_FPS: int = 60
const PHYSICS_TICKS: int = 60

const TIER_OFFLINE: int = 4
const TIER_DISTANT: int = 3
const TIER_PREPARING: int = 2
const TIER_ACTIVE: int = 1

const BIOMES: int = 6
const BIOME_SAFE_START: int = 0
const BIOME_WASTELAND: int = 1
const BIOME_FOREST: int = 2
const BIOME_DESERT: int = 3
const BIOME_MOUNTAIN: int = 4
const BIOME_ANOMALY: int = 5

const MAX_MEMORY_RECORDS: int = 64
const LONG_TERM_MEMORY_CAP: int = 24
const UTILITY_BUDGET_PER_TICK: int = 24

const SAVE_SLOTS: int = 5
const AUTOSAVE_SLOTS: int = 3

const VERSION_MAJOR: int = 0
const VERSION_MINOR: int = 1
const VERSION_PATCH: int = 0

enum TimeScale {
	PAUSED = 0,
	NORMAL = 1,
	DOUBLE = 2,
	QUADRUPLE = 4
}
