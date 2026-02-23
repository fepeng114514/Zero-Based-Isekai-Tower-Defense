class_name Log 

## 日志级别枚举
enum Level {

}

## 当前日志级别（低于此级别的日志不会输出）
var current_level: Level = Level.DEBUG

## 是否启用文件输出
var file_output_enabled: bool = false

## 日志文件路径
var log_file_path: String = "user://game.log"

## 是否在控制台输出带颜色的文本
var use_colors: bool = true

## 是否显示时间戳
var show_timestamp: bool = true

## 是否显示日志级别
var show_level: bool = true

## 是否显示调用者信息（文件名和行号）
var show_caller: bool = true

## 单例实例
static var instance: Log

## 颜色定义（ANSI颜色码）
const COLOR_RESET := "\033[0m"
const COLOR_DEBUG := "\033[36m"  # 青色
const COLOR_INFO := "\033[32m"   # 绿色
const COLOR_WARN := "\033[33m"   # 黄色
const COLOR_ERROR := "\033[31m"  # 红色
const COLOR_FATAL := "\033[35m"  # 紫色
const COLOR_TIME := "\033[90m"   # 灰色

## 日志文件句柄
var _file: FileAccess = null


func _init():
	"""初始化日志实例"""
	if instance == null:
		instance = self


## 获取单例
static func get_instance() -> Log:
	if instance == null:
		instance = Log.new()
	return instance


## 设置日志级别
func set_level(level: Level) -> void:
	current_level = level


## 启用文件输出
func enable_file_output(path: String = "user://game.log") -> void:
	file_output_enabled = true
	log_file_path = path
	_open_log_file()


## 禁用文件输出
func disable_file_output() -> void:
	file_output_enabled = false
	_close_log_file()


## 打开日志文件
func _open_log_file() -> void:
	if not file_output_enabled:
		return
		
	_file = FileAccess.open(log_file_path, FileAccess.WRITE_READ)
	if _file == null:
		push_error("无法打开日志文件: " + log_file_path)
		file_output_enabled = false


## 关闭日志文件
func _close_log_file() -> void:
	if _file != null:
		_file.close()
		_file = null


## 写入文件
func _write_to_file(text: String) -> void:
	if not file_output_enabled or _file == null:
		return
		
	_file.store_line(text)
	_file.flush()


## 获取当前时间戳字符串
func _get_timestamp() -> String:
	return Time.get_datetime_string_from_system()


## 获取调用者信息
func _get_caller_info() -> String:
	var stack = get_stack()
	# 索引0是当前函数，索引1是调用者，索引2是日志函数调用者
	if stack.size() > 2:
		var caller = stack[2]
		return "%s:%d" % [caller.source.get_file(), caller.line]
	return ""


## 格式化日志消息
func _format_message(level: Level, message: String, caller_info: String = "") -> String:
	var parts := []
	
	if show_timestamp:
		parts.append("[%s]" % _get_timestamp())
	
	if show_level:
		parts.append("[%s]" % Level.keys()[level])
	
	if show_caller and caller_info:
		parts.append("(%s)" % caller_info)
	
	parts.append(message)
	
	return " ".join(parts)


## 输出带颜色的文本到控制台
func _print_colored(level: Level, formatted_msg: String, plain_msg: String) -> void:
	if not use_colors:
		print(plain_msg)
		return
	
	var color: String
	match level:
		Level.DEBUG:
			color = COLOR_DEBUG
		Level.INFO:
			color = COLOR_INFO
		Level.WARN:
			color = COLOR_WARN
		Level.ERR, Level.FATAL:
			color = COLOR_ERROR
	
	# 分割时间戳和消息，为时间戳添加灰色
	if show_timestamp and formatted_msg.find("[") == 0:
		var end_bracket = formatted_msg.find("]", 0)
		if end_bracket > 0:
			var timestamp = formatted_msg.substr(0, end_bracket + 1)
			var rest = formatted_msg.substr(end_bracket + 1)
			print(COLOR_TIME + timestamp + color + rest + COLOR_RESET)
			return
	
	# 如果没有时间戳或格式不匹配，直接输出
	print(color + formatted_msg + COLOR_RESET)


## 内部日志方法
func _log(level: Level, message: String, args: Array = []) -> void:
	if level < current_level:
		return
	
	# 格式化消息（支持类似printf的格式化）
	var formatted_message: String
	if args.size() > 0:
		formatted_message = message % args
	else:
		formatted_message = message
	
	var caller_info := _get_caller_info()
	var plain_msg := _format_message(level, formatted_message, caller_info)
	var colored_msg := _format_message(level, formatted_message, caller_info)
	
	# 输出到控制台
	_print_colored(level, colored_msg, plain_msg)
	
	# 输出到文件（不带颜色）
	_write_to_file(plain_msg)
	
	# 对于错误级别以上，也使用Godot的内置错误系统
	match level:
		Level.WARN:
			push_warning(plain_msg)
		Level.ERR, Level.FATAL:
			push_error(plain_msg)


## 调试日志
func debug(message: String, args: Array = []) -> void:
	_log(Level.DEBUG, message, args)


## 信息日志
func info(message: String, args: Array = []) -> void:
	_log(Level.INFO, message, args)


## 警告日志
func warn(message: String, args: Array = []) -> void:
	_log(Level.WARN, message, args)


## 错误日志
func error(message: String, args: Array = []) -> void:
	_log(Level.ERR, message, args)


## 致命错误日志
func fatal(message: String, args: Array = []) -> void:
	_log(Level.FATAL, message, args)


## 断言（条件为false时记录错误）
func assert(condition: bool, message: String = "Assertion failed") -> bool:
	if not condition:
		error(message)
		return false
	return true


## 清除日志文件
func clear_log_file() -> void:
	if _file != null:
		_close_log_file()
	
	var file = FileAccess.open(log_file_path, FileAccess.WRITE)
	if file != null:
		file.store_string("")
		file.close()
	
	_open_log_file()


## 静态方法 - 方便直接调用

static func d(message: String, args: Array = []) -> void:
	get_instance().debug(message, args)

static func i(message: String, args: Array = []) -> void:
	get_instance().info(message, args)

static func w(message: String, args: Array = []) -> void:
	get_instance().warn(message, args)

static func e(message: String, args: Array = []) -> void:
	get_instance().error(message, args)

static func f(message: String, args: Array = []) -> void:
	get_instance().fatal(message, args)

static func a(condition: bool, message: String = "Assertion failed") -> bool:
	return get_instance().assert(condition, message)
