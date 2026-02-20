extends Node

"""
图像数据库，存储所有图像
"""

var image_db: Dictionary = {}
var atlas_uses: Array[String] = []
var loaded_atlas: Array[String] = []

## 加载图集组（需要的图集）
func load_atlas_group(required_atlas: Array) -> void:
	for atlas_name in required_atlas:
		var path: String = CS.PATH_ATLAS_ASSETS % atlas_name
		preload_atlas(path)

## 预加载图集
func preload_atlas(path) -> void:
	print_debug("加载图集: %s" % path)

	if path in atlas_uses:
		print_debug("跳过重复加载图集: %s" % path)
		return

	atlas_uses.append(path)
	parse_atlas_data(path)
	
func parse_atlas_data(path: String):
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
		var atlas_path: String = CS.PATH_ATLAS_ASSETS % atlas_name
		var atlas_file: Texture2D = load(atlas_path)
		
		for img_name: String in images_data.keys():
			var img_data: Dictionary = images_data[img_name]
			
			var atlas_tex: AtlasTexture = create_atlas_texture(img_data, atlas_file)
			image_db[img_name] = atlas_tex

			for alias: String in img_data.alias:
				image_db[alias] = atlas_tex
			
			print_debug("加载图像: %s" % img_name)

func create_atlas_texture(img_data: Dictionary, atlas_file: Texture2D) -> AtlasTexture:
	var quad_data: Array = img_data["quad"]

	var atlas_tex: AtlasTexture = AtlasTexture.new()
	atlas_tex.atlas = atlas_file
	atlas_tex.region = Rect2(quad_data[0], quad_data[1], quad_data[2], quad_data[3])
	atlas_tex.filter_clip = true

	return atlas_tex
	
func get_images(img_name: String) -> AtlasTexture:
	return image_db.get(img_name)
