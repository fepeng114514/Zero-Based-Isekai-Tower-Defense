class_name C
## 常量库


#region 基础常量
## 帧率
const FPS: int = 60
## 未设置数字
const UNSET: int = -1
## PI 二分之一
const HALF_PI: float = PI / 2
## PI 四分之一
const QUARTER_PI: float = PI / 4
#endregion


## 日志级别枚举
enum LogLevels {
	VERBOSE = 0,	# 详细信息
	DEBUG = 1,		# 调试信息
	INFO = 2,		# 普通信息
	WARN = 3,		# 警告
	ERROR = 4,		# 错误
}


## 伤害类型 (位运算) 枚举
enum DamageType {
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
	## 伤害类型：所有
	ALL = 1 << 40 - 1
}


## 伤害标识
enum DamageFlag {
	## 伤害标识：无
	NONE = 0,
	## 伤害标识：不杀死目标而是留 1 血
	NOT_KILL = 1,
	## 伤害标识：杀死目标后直接移除
	KILL_REMOVE = 1 << 1,
	## 伤害标识：无法闪避
	NO_DODGE = 1 << 2,
	## 伤害标识：无法反伤
	NO_SPIKED = 1 << 3,
}


## 实体标志 (位运算) 枚举
enum Flag {
	# 标识: 无
	NONE = 0,
	# 标识: 敌人
	ENEMY = 1,
	# 标识: BOSS
	BOSS = 1 << 1,
	# 标识: 友军
	FRIENDLY = 1 << 2,
	# 标识: 单位
	UNIT = ENEMY | FRIENDLY,
	# 标识: 英雄
	HERO = 1 << 3,
	# 标识: 防御塔
	TOWER = 1 << 4,
	# 标识: 状态效果
	MODIFIER = 1 << 5,
	# 标识: 光环
	AURA = 1 << 6,
	# 标识: 飞行
	FLYING = 1 << 7,
}


## 状态效果类型 (位运算) 枚举
enum ModType {
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
enum AuraType {
	## 光环类型: 无
	NONE = 0,
	## 光环类型: 正面效果
	BUFF = 1,
	## 光环类型: 负面效果
	DEBUFF = 1 << 1,
}


## 轨迹类型枚举
enum Trajectory {
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
enum SearchMode {
	## 搜索模式: 实体路程最远
	ENTITY_MAX_PROGRESS,
	## 搜索模式: 实体路程最近
	ENTITY_MIN_PROGRESS,
	## 搜索模式: 实体距离最远
	ENTITY_MAX_DISTANCE,
	## 搜索模式: 实体距离最近
	ENTITY_MIN_DISTANCE,
	## 搜索模式: 实体血量最高
	ENTITY_MAX_HEALTH,
	## 搜索模式: 实体血量最低
	ENTITY_MIN_HEALTH,
	## 搜索模式: 实体近战伤害最高
	ENTITY_MAX_MELEE_DAMAGE,
	## 搜索模式: 实体近战伤害最低
	ENTITY_MIN_MELEE_DAMAGE,
	## 搜索模式: 实体远程伤害最高
	ENTITY_MAX_RANGE_DAMAGE,
	## 搜索模式: 实体远程伤害最低
	ENTITY_MIN_RANGE_DAMAGE,
	## 搜索模式: 实体 ID 最大
	ENTITY_MAX_ID,
	## 搜索模式: 实体 ID 最小
	ENTITY_MIN_ID,
	## 搜索模式: 实体赏金最高
	ENTITY_MAX_GOLD,
	## 搜索模式: 实体赏金最低
	ENTITY_MIN_GOLD,

