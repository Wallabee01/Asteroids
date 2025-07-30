extends Area2D
class_name Asteroid

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


func _on_area_entered(area):
	area.queue_free()
	#TODO: Explosion sfx
	var explosion_instance = EXPLOSION_SCENE.instantiate()
	get_parent().add_child(explosion_instance)
	explosion_instance.global_position = global_position
	
	call_deferred("_spawn_asteroids", "Medium")
	
	GameEvents.asteroid_destroyed.emit(20)
	
	call_deferred("queue_free")
