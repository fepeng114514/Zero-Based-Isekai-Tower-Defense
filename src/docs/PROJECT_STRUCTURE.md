# 项目架构
该文档用于说明项目的架构与目录结构，以便组织代码。

## 目录
```
py_tools/					# python 工具
src/
├── .build/                 # 编译输出（自动生成，不提交 Git）目录
├── addons/                 # 插件目录
├── assets/                 # 资源文件目录
│   ├── animated_atlas/     # 动画图集目录
│   ├── audios/             # 音频目录
│   ├── fonts/              # 字体目录
│   ├── image_atlas/        # 图像图集目录
│   └── shaders/            # 着色器目录
├── autoloads/              # 自动加载目录
│   └── managers/           # 管理器目录
├── classes/                # 类目录
├── datas/                  # 数据目录
├── docs/                   # 文档目录
├── ecs/                    # ECS 相关目录
│   ├── components          # 组件类目录
│   │   └── subcomponents/  # 子组件目录
│   ├── resources/          # 资源类目录
│   ├── systems/            # 系统类目录
│   │   └── behaviors/      # 行为类目录
│   └── entity.gd           # 实体类
├── resources/              # 资源目录
│   ├── atlas_textures/     # 图集纹理资源目录
│   ├── select_menu/        # 选择菜单资源目录
│   └── sprite_frames/      # 精灵帧资源目录
├── scenes/                 # 场景目录
│   ├── entities/           # 实体场景目录
│   │   ├── enemies/        # 敌人场景目录
│   │   └── towers/         # 防御塔场景目录
│   ├── levels/             # 关卡场景目录
│   └── ui/                 # UI 场景目录
├── tools/                  # 构建/辅助工具脚本目录
```

## 架构
项目使用 ECS 实体-组件-系统架构，将数据与逻辑分离到组件与系统中。

## 代码层级
核心层（core）
↓
管理器层（managers）
↓
组件层（components）
↓
系统层（systems）

## 实体生命周期
1. 创建实体，遍历并调用所有系统的 `_on_insert` 回调。
2. 开始更新实体，每帧遍历并调用所有系统的 `_on_update` 回调。
3. 实体被移除，遍历并调用所有系统的 `_on_remove` 回调。