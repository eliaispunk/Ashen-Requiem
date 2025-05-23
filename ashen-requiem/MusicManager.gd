extends Node

@onready var audio_stream_player_2d: AudioStreamPlayer = $MainBGM

var main_bgm: AudioStream = preload("res://sounds/Dark-Lands.mp3")

func _ready():
	play_main_bgm()

func play_main_bgm():
	audio_stream_player_2d.stream = main_bgm
	audio_stream_player_2d.play()

func play_music(stream: AudioStream):
	audio_stream_player_2d.stream = stream
	audio_stream_player_2d.play()

func stop_music():
	audio_stream_player_2d.stop()
