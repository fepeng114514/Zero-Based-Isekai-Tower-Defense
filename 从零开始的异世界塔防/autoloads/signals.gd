extends Node


"""信号库:
    存储所有信号
"""
@warning_ignore_start("unused_signal")
#region UI 相关
## 重设窗口大小信号
signal resized_window

## 选择实体信号
signal select_entity(e: Entity)
## 取消选择实体信号
signal deselect_entity
#endregion

## 创建实体信号
signal insert_entity(entity: Entity)

## 开始波次倒计时信号
signal start_wave_timer(wave: Wave)
@warning_ignore_restore("unused_signal")
