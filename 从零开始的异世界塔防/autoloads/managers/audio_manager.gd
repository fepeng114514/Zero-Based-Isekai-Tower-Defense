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

## 音乐的 AudioStreamPlayer
var _music_player := AudioStreamPlayer.new()
## 音效 AudioStreamPlayer 总数
var _sfx_player_count: int = 10
## 音效的 AudioStreamPlayer 数组
var _sfx_players: Array[AudioStreamPlayer] = []


func _ready() -> void:
	# 初始化音乐
	_music_player.name = "Music"
	add_child(_music_player)
	
	# 初始化音效
	for i: int in range(_sfx_player_count):
		var sfx_player := AudioStreamPlayer.new()
		sfx_player.name = "SFX%d" % (i + 1)
		add_child(sfx_player)
		_sfx_players.append(sfx_player)
	
	
## 播放音乐
func play_music(audio_data: AudioData) -> void:
	play_audio(audio_data, _music_player, MusicBus)


## 播放音效
func play_sfx(audio_data: AudioData) -> void:
	for sfx_player: AudioStreamPlayer in _sfx_players:
		if sfx_player.playing:
			continue
		
		play_audio(audio_data, sfx_player, SFXBus)
		return
		
		
## 播放音频
func play_audio(
		audio_data: AudioData, player: AudioStreamPlayer, bus: StringName
	) -> void:
	match audio_data.play_mode:
		C.AudioPlayMode.RANGDOM:
			var stream: AudioStream = audio_data.audio_list.pick_random()
			_play(stream, player, bus, audio_data)
		C.AudioPlayMode.CONCURRENCY:
			for stream: AudioStream in audio_data.audio_list:
				_play(stream, player, bus, audio_data)


## 播放音频
func _play(
		stream: AudioStream, 
		player: AudioStreamPlayer, 
		bus: StringName,
		audio_data: AudioData
	) -> void:
	player.stream = stream
	player.volume_db = audio_data.volume_db
	player.volume_linear = audio_data.volume_linear
	player.bus = bus
	player.play()
