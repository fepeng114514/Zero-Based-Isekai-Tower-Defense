extends Node

const PATH_SETTING: String = "settings"
var PATH_TEMPLATES: String = PATH_SETTING.path_join("templates.json")
var PATH_ENEMY_TEMPLATES: String = PATH_SETTING.path_join("enemy_templates.json")
var PATH_TOWER_TEMPLATES: String = PATH_SETTING.path_join("tower_templates.json")
var PATH_HERO_TEMPLATES: String = PATH_SETTING.path_join("hero_templates.json")
var PATH_BOSS_TEMPLATES: String = PATH_SETTING.path_join("boss_templates.json")

const STATE_IDLE: String = "idle"
const STATE_DEAD: String = "dead"
const STATE_BLOCK: String = "block"
const STATE_GO_NAV: String = "go_nav"
const STATE_MELEE: String = "melee"
const STATE_RANGED: String = "ranged"

const CN_HEALTH: String = "HealthComponen"
const CN_NAV_PATH: String = "NavPathComponent"
const CN_ENEMY: String = "EnemyComponent"
const CN_SOLDIER: String = "SoldierComponent"
const CN_TOWER: String = "TowerComponent"
const CN_MODIFIER: String = "ModifierComponent"
const CN_AURA: String = "AuraComponent"

const DAMAGE_PHYSICAL: int = 1
const DAMAGE_MAGICAL: int = 1 << 1
const DAMAGE_EXPLOSION: int = 1 << 2
const DAMAGE_TRUE: int = 1 << 3
const DAMAGE_DISINTEGRATE: int = 1 << 4
const DAMAGE_POISON: int = 1 << 5
const DAMAGE_EAT: int = 1 << 6

const DAMAGE_PHYSICAL_ARMOR: int = 1 << 15
const DAMAGE_MAGICAL_ARMOR: int = 1 << 16
