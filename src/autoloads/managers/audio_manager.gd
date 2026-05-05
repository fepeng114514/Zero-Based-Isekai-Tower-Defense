extends Node
## 音频管理器
##
## 管理音频播放与总线


## 主音频总线
const MasterBus: StringName = &"Master"
## 音乐总线
const MusicBus: StringName = &"Music"
## 音效总线
const SFXBus: StringName = &"SFX"

var _audio_stream_dict: Dictionary[StringName, AudioStream] = {}
## 音乐的 AudioStreamPlayer
var _music_player := AudioStreamPlayer.new()
## 音效 AudioStreamPlayer 总数
var _sfx_player_count: int = 10
## 音效的 AudioStreamPlayer 数组
var _sfx_player_list: Array[AudioStreamPlayer] = []


func _ready() -> void:
	# 初始化音乐
	_music_player.name = "Music"
	add_child(_music_player)
	
	# 初始化音效
	for i: int in _sfx_player_count:
		var sfx_player := AudioStreamPlayer.new()
		sfx_player.name = "SFX%d" % (i + 1)
		add_child(sfx_player)
		_sfx_player_list.append(sfx_player)
	
	
func load() -> void:
	_audio_stream_dict.clear()
	
	var json_data: Array = U.load_json(
		"res://assets/audio_paths.json"
	)
	
	for path: String in json_data:
		if not ResourceLoader.exists(path):
			Log.error("未找到音频: %s" % path)
			continue
		
		Log.verbose("加载音频: %s" % path)
		var stream: AudioStream = load(path)
		
		var stream_name: StringName = path.get_file().get_basename()
		_audio_stream_dict[stream_name] = stream
	
	
## 播放音乐
func play_music(audio_data: AudioData) -> void:
	play_audio(audio_data, _music_player, MusicBus)


## 播放音效
func play_sfx(audio_data: AudioData) -> void:
	if not audio_data:
		return
	
	for sfx_player: AudioStreamPlayer in _sfx_player_list:
		if sfx_player.playing:
			continue

		play_audio(audio_data, sfx_player, SFXBus)
		return
		
		
## 播放音频
func play_audio(
		audio_data: AudioData, player: AudioStreamPlayer, bus: StringName
	) -> void:
	if not audio_data:
		return
		
	await TimeMgr.y_wait(audio_data.delay)
	
	var play_list: Array[StringName] = []
	var data_list: Array[StringName] = audio_data.list

	match audio_data.play_mode:
		C.AudioPlayMode.RANGDOM:
			var audio_name: StringName = U.pick_random(data_list)
			play_list = [audio_name]
		C.AudioPlayMode.SEQUENCE:
			var play_idx: int = audio_data.played_idx + 1
			play_idx %= data_list.size()
			
			var audio_name: StringName = data_list[play_idx]
			audio_data.played_idx = play_idx
			
			play_list = [audio_name]
		C.AudioPlayMode.CONCURRENCY:
			play_list = data_list
			
	for audio_name: StringName in play_list:
		player.stream = _audio_stream_dict[audio_name]
		player.volume_db = audio_data.volume_db
		player.volume_linear = audio_data.volume_linear
		player.bus = bus
		player.play()
