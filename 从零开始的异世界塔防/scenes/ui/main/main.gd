extends PanelContainer


#func _ready() -> void:
	#if GlobalMgr.is_debug:
		#UpdateJsonDatas.new()._run()
