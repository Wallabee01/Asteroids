extends Node2D

const ASTEROID_LARGE_SCENE: PackedScene = preload("res://src/asteroids/asteroid_large.tscn")
const SPAWN_OFFSET: float = 32.0
const SPAWN_SAFE_RADIUS: float = 96.0
const MAX_SPEED: float = 100.0
const MIN_SPAWN_ANGLE: float = -0.1
const MAX_SPAWN_ANGLE: float = 0.5
const MIN_SPAWN_SPEED_MULTIPLIER: float = 0.75
const MAX_SPAWN_SPEED_MULTIPLIER: float = 1.75
const START_ASTEROID_COUNT = 5
const ASTEROID_GROW_COUNT = 1
const NEW_LEVEL_DELAY: float = 1.0

var asteroid_count: int = START_ASTEROID_COUNT


func _ready():
	GameEvents.asteroid_destroyed.connect(_on_asteroid_destroyed)
	GameEvents.game_over.connect(_on_game_over)
	_spawn_asteroids()


func _spawn_asteroids():
	for i in asteroid_count:
		var asteroid_instance = ASTEROID_LARGE_SCENE.instantiate() as Asteroid
		add_child(asteroid_instance)
		
		asteroid_instance.global_position = Vector2(randf_range(0.0, get_viewport_rect().size.x), randf_range(0.0, get_viewport_rect().size.y))
		while asteroid_instance.global_position.x > (get_viewport_rect().size.x / 2.0 - SPAWN_SAFE_RADIUS)\
		&& asteroid_instance.global_position.x < (get_viewport_rect().size.x / 2.0 + SPAWN_SAFE_RADIUS):
			asteroid_instance.global_position.x = randf_range(0.0, get_viewport_rect().size.x)
		while asteroid_instance.global_position.y > (get_viewport_rect().size.y / 2.0 - SPAWN_SAFE_RADIUS)\
		&& asteroid_instance.global_position.y < (get_viewport_rect().size.y / 2.0 + SPAWN_SAFE_RADIUS):
			asteroid_instance.global_position.y = randf_range(0.0, get_viewport_rect().size.y)
		
		var initial_velocity: Vector2 = Vector2(randf_range(-MAX_SPEED, MAX_SPEED), randf_range(-MAX_SPEED, MAX_SPEED))
		asteroid_instance.set_velocity(initial_velocity)


func _on_asteroid_destroyed(_points: int):
	await get_tree().create_timer(NEW_LEVEL_DELAY).timeout
	
	if get_children().is_empty():
		asteroid_count += ASTEROID_GROW_COUNT
		_spawn_asteroids()
		GameEvents.level_complete.emit()


func _on_game_over():
	for child in get_children():
		child.call_deferred("queue_free")
	
	asteroid_count = START_ASTEROID_COUNT
	call_deferred("_spawn_asteroids")
