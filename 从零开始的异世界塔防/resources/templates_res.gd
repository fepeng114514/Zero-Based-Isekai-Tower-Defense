extends Resource
class_name TemplatesRes

var templates: Dictionary = {
	"enemy_goblin": preload(CS.PATH_TEMPLATES_SCENES % "enemy_goblin"),
	"bullet_bolt": preload(CS.PATH_TEMPLATES_SCENES % "bullet_bolt"),
	"bullet_arrow": preload(CS.PATH_TEMPLATES_SCENES % "bullet_arrow"),
	"bullet_bomb": preload(CS.PATH_TEMPLATES_SCENES % "bullet_bomb"),
	"bullet_sword": preload(CS.PATH_TEMPLATES_SCENES % "bullet_sword"),
	"tower_mage": preload(CS.PATH_TEMPLATES_SCENES % "tower_mage"),
	"damage": preload(CS.PATH_TEMPLATES_SCENES % "damage")
}
