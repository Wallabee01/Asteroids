extends Area2D
class_name Asteroid

const DEATH_SFX_01: AudioStream = preload("res://assets/audio/sfx/hit1.ogg")
const DEATH_SFX_02: AudioStream = preload("res://assets/audio/sfx/hit2.ogg")
const DEATH_SFX_03: AudioStream = preload("res://assets/audio/sfx/hit3.ogg")
const DEATH_SFX_04: AudioStream = preload("res://assets/audio/sfx/hit4.ogg")
const DEATH_SFX_05: AudioStream = preload("res://assets/audio/sfx/hit5.ogg")
const STAND_ALONE_STREAM_PLAYER: PackedScene = preload("res://src/components/standalone_stream_player.tscn")
const EXPLOSION_SCENE: PackedScene = preload("res://src/components/explosion_gpu_particles_2d.tscn")
const MAX_SPEED: float = 100
const SPAWN_OFFSET: float = 32.0
const MIN_SPAWN_ANGLE: float = -0.1
const MAX_SPAWN_ANGLE: float = 0.5
const MIN_SPAWN_SPEED_MULTIPLIER: float = 0.75
const MAX_SPAWN_SPEED_MULTIPLIER: float = 1.75

var velocity = Vector2(randf_range(-MAX_SPEED, MAX_SPEED), randf_range(-MAX_SPEED, MAX_SPEED))
var asteroid_type_to_spawn: PackedScene

@onready var line_2d = %Line2D
@onready var collision_polygon_2d = %CollisionPolygon2D
@onready var line_2d_2 = %Line2D2
@onready var collision_polygon_2d_2 = %CollisionPolygon2D2
@onready var line_2d_3 = %Line2D3
@onready var collision_polygon_2d_3 = %CollisionPolygon2D3



func _ready():
	var rng = randf()
	if rng >= .33 and rng < .66:
		line_2d.visible = false
		collision_polygon_2d.disabled = true
		line_2d_2.visible = true
		collision_polygon_2d_2.disabled = false
	elif rng >= .66 and rng <= 1.0:
		line_2d.visible = false
		collision_polygon_2d.disabled = true
		line_2d_3.visible = true
		collision_polygon_2d_3.disabled = false


func _physics_process(delta):
	global_position += velocity * delta
	
	_handle_screen_wrap()


func _handle_screen_wrap():
	var screen_size = get_viewport_rect().size
	
	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0
	
	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0


func set_velocity(vel: Vector2):
	velocity = vel


func _spawn_asteroids(asteroid_type: String):
	match asteroid_type:
		"Medium":
			asteroid_type_to_spawn = load("res://src/asteroids/asteroid_medium.tscn")
		"Small":
			asteroid_type_to_spawn = load("res://src/asteroids/asteroid_small.tscn")
	
	if asteroid_type_to_spawn != null:
		_spawn_asteroid()
		_spawn_asteroid()


func _spawn_asteroid():
	var asteroid_instance = asteroid_type_to_spawn.instantiate() as Asteroid
	get_parent().add_child(asteroid_instance)
	asteroid_instance.global_position = global_position + Vector2(randf_range(-SPAWN_OFFSET, SPAWN_OFFSET), randf_range(-SPAWN_OFFSET, SPAWN_OFFSET))
	var initial_velocity: Vector2 = Vector2(velocity.x * randf_range(MIN_SPAWN_ANGLE, MAX_SPAWN_ANGLE), velocity.y * randf_range(MIN_SPAWN_ANGLE, MAX_SPAWN_ANGLE))
	initial_velocity = initial_velocity.normalized() * randf_range(MAX_SPEED * MIN_SPAWN_SPEED_MULTIPLIER, MAX_SPEED * MAX_SPAWN_SPEED_MULTIPLIER)
	asteroid_instance.set_velocity(initial_velocity)


func _on_asteroid_destroyed():
	call_deferred("_spawn_asteroids", "Medium")
	
	GameEvents.asteroid_destroyed.emit(20)


func _on_area_entered(area):
	area.queue_free()
	
	var stand_alone_stream_player_instance = STAND_ALONE_STREAM_PLAYER.instantiate()
	get_parent().add_child(stand_alone_stream_player_instance)
	var death_sound_roll: float = randf()
	if death_sound_roll >= 0.0 && death_sound_roll < 0.2:
		stand_alone_stream_player_instance.stream = DEATH_SFX_01
	elif death_sound_roll >= 0.2 && death_sound_roll < 0.4:
		stand_alone_stream_player_instance.stream = DEATH_SFX_02
	elif death_sound_roll >= 0.4 && death_sound_roll < 0.6:
		stand_alone_stream_player_instance.stream = DEATH_SFX_03
	elif death_sound_roll >= 0.6 && death_sound_roll < 0.8:
		stand_alone_stream_player_instance.stream = DEATH_SFX_04
	elif death_sound_roll >= 0.8 && death_sound_roll <+ 1.0:
		stand_alone_stream_player_instance.stream = DEATH_SFX_05
	stand_alone_stream_player_instance.play()
	
	var explosion_instance = EXPLOSION_SCENE.instantiate()
	get_parent().add_child(explosion_instance)
	explosion_instance.global_position = global_position
	
	_on_asteroid_destroyed()
	
	call_deferred("queue_free")
