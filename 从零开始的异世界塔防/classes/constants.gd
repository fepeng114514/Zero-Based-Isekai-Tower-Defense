## 常量库，存储所有常量
class_name C

"""
	命名规范:
		1. 格式: 主标识_名称_副标识
		2. 字母全大写

		示例:
			## 资产图集目录
			const DIR_ATLAS_ASSETS: String = DIR_ASSETS + "/atlas"

			1. DIR 主标识，表示这是一个目录
			2. ATLAS 名称，图集
			3. ASSETS 副表示，表示是资产目录下的子目录
"""

#region 基础常量
## 帧率
const FPS: int = 60
const NAME_TOWER_HOLDER: String = "tower_holder_%s"
const UNSET: int = -1
#endregion

## 日志级别枚举
enum LOG_LEVEL {
	VERBOSE = 0,	# 详细信息
	DEBUG = 1,		# 调试信息
	INFO = 2,		# 普通信息
	WARN = 3,		# 警告
	ERROR = 4,		# 错误
}


#region 资源目录
## 目录: 资产
const DIR_ASSETS: String = "res://assets"
## 目录: 自动加载
const DIR_AUTOLOADS: String = "res://autoloads"
## 目录: 组件
const DIR_COMPONENTS: String = "res://components"
## 目录: 资源
const DIR_RESOURCES: String = "res://resources"
## 目录: 场景
const DIR_SCENES: String = "res://scenes"
## 目录: 脚本
const DIR_SCRIPTS: String = "res://scripts"
## 目录: 系统
const DIR_SYSTEMS: String = "res://systems"
## 目录: 图像图集资产
const DIR_IMAGE_ATLAS_ASSETS: String = DIR_ASSETS + "/image_atlas"
## 目录: 动画图集资产
const DIR_ANIMATED_ATLAS_ASSETS: String = DIR_ASSETS + "/animated_atlas"
## 目录: 实体场景
const DIR_ENTITIES_SCENES: String = DIR_SCENES + "/entities"
## 目录: 关卡场景
const DIR_LEVELS_SCENES: String = DIR_SCENES + "/levels"
## 目录: 实体脚本
const DIR_ENTITIES_SCRIPTS: String = DIR_SCRIPTS + "/entities"
## 目录: 图集纹理资源
const DIR_ATLAS_TEXTURE_RESOURCES: String = (
	DIR_RESOURCES + "/atlas_texture_resources"
)
## 目录: 图集的精灵帧资源
const DIR_SPRITE_FRAMES_RESOURCES: String = (
	DIR_RESOURCES + "/sprite_frames_resources"
)
#endregion


#region 路径模板
## 路径模板: 关卡场景
const PATH_LEVELS_SCENES: String = DIR_LEVELS_SCENES + "/level_%s.tscn"
## 路径模板: 图像图集数据
const PATH_IMAGE_ATLAS_ASSETS_DATA: String = (
	DIR_IMAGE_ATLAS_ASSETS + "/%s.json"
)
## 路径模板: 动画图集数据
const PATH_ANIMATE_ATLAS_ASSETS_DATA: String = (
	DIR_ANIMATED_ATLAS_ASSETS + "/%s.json"
)
## 路径模板: 场景
const PATH_SCENES: String = DIR_SCENES + "/%s.tscn"
## 路径模板: 实体场景
const PATH_ENTITIES_SCENES: String = DIR_ENTITIES_SCENES + "/%s.tscn"
## 路径模板: 系统
const PATH_SYSTEMS: String = DIR_SYSTEMS + "/%s.gd"
## 路径模板: 组件
const PATH_COMPONENTS: String = DIR_COMPONENTS + "/%s.gd"
## 路径模板: 实体脚本
const PATH_ENTITIES_SCRIPTS: String = DIR_ENTITIES_SCRIPTS + "/%s.gd"
## 路径模板: 图集纹理
const PATH_ATLAS_TEXTURE_RESOURCES: String = (
	DIR_ATLAS_TEXTURE_RESOURCES + "/%s.tres"
)
## 路径模板: 图集的精灵帧
const PATH_SPRITE_FRAMES_RESOURCES: String = (
	DIR_SPRITE_FRAMES_RESOURCES + "/%s.tres"
)
#endregion


