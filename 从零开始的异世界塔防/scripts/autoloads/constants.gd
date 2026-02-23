class_name C

const FPS: int = 60

const PATH_TEMPLATES: String = "templates.json"
const PATH_COMPOTENTS: String = "components.json"
const PATH_LEVELS: String = "levels/level_%s_data.json"
const PATH_WAVES: String = "levels/level_%s_wave.json"
const PATH_ANIMATIONS: String = "animations.json"

const PATH_SCRIPTS: String = "res://scripts"
const PATH_SYSTEMS_SCRIPTS: String = PATH_SCRIPTS + "/systems/%s.gd"
const PATH_COMPONENTS_SCRIPTS: String = PATH_SCRIPTS + "/components/%s.gd"
const PATH_ENTITIES_SCRIPTS: String = PATH_SCRIPTS + "/entities/%s.gd"

const PATH_SCENES: String = "res://scenes"
const PATH_TEMPLATES_SCENES: String = PATH_SCENES + "/templates/%s.tscn"
const PATH_LEVELS_SCENES: String = PATH_SCENES + "/levels/level_%s.tscn"

const PATH_RESOURCES: String = "res://resources"

const PATH_DATAS: String = "res://data"

const PATH_ASSETS: String = "res://assets"
const PATH_ATLAS_ASSETS: String = PATH_ASSETS + "/atlas/%s"

const LEVEL_LIST: Array = [
	1
]

const STATE_NONE: int = 0
const STATE_IDLE: int = 1
const STATE_MELEE: int = 1 << 1
const STATE_RANGED: int = 1 << 2
const STATE_BLOCK: int = 1 << 3
const STATE_RALLY: int = 1 << 4

const CN_HEALTH: StringName = &"health"
const CN_HEALTH_BAR: StringName = &"health_bar"
const CN_NAV_PATH: StringName = &"nav_path"
const CN_RALLY: StringName = &"rally"
const CN_TOWER: StringName = &"tower"
const CN_MODIFIER: StringName = &"modifier"
const CN_AURA: StringName = &"aura"
const CN_MELEE: StringName = &"melee"
const CN_RANGED: StringName = &"ranged"
const CN_BULLET: StringName = &"bullet"
const CN_SPRITE: StringName = &"sprite"
const CN_BARRACK: StringName = &"barrack"
const CN_SPAWNER: StringName = &"spawner"

const DAMAGE_NONE: int = 0
const DAMAGE_PHYSICAL: int = 1
const DAMAGE_MAGICAL: int = 1 << 1
const DAMAGE_EXPLOSION: int = 1 << 2
const DAMAGE_MAGICAL_EXPLOSION: int = 1 << 3
const DAMAGE_TRUE: int = 1 << 4
const DAMAGE_DISINTEGRATE: int = 1 << 5
const DAMAGE_POISON: int = 1 << 6
const DAMAGE_EAT: int = 1 << 7

const FLAG_NONE: int = 0
const FLAG_ENEMY: int = 1
const FLAG_BOSS: int = 1 << 1 | FLAG_ENEMY
const FLAG_FRIENDLY: int = 1 << 2
const FLAG_HERO: int = 1 << 3 | FLAG_FRIENDLY
const FLAG_TOWER: int = 1 << 4
const FLAG_BULLET: int = 1 << 5
const FLAG_MODIFIER: int = 1 << 6
const FLAG_AURA: int = 1 << 7
const FLAG_FLYING: int = 1 << 8

const MOD_TYPE_NONE: int = 0
const MOD_TYPE_POISON: int = 1
const MOD_TYPE_LAVA: int = 1 << 1
const MOD_TYPE_BLEED: int = 1 << 2
const MOD_TYPE_FREEZE: int = 1 << 3
const MOD_TYPE_STUN: int = 1 << 4

const AURA_TYPE_NONE: int = 0
const AURA_TYPE_BUFF: int = 1
const AURA_TYPE_DEBUFF: int = 1 << 1

const NAME_TOWER_HOLDER: String = "tower_holder_%s"

const SEARCH_MODE_ENEMY_FIRST: StringName = &"enemy_first"
const SEARCH_MODE_ENEMY_LAST: StringName = &"enemy_last"
const SEARCH_MODE_ENEMY_NEARST: StringName = &"enemy_nearst"
const SEARCH_MODE_ENEMY_FARTHEST: StringName = &"enemy_farthest"
const SEARCH_MODE_ENEMY_STRONGEST: StringName = &"enemy_strongest"
const SEARCH_MODE_ENEMY_WEAKEST: StringName = &"enemy_weakest"
const SEARCH_MODE_FRIENDLY_FIRST: StringName = &"friendly_first"
const SEARCH_MODE_FRIENDLY_LAST: StringName = &"friendly_last"
const SEARCH_MODE_FRIENDLY_NEARST: StringName = &"friendly_nearst"
const SEARCH_MODE_FRIENDLY_FARTHEST: StringName = &"friendly_farthest"
const SEARCH_MODE_FRIENDLY_STRONGEST: StringName = &"friendly_strongest"
const SEARCH_MODE_FRIENDLY_WEAKEST: StringName = &"friendly_weakest"

const SORT_TYPE_PROGRESS: StringName = &"progress"
const SORT_TYPE_DIST: StringName = &"dist"
const SORT_TYPE_HP: StringName = &"hp"

const GROUP_ENEMIES: StringName = &"enemies"
const GROUP_FRIENDLYS: StringName = &"friendlys"
const GROUP_TOWERS: StringName = &"towers"
const GROUP_MODIFIERS: StringName = &"modifiers"
const GROUP_AURAS: StringName = &"auras"
const GROUP_BULLETS: StringName = &"bullets"

const TRAJECTORY_LINEAR: int = 1
const TRAJECTORY_PARABOLA: int = 1 << 1
const TRAJECTORY_TRACKING: int = 1 << 2
const TRAJECTORY_HOMING: int = 1 << 3
const TRAJECTORY_INSTANT: int = 1 << 4

const LEVEL_REQUIRED_SYSTEMS: Array[String] = [
	"grouping_system",
	"time_system",
	"level_system",
	"spawner_system",
	"aura_system",
	"modifier_system",
	"bullet_system",
	"health_system",
	"melee_system",
	"sprite_system",
	"entity_system",
	"barrack_system",
	"rally_system",
	"nav_path_system",
	"ranged_system",
]

const LEVEL_REQUIRED_ATLAS: Array[String] = [
	"common_enemies",
	"towers"
]
