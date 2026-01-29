extends Node

const FPS: int = 40

const PATH_SETTING: String = "settings"
var PATH_TEMPLATES: String = PATH_SETTING.path_join("templates.json")
var PATH_ENEMY_TEMPLATES: String = PATH_SETTING.path_join("enemy_templates.json")
var PATH_TOWER_TEMPLATES: String = PATH_SETTING.path_join("tower_templates.json")
var PATH_HERO_TEMPLATES: String = PATH_SETTING.path_join("hero_templates.json")
var PATH_BOSS_TEMPLATES: String = PATH_SETTING.path_join("boss_templates.json")
var PATH_LEVELS_DATA: String = PATH_SETTING.path_join("levels/level_%s_data.json")
var PATH_WAVES_DATA: String = PATH_SETTING.path_join("waves/level_%s_wave.json")

const PATH_SCENES: String = "res://scenes"
var PATH_TEMPLATES_SCENES: String = PATH_SCENES.path_join("templates/%s.tscn")
var PATH_LEVELS_SCENES: String = PATH_SCENES.path_join("levels/level_%s_data.tscn")
var PATH_WAVES_SCENES: String = PATH_SCENES.path_join("waves/level_%s_wave.tscn")

const PATH_RESOURCES: String = "res://resources"

const PATH_ASSETS: String = "res://assets"
var PATH_ATLAS_ASSETS: String = PATH_ASSETS.path_join("atlas/%")

const STATE_IDLE: String = "idle"
const STATE_DEAD: String = "dead"
const STATE_BLOCK: String = "block"
const STATE_GO_NAV: String = "go_nav"
const STATE_MELEE: String = "melee"
const STATE_RANGED: String = "ranged"

const CN_HEALTH: String = "HealthComponent"
const CN_NAV_PATH: String = "NavPathComponent"
const CN_ENEMY: String = "EnemyComponent"
const CN_SOLDIER: String = "SoldierComponent"
const CN_TOWER: String = "TowerComponent"
const CN_MODIFIER: String = "ModifierComponent"
const CN_AURA: String = "AuraComponent"
const CN_MELEE: String = "MeleeComponent"
const CN_RANGED: String = "RangedComponent"
const CN_SPRITE: String = "SpriteComponent"

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
const FLAG_SOLDIER: int = 1 << 1
const FLAG_HERO: int = 1 << 2
const FLAG_TOWER: int = 1 << 3
const FLAG_BULLET: int = 1 << 4
const FLAG_MODIFIER: int = 1 << 5
const FLAG_AURA: int = 1 << 6
const FLAG_BOSS: int = 1 << 10

const MOD_TYPE_POISON: int = 1
const MOD_TYPE_LAVA: int = 1 << 1
const MOD_TYPE_BLEED: int = 1 << 2
const MOD_TYPE_FREEZE: int = 1 << 3
const MOD_TYPE_STUN: int = 1 << 4

const NAME_TOWER_HOLDER: String = "tower_holder_%s"

const SEARCH_MODE_FIRST: String = "first"
const SEARCH_MODE_LAST: String = "last"
const SEARCH_MODE_NEARST: String = "nearst"
const SEARCH_MODE_FARTHEST: String = "farthest"
const SEARCH_MODE_STRONGEST: String = "strongest"
const SEARCH_MODE_WEAKEST: String = "weakest"
