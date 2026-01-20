extends Node
#
#func deepclone_dict(dict: Dictionary) -> Dictionary:
	#var copy = {}
	#for key in dict:
		#var value = dict[key]
		#
		#if value is Dictionary:
			#copy[key] = deepclone_dict(value)
		#elif value is Array:
			#copy[key] = deepclone_array(value)
		#else:
			#copy[key] = value
	#
	#return copy
#
#func deepclone_array(array: Array):
	#var copy = []
	#for item in array:
		#if item is Dictionary:
			#copy.append(deepclone_dict(item))
		#elif item is Array:
			#copy.append(deepclone_array(item))
		#else:
			#copy.append(item)
			#
	#return copy

# 获取特定扩展名的文件
func get_files_with_extension(path: String, extensions: Array) -> Array:
	var files = []
	var dir = DirAccess.open(path)
	
	if not dir:
		return files
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.get_extension() in extensions:
			files.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	return files
