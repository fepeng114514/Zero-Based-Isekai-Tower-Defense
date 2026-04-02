class_name EditorUtils
## 编辑器工具函数库


#region tool 专用方法
static func tool_on_tree_call(
		node: Node, what: int, fn: Callable
) -> void:
	if not Engine.is_editor_hint():
		return
	
	match what:
		node.NOTIFICATION_CHILD_ORDER_CHANGED:
			# 子节点顺序改变
			fn.call()
		node.NOTIFICATION_ENTER_TREE:
			# 进入场景树
			fn.call()
		node.NOTIFICATION_PARENTED:
			# 被添加为子节点
			fn.call()
		node.NOTIFICATION_UNPARENTED:
			# 被移除
			fn.call()
#endregion
