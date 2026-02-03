extends Resource

var level_required_system: Array[String] = [
	"LevelSystem",
	"ModifierSystem",
	"HealthSystem",
	"EntitySystem",
	"BarrackSystem",
	"RallySystem",
	"NavPathSystem",
	"MeleeSystem",
	"RangedSystem"
]

var required_systems: Dictionary = {
	"EntitySystem": EntitySystem,
	"BarrackSystem": BarrackSystem,
	"LevelSystem": LevelSystem,
	"HealthSystem": HealthSystem,
	"SpriteSystem": SpriteSystem,
	"NavPathSystem": NavPathSystem,
	"ModifierSystem": ModifierSystem,
	"RallySystem": RallySystem,
	"MeleeSystem": MeleeSystem,
	"RangedSystem": RangedSystem
}

var required_templates: Dictionary = {
	"enemy_goblin": preload(CS.PATH_TEMPLATES_SCENES % "enemy_goblin"),
	"tower_mage": preload(CS.PATH_TEMPLATES_SCENES % "tower_mage"),
	"bullet_bolt": preload(CS.PATH_TEMPLATES_SCENES % "bullet_bolt"),
	"tower_archer": preload(CS.PATH_TEMPLATES_SCENES % "tower_archer"),
	"bullet_arrow": preload(CS.PATH_TEMPLATES_SCENES % "bullet_arrow"),
	"bullet_bomb": preload(CS.PATH_TEMPLATES_SCENES % "bullet_bomb"),
	"bullet_sword": preload(CS.PATH_TEMPLATES_SCENES % "bullet_sword"),
	"damage": preload(CS.PATH_TEMPLATES_SCENES % "damage")
}

var required_components: Dictionary = {
	"UI": UIComponent,
	"Modifier": ModifierComponent,
	"Aura": AuraComponent,
	"Hero": HeroComponent, 
	"Tower": TowerComponent,
	"Melee": MeleeComponent, 
	"Ranged": RangedComponent,
	"Bullet": BulletComponent,
	"Health": HealthComponent,
	"Sprite": SpriteComponent,
	"NavPath": NavPathComponent,
	"Rally": RallyComponent,
	"Barrack": BarrackComponent
}
