extends Node

const LEVEL_COMPLETE_SFX: AudioStream = preload("res://assets/audio/sfx/level_complete.ogg")
const GAME_OVER_SFX: AudioStream = preload("res://assets/audio/sfx/game_over.ogg")

@onready var audio_stream_player = %AudioStreamPlayer


func _ready():
	GameEvents.level_complete.connect(_on_level_complete)
	GameEvents.game_over.connect(_on_game_over)


func _on_level_complete():
	audio_stream_player.stream = LEVEL_COMPLETE_SFX
	audio_stream_player.pitch_scale = randf_range(0.9, 1.1)
	audio_stream_player.play()


func _on_game_over():
	audio_stream_player.stream = GAME_OVER_SFX
	audio_stream_player.pitch_scale = randf_range(0.9, 1.1)
	audio_stream_player.play()
