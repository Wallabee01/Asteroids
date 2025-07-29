extends CanvasLayer

@onready var life_01 = %Life01
@onready var life_02 = %Life02
@onready var life_03 = %Life03
@onready var life_04 = %Life04
@onready var life_05 = %Life05
@onready var score_label = %ScoreLabel
@onready var highscore_label = %HighscoreLabel
@onready var pause_panel_container = %PausePanelContainer
@onready var start_panel_container = %StartPanelContainer

var is_paused: bool = false
var is_game_started:bool = false

func _ready():
	GameEvents.score_changed.connect(_on_score_changed)
	GameEvents.ship_destroyed.connect(_on_ship_destroyed)
	GameEvents.game_over.connect(_on_game_over)
	_set_score_label(GameEvents.score)
	_set_highscore_label(GameEvents.highscore)
	get_tree().paused = true


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		if !is_paused && is_game_started:
			is_paused = true
			pause_panel_container.visible = true
			get_tree().paused = true
		elif is_paused && is_game_started:
			is_paused = false
			pause_panel_container.visible = false
			get_tree().paused = false
		
		get_tree().root.set_input_as_handled()
	
	if event.is_action_pressed("start"):
		if !is_game_started:
			start_panel_container.visible = false
			get_tree().paused = false
			get_tree().root.set_input_as_handled()


func _set_score_label(points: int):
	score_label.text = str(points)


func _set_highscore_label(points: int):
	highscore_label.text = "\n" + str(points)


func _on_score_changed(score: int):
	_set_score_label(score)


func _on_ship_destroyed():
	var lives = GameEvents.lives
	match lives:
		4:
			life_01.visible = false
		3:
			life_02.visible = false
		2:
			life_03.visible = false
		1:
			life_04.visible = false


func _on_game_over():
	life_01.visible = true
	life_02.visible = true
	life_03.visible = true
	life_04.visible = true
	
	start_panel_container.visible = true
	get_tree().paused = true


func _on_quit_button_pressed():
	get_tree().quit()
