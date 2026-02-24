class_name Log


## 获取当前时间戳字符串
static func _get_timestamp() -> String:
	var datetime: String = Time.get_datetime_string_from_system()
	return datetime.split("T")[1]


## 格式化日志消息
static func _format_message(level: int, message: String) -> String:
	var format_message: String = "[%s]%s: %s" % [
		_get_timestamp(), 
		C.LOG_LEVEL.keys()[level],
		message
	]
	
	return format_message


## 获取调用堆栈
static func _get_stack(stack_level: int) -> String:
	var stack: Array = get_stack()

	var sliced: Array = stack.slice(stack_level)
	var result: Array = [
		"Traceback:"
	]

	for item: Dictionary in sliced:
		result.append("\t%s:%s: in func '%s'" % [item.source, item.line, item.function])

	return "\n".join(result)


## 内部日志方法
static func _log(level: int, message: String, arg: Variant = null) -> void:
	if level < Conf.LOG_LEVEL:
		return
	
	var formatted_message: String
	if arg:
		formatted_message = message % arg
	else:
		formatted_message = message

	var plain_message: String = _format_message(level, formatted_message)
	
	match level:
		C.LOG_LEVEL.WARN:
			print_rich("[color=#F1C40F]● WARN: %s[/color]" % plain_message)
			push_warning(plain_message)
		C.LOG_LEVEL.ERROR:
			printerr(plain_message)
			print(_get_stack(3) + "\n")
			push_error(plain_message)
		_:
			print(plain_message)


## 详细日志
static func verbose(message: String, arg: Variant = null) -> void:
	_log(C.LOG_LEVEL.VERBOSE, message, arg)


## 调试日志
static func debug(message: String, arg: Variant = null) -> void:
	_log(C.LOG_LEVEL.DEBUG, message, arg)


## 信息日志
static func info(message: String, arg: Variant = null) -> void:
	_log(C.LOG_LEVEL.INFO, message, arg)


## 警告日志
static func warn(message: String, arg: Variant = null) -> void:
	_log(C.LOG_LEVEL.WARN, message, arg)


## 错误日志
static func error(message: String, arg: Variant = null) -> void:
	_log(C.LOG_LEVEL.ERROR, message, arg)
