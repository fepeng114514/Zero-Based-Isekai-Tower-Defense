@tool
extends Resource
class_name SelectMenuButtonData
## 选择菜单项数据资源


## 项类型
@export var type: C.SelectMenuButtonType = C.SelectMenuButtonType.UPGRADE:
	set(value):
		type = value
		notify_property_list_changed()
## 升级为的实体场景名称
## 
## [annotation SelectMenuButtonData.type] 为 UPGRADE 时可用
@export var upgrade_to: String = ""
## 升级的技能索引
## 
## [annotation SelectMenuButtonData.type] 为 SKILL 时可用
@export var upgraded_skill: int = C.UNSET
## 购买的条目索引
##
## [annotation SelectMenuButtonData.type] 为 BUY 时可用
@export var buy_item: int = C.UNSET
## 图标
@export var icon: AtlasTexture = null
## 位置索引
@export var place: int = 0
## 标题
@export var title: String = ""
## 描述
@export var desc: String = ""
## 音效
@export var sfx: AudioData = null


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"upgrade_to":
			if type != C.SelectMenuButtonType.UPGRADE:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"upgraded_skill":
			if type != C.SelectMenuButtonType.SKILL:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"buy_item":
			if type != C.SelectMenuButtonType.BUY:
				property.usage = PROPERTY_USAGE_NO_EDITOR
	
