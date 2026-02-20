extends Resource
class_name FrameRes

var texture: AtlasTexture
var frame_idx: int = 0

func _init(new_texture: AtlasTexture, new_frame_idx: int) -> void:
	texture = new_texture
	frame_idx = new_frame_idx

func set_data(new_texture: AtlasTexture, new_frame_idx: int) -> void:
	texture = new_texture
	frame_idx = new_frame_idx
