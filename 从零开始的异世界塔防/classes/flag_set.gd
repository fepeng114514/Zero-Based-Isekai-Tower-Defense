class_name FlagSet

var bits: int = 0


func set_from_array(flags: Array) -> void:
	bits = 0
	for f in flags:
		bits |= f


func has_flags(flags: int) -> bool:
	return bits & flags


func add_flags(flags: int) -> void:
	bits |= flags


func remove_flags(flags: int) -> void:
	bits &= ~flags
