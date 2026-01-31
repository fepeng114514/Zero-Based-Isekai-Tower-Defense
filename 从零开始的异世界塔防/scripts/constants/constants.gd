class_name CS

const PATH_TEMPLATES: Array = [
	#"templates.json",
	"enemy_templates.json",
	"tower_templates.json",
	#"hero_templates.json",
	#"boss_templates.json"
]
const PATH_COMPOTENTS: String = "components.json"
const PATH_LEVELS: String = "levels/level_%s_data.json"
const PATH_WAVES: String = "levels/level_%s_wave.json"

const PATH_SCENES: String = "res://scenes"
const PATH_TEMPLATES_SCENES: String = PATH_SCENES + "/templates/%s.tscn"
const PATH_LEVELS_SCENES: String = PATH_SCENES + "/levels/level_%s_data.tscn"
const PATH_WAVES_SCENES: String = PATH_SCENES + "/levels/level_%s_wave.tscn"

const PATH_RESOURCES: String = "res://resources"

const PATH_ASSETS: String = "res://assets"
const PATH_ATLAS_ASSETS: String = PATH_ASSETS + "/atlas/%"

const LEVEL_LIST: Array = [
	1
]

const STATE_IDLE: String = "idle"
const STATE_DEAD: String = "dead"
const STATE_BLOCK: String = "block"
const STATE_GO_NAV: String = "go_nav"
const STATE_MELEE: String = "melee"
const STATE_RANGED: String = "ranged"

const CN_HEALTH: String = "Health"
const CN_NAV_PATH: String = "NavPath"
const CN_ENEMY: String = "Enemy"
const CN_SOLDIER: String = "Soldier"
const CN_TOWER: String = "Tower"
const CN_MODIFIER: String = "Modifier"
const CN_AURA: String = "Aura"
const CN_MELEE: String = "Melee"
const CN_RANGED: String = "Ranged"
const CN_BULLET: String = "Bullet"
const CN_SPRITE: String = "Sprite"

const DAMAGE_PHYSICAL: int = 1
const DAMAGE_MAGICAL: int = 1 << 1
const DAMAGE_EXPLOSION: int = 1 << 2
const DAMAGE_MAGICAL_EXPLOSION: int = 1 << 3
const DAMAGE_TRUE: int = 1 << 4
const DAMAGE_DISINTEGRATE: int = 1 << 5
const DAMAGE_POISON: int = 1 << 6
const DAMAGE_EAT: int = 1 << 7

const DAMAGE_PHYSICAL_ARMOR: int = 1 << 15
const DAMAGE_MAGICAL_ARMOR: int = 1 << 16

const FLAG_ENEMY: int = 1
const FLAG_BOSS: int = 1 << 1 | FLAG_ENEMY
const FLAG_SOLDIER: int = 1 << 2
const FLAG_HERO: int = 1 << 3 | FLAG_SOLDIER
const FLAG_TOWER: int = 1 << 4
const FLAG_BULLET: int = 1 << 5
const FLAG_MODIFIER: int = 1 << 6
const FLAG_AURA: int = 1 << 7

const MOD_TYPE_POISON: int = 1
const MOD_TYPE_LAVA: int = 1 << 1
const MOD_TYPE_BLEED: int = 1 << 2
const MOD_TYPE_FREEZE: int = 1 << 3
const MOD_TYPE_STUN: int = 1 << 4

const NAME_TOWER_HOLDER: String = "tower_holder_%s"

const SEARCH_MODE_ENEMY_FIRST: String = "enemy_first"
const SEARCH_MODE_ENEMY_LAST: String = "enemy_last"
const SEARCH_MODE_ENEMY_NEARST: String = "enemy_nearst"
const SEARCH_MODE_ENEMY_FARTHEST: String = "enemy_farthest"
const SEARCH_MODE_ENEMY_STRONGEST: String = "enemy_strongest"
const SEARCH_MODE_ENEMY_WEAKEST: String = "enemy_weakest"
const SEARCH_MODE_SOLDIER_FIRST: String = "soldier_first"
const SEARCH_MODE_SOLDIER_LAST: String = "soldier_last"
const SEARCH_MODE_SOLDIER_NEARST: String = "soldier_nearst"
const SEARCH_MODE_SOLDIER_FARTHEST: String = "soldier_farthest"
const SEARCH_MODE_SOLDIER_STRONGEST: String = "soldier_strongest"
const SEARCH_MODE_SOLDIER_WEAKEST: String = "soldier_weakest"

const SORT_TYPE_PROGRESS: String = "progress"
const SORT_TYPE_DIST: String = "dist"
const SORT_TYPE_HP: String = "hp"
const SORT_TYPE_BLOCK_LEVEL: String = "block_level"
