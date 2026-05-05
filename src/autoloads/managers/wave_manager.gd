extends Node


@warning_ignore_start("unused_signal")
signal first_release_wave
signal release_wave
signal start_wave_timer
@warning_ignore_restore("unused_signal")


## 是否跳过波次计时
var is_release_wave: bool = false
## 当前波次
var current_wave_idx: int = 0
## 波次是否释放完毕
var waves_finished: bool = false
var is_first_release_wave: bool = true
