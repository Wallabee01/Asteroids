extends Area2D
class_name Asteroid

const EXPLOSION_SCENE: PackedScene = preload("res://src/components/explosion_gpu_particles_2d.tscn")
const ASTEROID_MEDIUM_SCENE_01: PackedScene = preload("res://src/asteroids/asteroid_medium_01.tscn")
const MAX_SPEED: float = 100
const SPAWN_OFFSET: float = 32.0
const MIN_SPAWN_ANGLE: float = -0.1
const MAX_SPAWN_ANGLE: float = 0.5
const MIN_SPAWN_SPEED_MULTIPLIER: float = 0.75
const MAX_SPAWN_SPEED_MULTIPLIER: float = 1.75

var velocity = Vector2(randf_range(-MAX_SPEED, MAX_SPEED), randf_range(-MAX_SPEED, MAX_SPEED))


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

func _on_area_entered(area):
	area.queue_free()
	#TODO: Explosion sfx
	var explosion_instance = EXPLOSION_SCENE.instantiate()
	get_parent().add_child(explosion_instance)
	explosion_instance.global_position = global_position
	
	var asteroid_instance_01 = ASTEROID_MEDIUM_SCENE_01.instantiate()
	get_parent().add_child(asteroid_instance_01)
	asteroid_instance_01.global_position = global_position + Vector2(randf_range(-SPAWN_OFFSET, SPAWN_OFFSET), randf_range(-SPAWN_OFFSET, SPAWN_OFFSET))
	var initial_velocity_01: Vector2 = Vector2(velocity.x * randf_range(MIN_SPAWN_ANGLE, MAX_SPAWN_ANGLE), velocity.y * randf_range(MIN_SPAWN_ANGLE, MAX_SPAWN_ANGLE))
	initial_velocity_01 = initial_velocity_01.normalized() * randf_range(MAX_SPEED * MIN_SPAWN_SPEED_MULTIPLIER, MAX_SPEED * MAX_SPAWN_SPEED_MULTIPLIER)
	asteroid_instance_01.set_velocity(initial_velocity_01)
	
	var asteroid_instance_02 = ASTEROID_MEDIUM_SCENE_01.instantiate()
	get_parent().add_child(asteroid_instance_02)
	asteroid_instance_02.global_position = global_position + Vector2(randf_range(-SPAWN_OFFSET, SPAWN_OFFSET), randf_range(-SPAWN_OFFSET, SPAWN_OFFSET))
	var initial_velocity_02: Vector2 = Vector2(velocity.x * randf_range(MIN_SPAWN_ANGLE, MAX_SPAWN_ANGLE), velocity.y * randf_range(MIN_SPAWN_ANGLE, MAX_SPAWN_ANGLE))
	initial_velocity_02 = initial_velocity_02.normalized() * randf_range(MAX_SPEED * MIN_SPAWN_SPEED_MULTIPLIER, MAX_SPEED * MAX_SPAWN_SPEED_MULTIPLIER)
	asteroid_instance_02.set_velocity(initial_velocity_02)
	
	queue_free()
