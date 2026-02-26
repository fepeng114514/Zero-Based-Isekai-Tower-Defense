class_name C

"""常量库:
	存储所有常量

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
#endregion

#region 日志级别
enum LOG_LEVEL {
	VERBOSE = 0,	# 详细信息
	DEBUG = 1,		# 调试信息
	INFO = 2,		# 普通信息
	WARN = 3,		# 警告
	ERROR = 4,		# 错误
}
#endregion


#region 数据文件路径
## 路径: 模板数据
const PATH_TEMPLATES_DATA: String = "templates.json"
## 路径: 组件数据
const PATH_COMPONENTS_DATA: String = "components.json"
## 路径: 动画数据
const PATH_ANIMATIONS_DATA: String = "animations.json"
## 路径: 关卡数据
const PATH_LEVEL_DATA: String = "levels/level_%s_data.json"
## 路径: 波次数据
const PATH_WAVE_DATA: String = "levels/level_%s_wave.json"
#endregion


#region 资源目录
## 目录: 资产
const DIR_ASSETS: String = "res://assets"
## 目录: 自动加载
const DIR_AUTOLOADS: String = "res://autoloads"
## 目录: 类
const DIR_CLASSES: String = "res://classes"
## 目录: 组件
const DIR_COMPONENTS: String = "res://components"
## 目录: 数据
const DIR_DATA: String = "res://data"
## 目录: 开发文档
const DIR_DOCS: String = "res://docs"
## 目录: 资源
const DIR_RESOURCES: String = "res://resources"
## 目录: 场景
const DIR_SCENES: String = "res://scenes"
## 目录: 脚本
const DIR_SCRIPTS: String = "res://scripts"
## 目录: 系统
const DIR_SYSTEMS: String = "res://systems"
## 目录: 资产图集
const DIR_ATLAS_ASSETS: String = DIR_ASSETS + "/atlas"
## 目录: 实体场景
const DIR_ENTITIES_SCENES: String = DIR_SCENES + "/entities"
## 目录: 关卡场景
const DIR_LEVELS_SCENES: String = DIR_SCENES + "/levels"
## 目录: 实体脚本
const DIR_ENTITIES_SCRIPTS: String = DIR_SCRIPTS + "/entities"
#endregion


#region 路径模板
## 路径模板: 关卡场景
const PATH_LEVELS_SCENES: String = DIR_LEVELS_SCENES + "/level_%s.tscn"
## 路径模板: 图集数据
const PATH_ATLAS_ASSETS_DATA: String = DIR_ATLAS_ASSETS + "/%s.json"
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
#endregion


#region 状态标志 (位运算)
## 状态: 无
const STATE_NONE: int = 0
## 状态: 空闲
const STATE_IDLE: int = 1
## 状态: 近战攻击
const STATE_MELEE: int = 1 << 1
## 状态: 远程攻击
const STATE_RANGED: int = 1 << 2
## 状态: 被阻塞
const STATE_BLOCK: int = 1 << 3
## 状态: 前往集结点
const STATE_RALLY: int = 1 << 4
#endregion


#region 伤害类型 (位运算)
## 伤害类型: 无
const DAMAGE_NONE: int = 0
## 伤害类型: 物伤
const DAMAGE_PHYSICAL: int = 1
## 伤害类型: 法伤
const DAMAGE_MAGICAL: int = 1 << 1
## 伤害类型: 炮伤
const DAMAGE_EXPLOSION: int = 1 << 2
## 伤害类型: 法炮伤
const DAMAGE_MAGICAL_EXPLOSION: int = 1 << 3
## 伤害类型: 真伤
const DAMAGE_TRUE: int = 1 << 4
## 伤害类型: 秒杀
const DAMAGE_DISINTEGRATE: int = 1 << 5
## 伤害类型: 毒伤
const DAMAGE_POISON: int = 1 << 6
## 伤害类型: 吃
const DAMAGE_EAT: int = 1 << 7
#endregion


#region 实体标志 (位运算)
## 标识: 无
const FLAG_NONE: int = 0
## 标识: 敌人
const FLAG_ENEMY: int = 1
## 标识: BOSS
const FLAG_BOSS: int = 1 << 1 | FLAG_ENEMY
## 标识: 友军
const FLAG_FRIENDLY: int = 1 << 2
## 标识: 英雄
const FLAG_HERO: int = 1 << 3 | FLAG_FRIENDLY
## 标识: 防御塔
const FLAG_TOWER: int = 1 << 4
## 标识: 子弹
const FLAG_BULLET: int = 1 << 5
## 标识: 状态效果
const FLAG_MODIFIER: int = 1 << 6
## 标识: 光环
const FLAG_AURA: int = 1 << 7
## 标识: 飞行
const FLAG_FLYING: int = 1 << 8
#endregion


#region 状态效果类型 (位运算)
## 状态效果类型: 无
const MOD_NONE: int = 0
## 状态效果类型: 毒
const MOD_POISON: int = 1
## 状态效果类型: 火
const MOD_LAVA: int = 1 << 1
## 状态效果类型: 流血
const MOD_BLEED: int = 1 << 2
## 状态效果类型: 冻结
const MOD_FREEZE: int = 1 << 3
## 状态效果类型: 眩晕
const MOD_STUN: int = 1 << 4
#endregion


#region 光环类型 (位运算)
## 光环类型: 无
const AURA_NONE: int = 0
## 光环类型: 正面效果
const AURA_BUFF: int = 1
## 光环类型: 负面效果
const AURA_DEBUFF: int = 1 << 1
#endregion


#region 轨迹类型 (位运算)
## 轨迹: 直线
const TRAJECTORY_LINEAR: int = 1
## 轨迹: 抛物线
const TRAJECTORY_PARABOLA: int = 1 << 1
## 轨迹: 跟踪
const TRAJECTORY_TRACKING: int = 1 << 2
## 轨迹: 瞬移
const TRAJECTORY_INSTANT: int = 1 << 3
#endregion


#region 组件名称 (StringName)
## 组件名称: 血量
const CN_HEALTH: StringName = &"health"
## 组件名称: 导航路径
const CN_NAV_PATH: StringName = &"nav_path"
## 组件名称: 集结点
const CN_RALLY: StringName = &"rally"
## 组件名称: 防御塔
const CN_TOWER: StringName = &"tower"
## 组件名称: 状态效果
const CN_MODIFIER: StringName = &"modifier"
## 组件名称: 光环
const CN_AURA: StringName = &"aura"
## 组件名称: 近战攻击
const CN_MELEE: StringName = &"melee"
## 组件名称: 远程攻击
const CN_RANGED: StringName = &"ranged"
## 组件名称: 子弹
const CN_BULLET: StringName = &"bullet"
## 组件名称: 精灵
const CN_SPRITE: StringName = &"sprite"
## 组件名称: 兵营
const CN_BARRACK: StringName = &"barrack"
## 组件名称: 生成器
const CN_SPAWNER: StringName = &"spawner"
## 组件名称: UI
const CN_UI: StringName = &"ui"
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


#region 搜索模式 (StringName)
## 搜索模式: 实体第一个
const SEARCH_ENTITY_FIRST: StringName = &"entity_first"
## 搜索模式: 实体最后一个
const SEARCH_ENTITY_LAST: StringName = &"entity_last"
## 搜索模式: 实体最近
const SEARCH_ENTITY_NEARST: StringName = &"entity_nearst"
## 搜索模式: 实体最远
const SEARCH_ENTITY_FARTHEST: StringName = &"entity_farthest"
## 搜索模式: 实体最强
const SEARCH_ENTITY_STRONGEST: StringName = &"entity_strongest"
## 搜索模式: 实体最弱
const SEARCH_ENTITY_WEAKEST: StringName = &"entity_weakest"
## 搜索模式: 实体最大 ID
const SEARCH_ENTITY_MAX_ID: StringName = &"entity_max_id"
## 搜索模式: 实体最小 ID
const SEARCH_ENTITY_MIN_ID: StringName = &"entity_min_id"

## 搜索模式: 敌人第一个
const SEARCH_ENEMY_FIRST: StringName = &"enemy_first"
## 搜索模式: 敌人最后一个
const SEARCH_ENEMY_LAST: StringName = &"enemy_last"
## 搜索模式: 敌人最近
const SEARCH_ENEMY_NEARST: StringName = &"enemy_nearst"
## 搜索模式: 敌人最远
const SEARCH_ENEMY_FARTHEST: StringName = &"enemy_farthest"
## 搜索模式: 敌人最强
const SEARCH_ENEMY_STRONGEST: StringName = &"enemy_strongest"
## 搜索模式: 敌人最弱
const SEARCH_ENEMY_WEAKEST: StringName = &"enemy_weakest"
## 搜索模式: 敌人最大 ID
const SEARCH_ENEMY_MAX_ID: StringName = &"enemy_max_id"
## 搜索模式: 敌人最小 ID
const SEARCH_ENEMY_MIN_ID: StringName = &"enemy_min_id"

## 搜索模式: 友军第一个
const SEARCH_FRIENDLY_FIRST: StringName = &"friendly_first"
## 搜索模式: 友军最后一个
const SEARCH_FRIENDLY_LAST: StringName = &"friendly_last"
## 搜索模式: 友军最近
const SEARCH_FRIENDLY_NEARST: StringName = &"friendly_nearst"
## 搜索模式: 友军最远
const SEARCH_FRIENDLY_FARTHEST: StringName = &"friendly_farthest"
## 搜索模式: 友军最强
const SEARCH_FRIENDLY_STRONGEST: StringName = &"friendly_strongest"
## 搜索模式: 友军最弱
const SEARCH_FRIENDLY_WEAKEST: StringName = &"friendly_weakest"
## 搜索模式: 友军最大 ID
const SEARCH_FRIENDLY_MAX_ID: StringName = &"friendly_max_id"
## 搜索模式: 友军最小 ID
const SEARCH_FRIENDLY_MIN_ID: StringName = &"friendly_min_id"
#endregion


#region 排序类型 (StringName)
## 排序类型: 路径路程
const SORT_PROGRESS: StringName = &"progress"
## 排序类型: 距离
const SORT_DISTANCE: StringName = &"distance"
## 排序类型: 血量
const SORT_HEALTH: StringName = &"health"
## 排序类型: 实体 ID
const SORT_ID: StringName = &"entity_id"
#endregion


#region 关卡相关常量
## 关卡列表
const LEVEL_LIST: Array[int] = [1]
## 关卡必需系统名称列表
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
## 关卡必需图集名称列表
const LEVEL_REQUIRED_ATLAS: Array[String] = [
	"common_enemies",
	"towers",
]
#endregion

#region 实体信息类型 (StringName)
const INFO_COMMON: StringName = &"common"
#endregion
