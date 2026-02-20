extends Resource
class_name AnimRes

var origin_name: String = ""
var full_name: String = ""
var fps: float = 60
var loop: bool = true
var from: int = 1
var to: int = -1
var frames: Array[FrameRes] = []

func _init(new_full_name: String, new_origin_name: String) -> void:
	full_name = new_full_name
	origin_name = new_origin_name

func set_data(
		new_fps: float, new_loop: bool, new_from: int, new_to: int
	) -> void:
	fps = new_fps
	loop = new_loop
	from = new_from
	to = new_to

## 增加一帧
func add_single_frame(texture: AtlasTexture, frame_idx: int) -> void:
	frames.append(FrameRes.new(texture, frame_idx))

## 根据范围增加帧
func add_frames() -> void:
	for i in range(from, to + 1):
		var img_name: String = "%s%%%d" % [origin_name, i]
		var img: AtlasTexture = ImageDB.image_db[img_name]
		
		add_single_frame(img, i)
		
	# 按帧索引升序排序
	frames.sort_custom(func(a, b): return a.frame_idx < b.frame_idx)
