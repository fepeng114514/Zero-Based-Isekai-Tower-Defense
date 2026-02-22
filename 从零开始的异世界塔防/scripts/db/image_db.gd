extends Node

"""
图像数据库，存储所有图像
"""

var image_db: Dictionary[String, AtlasTexture] = {}
var atlas_uses: Array[String] = []
	
func load(required_atlas: Array) -> void:
	image_db = {}
	atlas_uses = []

	_load_atlas(required_atlas)
	
func _load_atlas(required_atlas: Array) -> void:
	for atlas_name in required_atlas:
		var path: String = C.PATH_ATLAS_ASSETS % atlas_name

		if path in atlas_uses:
			print_debug("跳过重复加载图集: %s" % path)
			return

		atlas_uses.append(path)
		print_debug("加载图集: %s" % path)
		_parse_atlas_data(path)

## 解析图集数据
func _parse_atlas_data(path: String) -> void:
	"""图集格式
	"图集名.png": {	# 来自哪个图集，主要用于多图集的打包
		"图像名": {
			"quad": [	# 图像位置（矩形）
				3,
				3,
				2729,
				1536
			],
			"alias": []	# 别名
		},
	"""
	var atlas_data = U.load_json_file(path + ".json")
	
	for atlas_name: String in atlas_data.keys():
		var images_data: Dictionary = atlas_data[atlas_name]
		var atlas_path: String = C.PATH_ATLAS_ASSETS % atlas_name
		var atlas_file: Texture2D = load(atlas_path)
		
		for img_name: String in images_data.keys():
			var img_data: Dictionary = images_data[img_name]

			var atlas_texture: AtlasTexture = _create_atlas_texture(img_data, atlas_file)
			image_db[img_name] = atlas_texture

			for alias: String in img_data.alias:
				image_db[alias] = atlas_texture
			
			print_verbose("加载图像: %s" % img_name)

## 创建图集纹理
func _create_atlas_texture(
		img_data: Dictionary, atlas_file: Texture2D
	) -> AtlasTexture:
	var quad_data: Array = img_data["quad"]

	var atlas_texture: AtlasTexture = AtlasTexture.new()
	atlas_texture.atlas = atlas_file
	atlas_texture.region = Rect2(quad_data[0], quad_data[1], quad_data[2], quad_data[3])
	atlas_texture.filter_clip = true

	return atlas_texture
	
## 获取纹理
func get_image(img_name: String) -> AtlasTexture:
	if not image_db.has(img_name):
		printerr("未找到图像: %s" % img_name)
		return null
		
	return image_db[img_name]
