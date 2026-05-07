@tool
extends Entity


@export var show_time: float = 1
@export var build_target: StringName = ""

@export_group("Ref")
@export var progress_bar: TextureProgressBar = null


func _on_insert() -> bool:
	progress_bar.value = 0
	
	return true


func _on_update(_delta: float) -> void:
	var max_value: float = progress_bar.max_value
	
	var past_time: float = TimeMgr.tick_ts - insert_ts
	var value: float = past_time * max_value / show_time
	
	progress_bar.value = value
	
	if TimeMgr.is_ready_time(insert_ts, show_time):
		var tower_c: TowerComponent = get_node_or_null(C.CN_TOWER)
		tower_c.upgrade_to = build_target
