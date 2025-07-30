extends Node2D

const ALIEN_LARGE_SCENE: PackedScene = preload("res://src/aliens/alien_large.tscn")
const ALIEN_SMALL_SCENE: PackedScene = preload("res://src/aliens/alien_small.tscn")
const SPAWN_SAFE_RADIUS: float = 96.0
const MIN_SPAWN_TIMER: float = 5.0
const MAX_SPAWN_TIMER: float = 10.0
const ALIEN_LARGE_LEVEL_SPAWN: int = 1
const ALIEN_SMALL_LEVEL_SPAWN: int = 3

@onready var spawn_timer = %SpawnTimer


func _ready():
	GameEvents.level_complete.connect(_on_level_complete)
	GameEvents.alien_destroyed.connect(_on_alien_destroyed)
	GameEvents.game_over.connect(_on_game_over)
	
	_set_spawn_timer()


func _spawn_alien(alien_instance):
	add_child(alien_instance)
	
	alien_instance.global_position = Vector2(randf_range(0.0, get_viewport_rect().size.x), randf_range(0.0, get_viewport_rect().size.y))
	while alien_instance.global_position.x > (GameEvents.player.global_position.x - SPAWN_SAFE_RADIUS)\
	&& alien_instance.global_position.x < (GameEvents.player.global_position.x + SPAWN_SAFE_RADIUS):
		alien_instance.global_position.x = randf_range(0.0, get_viewport_rect().size.x)
	while alien_instance.global_position.y > (GameEvents.player.global_position.y - SPAWN_SAFE_RADIUS)\
	&& alien_instance.global_position.y < (GameEvents.player.global_position.y + SPAWN_SAFE_RADIUS):
		alien_instance.global_position.y = randf_range(0.0, get_viewport_rect().size.y)


func _set_spawn_timer():
	spawn_timer.wait_time = randf_range(MIN_SPAWN_TIMER, MAX_SPAWN_TIMER)
	spawn_timer.start()


func _reset():
	for child in get_children():
		if child is Alien:
			child.call_deferred("queue_free")
	
	GameEvents.is_alien = false
	
	_set_spawn_timer()


func _on_alien_destroyed():
	_set_spawn_timer()


func _on_level_complete():
	_reset()


func _on_game_over():
	_reset()


func _on_spawn_timer_timeout():
	if GameEvents.level < ALIEN_LARGE_LEVEL_SPAWN:
			_set_spawn_timer()
			return
	
	if !GameEvents.is_alien:
		var alien_to_spawn
		
		if GameEvents.level >= ALIEN_SMALL_LEVEL_SPAWN:
			if randf() > 0.33:
				alien_to_spawn = ALIEN_LARGE_SCENE.instantiate() as Alien
			else:
				alien_to_spawn = ALIEN_SMALL_SCENE.instantiate() as Alien
		else:
			alien_to_spawn = ALIEN_LARGE_SCENE.instantiate() as Alien
		
		GameEvents.is_alien = true
		_spawn_alien(alien_to_spawn)
		_set_spawn_timer()
