extends Node2D  

const BULLET_SCENE: PackedScene = preload("res://src/bullet/bullet.tscn")
const ROTATION_SPEED = 3.0        # radians per second
const ACCELERATION = 100.0
const MAX_SPEED = 100.0
const FRICTION = 0.98

@onready var gpu_particles_2d = %GPUParticles2D
@onready var shoot_timer = %ShootTimer
@onready var bullet_spawn = %BulletSpawn

var velocity = Vector2.ZERO


func _physics_process(delta):
	if Input.is_action_pressed("turn_left"):
		rotation -= ROTATION_SPEED * delta
	elif Input.is_action_pressed("turn_right"):
		rotation += ROTATION_SPEED * delta
	
	if Input.is_action_pressed("thrust"):
		var direction = Vector2.UP.rotated(rotation)
		velocity += direction * ACCELERATION * delta
		gpu_particles_2d.emitting = true
	if Input.is_action_just_released("thrust"):
		gpu_particles_2d.emitting = false
	
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED
	
	global_position += velocity * delta
	
	if Input.is_action_pressed("shoot") && shoot_timer.is_stopped():
		var direction = Vector2.UP.rotated(rotation)
		var bullet_instance = BULLET_SCENE.instantiate()
		get_parent().find_child("Bullets").add_child(bullet_instance)
		bullet_instance.init(Vector2.UP.rotated(rotation))
		bullet_instance.global_position = bullet_spawn.global_position
		shoot_timer.start()
	
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
