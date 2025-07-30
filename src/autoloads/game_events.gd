extends Node

const SAVE_FILE_PATH = "user://game.save"

signal asteroid_destroyed(points: int)
signal score_changed(score: int)
signal lives_changed(lives: int)
signal highscore_changed(highscore: int)
signal alien_destroyed
signal ship_destroyed
signal level_complete
signal level_changed(level)
signal game_over

var score: int = 0
var highscore: int = 0
var lives: int = 5
var level: int = 0
var player: Node2D
var is_alien: bool = false


func _ready():
	asteroid_destroyed.connect(_on_asteroid_destroyed)
	alien_destroyed.connect(_on_alien_destroyed)
	ship_destroyed.connect(_on_ship_destroyed)
	level_complete.connect(_on_level_complete)


func _on_asteroid_destroyed(points):
	score += points
	score_changed.emit(score)


func _on_ship_destroyed():
	lives -= 1
	lives_changed.emit(lives)
	
	if lives == 0:
		await get_tree().create_timer(2.05).timeout
		game_over.emit()
		_reset()


func _check_highscore():
	if score > highscore:
		highscore = score
		highscore_changed.emit(highscore)
		save()

func _reset():
	_check_highscore()
	
	score = 0
	lives = 5
	level = 0
	score_changed.emit(score)
	lives_changed.emit(lives)
	level_changed.emit(level)


func _on_alien_destroyed():
	is_alien = false


func _on_level_complete():
	level += 1
	level_changed.emit(level)


func _exit_tree():
	_check_highscore()


func load_save_file():
	if !FileAccess.file_exists(SAVE_FILE_PATH): return
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	highscore = file.get_var()


func save():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_var(highscore)
