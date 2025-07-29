extends Node

const SAVE_FILE_PATH = "user://game.save"

signal asteroid_destroyed(points: int)
signal score_changed(score: int)
signal lives_changed(lives: int)
signal highscore_changed(highscore: int)
signal ship_destroyed
signal level_complete
signal game_over

var score: int = 0
var highscore: int = 0
var lives: int = 5


func _ready():
	asteroid_destroyed.connect(_on_asteroid_destroyed)
	ship_destroyed.connect(_on_ship_destroyed)


func _on_asteroid_destroyed(points):
	score += points
	score_changed.emit(score)


func _on_ship_destroyed():
	lives -= 1
	lives_changed.emit(lives)
	
	if lives == 0:
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
	score_changed.emit(score)
	lives_changed.emit(lives)


func _exit_tree():
	_check_highscore()


func load_save_file():
	if !FileAccess.file_exists(SAVE_FILE_PATH): return
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	highscore = file.get_var()


func save():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_var(highscore)
