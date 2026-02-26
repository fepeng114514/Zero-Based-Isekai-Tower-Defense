extends Node


"""信号库:
    存储所有信号
"""

#region UI 相关
## 重设窗口大小信号
signal resized_window_s

## 选择实体信号
signal select_entity_s(e: Entity)
## 取消选择实体信号
signal deselect_entity_s
#endregion

## 创建实体信号
signal create_entity_s(entity: Entity)