## 状态标志枚举
enum STATE {
	## 状态: 空闲
	IDLE = 1,
	## 状态: 近战攻击
	MELEE = 1 << 1,
	## 状态: 远程攻击
	RANGED = 1 << 2,
	## 状态: 被阻塞
	BLOCK = 1 << 3,
	## 状态: 前往集结点
	RALLY = 1 << 4,
	## 状态: 生成
	SPAWN = 1 << 5,
}


## 伤害类型 (位运算) 枚举
enum DAMAGE {
	## 伤害类型: 无
	NONE = 0,
	## 伤害类型: 物伤
	PHYSICAL = 1,
	## 伤害类型: 法伤
	MAGICAL = 1 << 1,
	## 伤害类型: 炮伤
	EXPLOSION = 1 << 2,
	## 伤害类型: 法炮伤
	MAGICAL_EXPLOSION = 1 << 3,
	## 伤害类型: 真伤
	TRUE = 1 << 4,
	## 伤害类型: 秒杀
	DISINTEGRATE = 1 << 5,
	## 伤害类型: 毒伤
	POISON = 1 << 6,
	## 伤害类型: 吃
	EAT = 1 << 7,
}


## 实体标志 (位运算) 枚举
enum FLAG {
	# 标识: 无
	NONE = 0,
	# 标识: 敌人
	ENEMY = 1,
	# 标识: BOSS
	BOSS = 1 << 1 | ENEMY,
	# 标识: 友军
	FRIENDLY = 1 << 2,
	# 标识: 英雄
	HERO = 1 << 3 | FRIENDLY,
	# 标识: 防御塔
	TOWER = 1 << 4,
	# 标识: 子弹
	BULLET = 1 << 5,
	# 标识: 状态效果
	MODIFIER = 1 << 6,
	# 标识: 光环
	AURA = 1 << 7,
	# 标识: 飞行
	FLYING = 1 << 8,
}


## 状态效果类型 (位运算) 枚举
enum MOD {
	## 状态效果类型: 无
	NONE = 0,
	## 状态效果类型: 毒
	POISON = 1,
	## 状态效果类型: 火
	LAVA = 1 << 1,
	## 状态效果类型: 流血
	BLEED = 1 << 2,
	## 状态效果类型: 冻结
	FREEZE = 1 << 3,
	## 状态效果类型: 眩晕
	STUN = 1 << 4,
}


## 光环类型 (位运算) 枚举
enum AURA {
	## 光环类型: 无
	NONE = 0,
	## 光环类型: 正面效果
	BUFF = 1,
	## 光环类型: 负面效果
	DEBUFF = 1 << 1,
}


## 轨迹类型枚举
enum TRAJECTORY {
	## 轨迹: 直线
	LINEAR,
	## 轨迹: 抛物线
	PARABOLA,
	## 轨迹: 跟踪
	TRACKING,
	## 轨迹: 瞬移
	INSTANT,
}



## 搜索模式枚举
enum SEARCH {
	## 搜索模式: 实体第一个
	ENTITY_FIRST,
	## 搜索模式: 实体最后一个
	ENTITY_LAST,
	## 搜索模式: 实体最近
	ENTITY_NEARST,
	## 搜索模式: 实体最远
	ENTITY_FARTHEST,
	## 搜索模式: 实体最强
	ENTITY_STRONGEST,
	## 搜索模式: 实体最弱
	ENTITY_WEAKEST,
	## 搜索模式: 实体最大 ID
	ENTITY_MAX_ID,
	## 搜索模式: 实体最小 ID
	ENTITY_MIN_ID,

