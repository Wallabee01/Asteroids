extends Area2D
class_name Alien

const EXPLOSION_SCENE: PackedScene = preload("res://src/components/explosion_gpu_particles_2d.tscn")
const BULLET_ALIEN_SCENE: PackedScene = preload("res://src/bullets/bullet_alien.tscn")
const MIN_SPEED: float = 50.0
const MAX_SPEED: float = 100.0
const MIN_VERT_MOVE_TIME: float = 10.0
const MAX_VERT_MOVE_TIME: float = 20.0
const MIN_VERT_MOVE_DURATION: float = 5.0
const MAX_VERT_MOVE_DURATION: float = 10.0
const MIN_SHOOT_TIME: float = 5.0
const MAX_SHOOT_TIME: float = 10.0


var moving_left: bool = true
var moving_up: bool = true
var moving_verticle: bool = false
var velocity: Vector2

@onready var verticle_move_timer = %VerticleMoveTimer
@onready var verticle_move_duration_timer = %VerticleMoveDurationTimer
@onready var shoot_timer = %ShootTimer
@onready var bullet_spawn = %BulletSpawn


func _ready():
	if randf() >= 0.5:
		moving_left = false
	
	_set_initial_velocity()
	_set_verticle_move_timer()
	_set_shoot_timer()


func _set_initial_velocity():
	if moving_left:
		velocity = Vector2(-randf_range(MIN_SPEED, MAX_SPEED), 0.0)
	else:
		velocity = Vector2(randf_range(MIN_SPEED, MAX_SPEED), 0.0)


func _set_verticle_velocity():
	if moving_up:
		velocity = Vector2(velocity.x, -randf_range(MIN_SPEED, MAX_SPEED))
	else:
		velocity = Vector2(velocity.x, randf_range(MIN_SPEED, MAX_SPEED))


func _add_score():
	GameEvents.score += 200
	GameEvents.score_changed.emit(GameEvents.score)


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


func _get_direction_to_player() -> Vector2:
	return (GameEvents.player.global_position - global_position).normalized()


func _shoot():
	var bullet_instance = BULLET_ALIEN_SCENE.instantiate()
	get_parent().get_parent().find_child("Bullets").add_child(bullet_instance)
	bullet_instance.init(_get_direction_to_player())
	bullet_instance.global_position = bullet_spawn.global_position
	shoot_timer.start()


func _set_shoot_timer():
	shoot_timer.wait_time = randf_range(MIN_SHOOT_TIME, MAX_SHOOT_TIME)
	shoot_timer.start()


func _set_verticle_move_timer():
	verticle_move_timer.wait_time = randf_range(MIN_VERT_MOVE_TIME, MAX_VERT_MOVE_TIME)
	verticle_move_timer.start()


func _on_verticle_move_timer_timeout():
	if randf() >= 0.5:
		moving_up = false
	else:
		moving_up = true
	
	_set_verticle_velocity()
	
	verticle_move_duration_timer.wait_time = randf_range(MIN_VERT_MOVE_DURATION, MAX_VERT_MOVE_DURATION)
	verticle_move_duration_timer.start()


func _on_verticle_move_duration_timer_timeout():
	velocity = Vector2(velocity.x, 0.0)
	
	_set_verticle_move_timer()


func _on_shoot_timer_timeout():
	_shoot()
	_set_shoot_timer()


func _on_area_entered(area):
	#TODO: sfx
	var explosion_instance = EXPLOSION_SCENE.instantiate()
	get_parent().add_child(explosion_instance)
	explosion_instance.global_position = global_position
	
	_add_score()
	GameEvents.alien_destroyed.emit()
	queue_free()
