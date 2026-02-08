class_name CS

const FPS: int = 60

const PATH_TEMPLATES: Array = [
	"templates.json",
	"enemy_templates.json",
	"tower_templates.json",
	#"hero_templates.json",
	#"boss_templates.json"
]
const PATH_COMPOTENTS: String = "components.json"
const PATH_LEVELS: String = "levels/level_%s_data.json"
const PATH_WAVES: String = "levels/level_%s_wave.json"

const PATH_SCRIPTS: String = "res://scripts"
const PATH_SYSTEMS_SCRIPTS: String = PATH_SCRIPTS + "/systems/%s.gd"
const PATH_COMPONENTS_SCRIPTS: String = PATH_SCRIPTS + "/components/%s.gd"
const PATH_ENTITIES_SCRIPTS: String = PATH_SCRIPTS + "/entities/%s.gd"

const PATH_SCENES: String = "res://scenes"
const PATH_TEMPLATES_SCENES: String = PATH_SCENES + "/templates/%s.tscn"
const PATH_LEVELS_SCENES: String = PATH_SCENES + "/levels/level_%s_data.tscn"
const PATH_WAVES_SCENES: String = PATH_SCENES + "/levels/level_%s_wave.tscn"

const PATH_RESOURCES: String = "res://resources"

const PATH_DATAS: String = "res://data"

const PATH_ASSETS: String = "res://assets"
const PATH_ATLAS_ASSETS: String = PATH_ASSETS + "/atlas/%"

const LEVEL_LIST: Array = [
	1
]

const STATE_IDLE: int = 1
const STATE_MELEE: int = 1 << 1
const STATE_RANGED: int = 1 << 2
const STATE_BLOCK: int = 1 << 3
const STATE_RALLY: int = 1 << 4

const CN_HEALTH: String = "health"
const CN_HEALTH_BAR: String = "health_bar"
const CN_NAV_PATH: String = "nav_path"
const CN_RALLY: String = "rally"
const CN_TOWER: String = "tower"
const CN_MODIFIER: String = "modifier"
const CN_AURA: String = "aura"
const CN_MELEE: String = "melee"
const CN_RANGED: String = "ranged"
const CN_BULLET: String = "bullet"
const CN_SPRITE: String = "sprite"
const CN_BARRACK: String = "barrack"
const CN_SPAWNER: String = "spawner"

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

const SEARCH_MODE_ENEMY_FIRST: String = "enemy_first"
const SEARCH_MODE_ENEMY_LAST: String = "enemy_last"
const SEARCH_MODE_ENEMY_NEARST: String = "enemy_nearst"
const SEARCH_MODE_ENEMY_FARTHEST: String = "enemy_farthest"
const SEARCH_MODE_ENEMY_STRONGEST: String = "enemy_strongest"
const SEARCH_MODE_ENEMY_WEAKEST: String = "enemy_weakest"
const SEARCH_MODE_FRIENDLY_FIRST: String = "friendly_first"
const SEARCH_MODE_FRIENDLY_LAST: String = "friendly_last"
const SEARCH_MODE_FRIENDLY_NEARST: String = "friendly_nearst"
const SEARCH_MODE_FRIENDLY_FARTHEST: String = "friendly_farthest"
const SEARCH_MODE_FRIENDLY_STRONGEST: String = "friendly_strongest"
const SEARCH_MODE_FRIENDLY_WEAKEST: String = "friendly_weakest"

const SORT_TYPE_PROGRESS: String = "progress"
const SORT_TYPE_DIST: String = "dist"
const SORT_TYPE_HP: String = "hp"

const GROUP_ENEMIES: String = "enemies"
const GROUP_FRIENDLYS: String = "friendlys"
const GROUP_TOWERS: String = "towers"
const GROUP_MODIFIERS: String = "modifiers"
const GROUP_AURAS: String = "auras"
const GROUP_BULLETS: String = "bullets"

const TRAJECTORY_LINEAR: int = 1
const TRAJECTORY_PARABOLA: int = 1 << 1
const TRAJECTORY_TRACKING: int = 1 << 2
const TRAJECTORY_HOMING: int = 1 << 3
const TRAJECTORY_INSTANT: int = 1 << 4