	## 搜索模式: 敌人第一个
	ENEMY_FIRST,
	## 搜索模式: 敌人最后一个
	ENEMY_LAST,
	## 搜索模式: 敌人最近
	ENEMY_NEARST,
	## 搜索模式: 敌人最远
	ENEMY_FARTHEST,
	## 搜索模式: 敌人最强
	ENEMY_STRONGEST,
	## 搜索模式: 敌人最弱
	ENEMY_WEAKEST,
	## 搜索模式: 敌人最大 ID
	ENEMY_MAX_ID,
	## 搜索模式: 敌人最小 ID
	ENEMY_MIN_ID,

	## 搜索模式: 友军第一个
	FRIENDLY_FIRST,
	## 搜索模式: 友军最后一个
	FRIENDLY_LAST,
	## 搜索模式: 友军最近
	FRIENDLY_NEARST,
	## 搜索模式: 友军最远
	FRIENDLY_FARTHEST,
	## 搜索模式: 友军最强
	FRIENDLY_STRONGEST,
	## 搜索模式: 友军最弱
	FRIENDLY_WEAKEST,
	## 搜索模式: 友军最大 ID
	FRIENDLY_MAX_ID,
	## 搜索模式: 友军最小 ID
	FRIENDLY_MIN_ID,
}


## 排序类型枚举
enum SORT {
	## 排序类型: 路径路程
	PROGRESS,
	## 排序类型: 距离
	DISTANCE,
	## 排序类型: 血量
	HEALTH,
	## 排序类型: 实体 ID
	ID,
}


#region 组件名称 (StringName)
## 组件名称: 血量
const CN_HEALTH: StringName = &"HealthComponent"
## 组件名称: 导航路径
const CN_NAV_PATH: StringName = &"NavPathComponent"
## 组件名称: 集结点
const CN_RALLY: StringName = &"RallyComponent"
## 组件名称: 防御塔
const CN_TOWER: StringName = &"TowerComponent"
## 组件名称: 状态效果
const CN_MODIFIER: StringName = &"ModifierComponent"
## 组件名称: 光环
const CN_AURA: StringName = &"AuraComponent"
## 组件名称: 近战攻击
const CN_MELEE: StringName = &"MeleeComponent"
## 组件名称: 远程攻击
const CN_RANGED: StringName = &"RangedComponent"
## 组件名称: 子弹
const CN_BULLET: StringName = &"BulletComponent"
## 组件名称: 精灵
const CN_SPRITE: StringName = &"SpriteComponent"
## 组件名称: 兵营
const CN_BARRACK: StringName = &"BarrackComponent"
## 组件名称: 生成器
const CN_SPAWNER: StringName = &"SpawnerComponent"
## 组件名称: UI
const CN_UI: StringName = &"UIComponent"
#endregion


#region 组名称 (StringName)
## 组名: 敌人
const GROUP_ENEMIES: StringName = &"enemies"
## 组名: 友军
const GROUP_FRIENDLYS: StringName = &"friendlys"
## 组名: 防御塔
const GROUP_TOWERS: StringName = &"towers"
## 组名: 状态效果
const GROUP_MODIFIERS: StringName = &"modifiers"
## 组名: 光环
const GROUP_AURAS: StringName = &"auras"
## 组名: 子弹
const GROUP_BULLETS: StringName = &"bullets"
#endregion


## 实体标签
enum ENTITY_TAG {
	WAVE_SPAWNER,  ## 波次生成器，负责生成敌人生成波次
	BULLET_ARROW,  ## 箭矢子弹
	BULLET_BOLT,
	BULLET_SWORD,
	SOLDIER,       ## 士兵
	TOWER_ARCHER,  ## 箭塔
	TOWER_MAGE,    ## 法师塔
	TOWER_BARRACK, ## 兵营
	TOWER_ENGINEER,## 炮塔
	ENEMY_GOBLIN,  ## 哥布林敌人，基础敌人单位
}


#region 关卡相关常量
## 关卡列表
const LEVEL_LIST: Array[int] = [1]
## 关卡必需系统名称列表
const LEVEL_REQUIRED_SYSTEMS: Array[String] = [
	"grouping_system",
	"time_system",
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
#endregion

## 实体信息类型枚举
enum INFO {
	UNIT,
	TOWER,
}