	## 搜索模式: 敌人路程最远
	ENEMY_MAX_PROGRESS,
	## 搜索模式: 敌人路程最近
	ENEMY_MIN_PROGRESS,
	## 搜索模式: 敌人距离最远
	ENEMY_MAX_DISTANCE,
	## 搜索模式: 敌人距离最近
	ENEMY_MIN_DISTANCE,
	## 搜索模式: 敌人血量最高
	ENEMY_MAX_HEALTH,
	## 搜索模式: 敌人血量最低
	ENEMY_MIN_HEALTH,
	## 搜索模式: 敌人近战伤害最高
	ENEMY_MAX_MELEE_DAMAGE,
	## 搜索模式: 敌人近战伤害最低
	ENEMY_MIN_MELEE_DAMAGE,
	## 搜索模式: 敌人远程伤害最高
	ENEMY_MAX_RANGE_DAMAGE,
	## 搜索模式: 敌人远程伤害最低
	ENEMY_MIN_RANGE_DAMAGE,
	## 搜索模式: 敌人 ID 最大
	ENEMY_MAX_ID,
	## 搜索模式: 敌人 ID 最小
	ENEMY_MIN_ID,
	## 搜索模式: 敌人赏金最高
	ENEMY_MAX_GOLD,
	## 搜索模式: 敌人赏金最低
	ENEMY_MIN_GOLD,

	## 搜索模式: 友军路程最远
	FRIENDLY_MAX_PROGRESS,
	## 搜索模式: 友军路程最近
	FRIENDLY_MIN_PROGRESS,
	## 搜索模式: 友军距离最近
	FRIENDLY_MIN_DISTANCE,
	## 搜索模式: 友军距离最远
	FRIENDLY_MAX_DISTANCE,
	## 搜索模式: 友军血量最高
	FRIENDLY_MAX_HEALTH,
	## 搜索模式: 友军血量最低
	FRIENDLY_MIN_HEALTH,
	## 搜索模式: 友军近战伤害最高
	FRIENDLY_MAX_MELEE_DAMAGE,
	## 搜索模式: 友军近战伤害最低
	FRIENDLY_MIN_MELEE_DAMAGE,
	## 搜索模式: 友军远程伤害最高
	FRIENDLY_MAX_RANGE_DAMAGE,
	## 搜索模式: 友军远程伤害最低
	FRIENDLY_MIN_RANGE_DAMAGE,
	## 搜索模式: 友军 ID 最大
	FRIENDLY_MAX_ID,
	## 搜索模式: 友军 ID 最小
	FRIENDLY_MIN_ID,
	## 搜索模式: 友军赏金最高
	FRIENDLY_MAX_GOLD,
	## 搜索模式: 友军赏金最低
	FRIENDLY_MIN_GOLD,

	## 搜索模式: 单位路程最远
	UNIT_MAX_PROGRESS,
	## 搜索模式: 单位路程最近
	UNIT_MIN_PROGRESS,
	## 搜索模式: 单位距离最近
	UNIT_MIN_DISTANCE,
	## 搜索模式: 单位距离最远
	UNIT_MAX_DISTANCE,
	## 搜索模式: 单位血量最高
	UNIT_MAX_HEALTH,
	## 搜索模式: 单位血量最低
	UNIT_MIN_HEALTH,
	## 搜索模式: 单位近战伤害最高
	UNIT_MAX_MELEE_DAMAGE,
	## 搜索模式: 单位近战伤害最低
	UNIT_MIN_MELEE_DAMAGE,
	## 搜索模式: 单位远程伤害最高
	UNIT_MAX_RANGE_DAMAGE,
	## 搜索模式: 单位远程伤害最低
	UNIT_MIN_RANGE_DAMAGE,
	## 搜索模式: 单位 ID 最大
	UNIT_MAX_ID,
	## 搜索模式: 单位 ID 最小
	UNIT_MIN_ID,
	## 搜索模式: 单位赏金最高
	UNIT_MAX_GOLD,
	## 搜索模式: 单位赏金最低
	UNIT_MIN_GOLD,
}


## 状态标志枚举
enum State {
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
	## 状态：在路径上移动
	NAV_PATH_WALK = 1 << 5,
	## 状态：等待
	WAITING = 1 << 6,
	## 状态：禁止
	DISABLED = 1 << 7,
	## 状态：移除
	REMOVED = 1 << 8,
}


## 实体信息栏类型枚举
enum InfoBarType {
	## 信息栏类型：无，不显示
	NONE,
	## 信息栏类型：敌人或友军的信息栏
	UNIT,
	## 信息栏类型：防御塔的信息栏
	TOWER,
	## 信息栏类型：文本
	TEXT,
}


## 选择模式枚举
enum SelectMode {
	NONE,
	RALLY,
	BARRACK_RALLY,
}


## 方向枚举 
enum Direction {
	## 方向：上
	UP,
	## 方向：下
	DOWN,
	## 方向：左
	LEFT,
	## 方向：右
	RIGHT,
}


## 音频播放模式枚举
enum AudioPlayMode {
	## 音频播放模式：随机播放音频列表中的音频
	RANGDOM,
	## 音频播放模式：并行播放音频列表中的音频
	CONCURRENCY
}


## 防御塔类型枚举
enum TowerType {
	## 防御塔类型：塔位
	TOWER_HOLDER,
	## 防御塔类型：箭塔
	TOWER_ARCHER,
	## 防御塔类型：兵营
	TOWER_BARRACK,
	## 防御塔类型：法师塔
	TOWER_MAGE,
	## 防御塔类型：炮塔
	TOWER_ARTILLERY,
}


## 塔位样式枚举
enum TowerHolderStyle {
	## 草地
	GRASS,
}


## 子弹生成模式枚举
enum BulletSpawnMode {
	## 子弹生成模式：随机
	##
	## 子弹会以 bullet_angle_range 范围内的随机角度生成
	RANDOM,
	## 子弹生成模式：等距
	##
	## 子弹会以 bullet_angle_range 范围内等距的角度生成
	EQUAL_INTERVAL,
}


## 选择菜单按钮类型
enum SelectMenuButtonType {
	## 升级
	UPGRADE,
	## 出售
	SELL,
	## 集结
	RALLY,
	## 购买
	BUY,
	## 技能
	SKILL,
	## 瞄准
	AIM,
	## 切换
	SWITCH,
}


## 近战状态枚举
enum MeleeState {
	## 到达原点
	IDLE,
	## 返回位置中
	RETURNING,      
	## 前往近战位置中
	MOVING_TO_POS,  
	## 已到达位置
	MELEE_POS_ARRIVED,    
}


#region 组件名称
## 组件名称: 血量
const CN_HEALTH: NodePath = ^"HealthComponent"
## 组件名称: 导航路径
const CN_NAV_PATH: NodePath = ^"NavPathComponent"
## 组件名称: 集结点
const CN_RALLY: NodePath = ^"RallyComponent"
## 组件名称: 防御塔
const CN_TOWER: NodePath = ^"TowerComponent"
## 组件名称: 状态效果
const CN_MODIFIER: NodePath = ^"ModifierComponent"
## 组件名称: 光环
const CN_AURA: NodePath = ^"AuraComponent"
## 组件名称: 近战攻击
const CN_MELEE: NodePath = ^"MeleeComponent"
## 组件名称: 远程攻击
const CN_RANGED: NodePath = ^"RangedComponent"
## 组件名称: 子弹
const CN_BULLET: NodePath = ^"BulletComponent"
## 组件名称: 精灵
const CN_SPRITE: NodePath = ^"SpriteComponent"
## 组件名称: 兵营
const CN_BARRACK: NodePath = ^"BarrackComponent"
## 组件名称: 生成器
const CN_SPAWNER: NodePath = ^"SpawnerComponent"
## 组件名称: UI
const CN_UI: NodePath = ^"UIComponent"
## 组件名称: FX
const CN_FX: NodePath = ^"FXComponent"
#endregion


#region 组名称 (StringName)
## 组名: 实体
const GROUP_ENTITIES: StringName = &"entities"
## 组名: 敌人
const GROUP_ENEMIES: StringName = &"enemies"
## 组名: 友军
const GROUP_FRIENDLYS: StringName = &"friendlys"
## 组名: 单位
const GROUP_UNIT: StringName = &"units"
## 组名: 防御塔
const GROUP_TOWERS: StringName = &"towers"
## 组名: 状态效果
const GROUP_MODIFIERS: StringName = &"modifiers"
## 组名: 光环
const GROUP_AURAS: StringName = &"auras"
## 组名: 子弹
const GROUP_BULLETS: StringName = &"bullets"
#endregion


#region 关卡相关常量
## 关卡列表
const LEVEL_LIST: Array[int] = [1]
#endregion
