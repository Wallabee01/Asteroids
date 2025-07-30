extends Node2D  

const DEATH_SFX_01: AudioStream = preload("res://assets/audio/sfx/explosion1.ogg")
const DEATH_SFX_02: AudioStream = preload("res://assets/audio/sfx/explosion2.ogg")
const DEATH_SFX_03: AudioStream = preload("res://assets/audio/sfx/explosion3.ogg")
const DEATH_SFX_04: AudioStream = preload("res://assets/audio/sfx/explosion4.ogg")
const DEATH_SFX_05: AudioStream = preload("res://assets/audio/sfx/explosion5.ogg")
const EXPLOSION_SCENE: PackedScene = preload("res://src/components/explosion_gpu_particles_2d.tscn")
const BULLET_SCENE: PackedScene = preload("res://src/bullets/bullet.tscn")
const ROTATION_SPEED = 3.0        # radians per second
const ACCELERATION = 100.0
const MAX_SPEED = 200.0
const SIZE_OFFSET: Vector2 = Vector2(8.0 / 2.0, 16.0 / 2.0)

var start_pos: Vector2
var velocity = Vector2.ZERO
var is_exploding: bool = false

@onready var gpu_particles_2d = %GPUParticles2D
@onready var shoot_timer = %ShootTimer
@onready var bullet_spawn = %BulletSpawn
@onready var animation_player = %AnimationPlayer
@onready var death_stream_player = %DeathStreamPlayer
@onready var shoot_stream_player = %ShootStreamPlayer
@onready var thrust_stream_player = %ThrustStreamPlayer


func _ready():
	start_pos = global_position
	GameEvents.player = self


func _physics_process(delta):
	if Input.is_action_pressed("turn_left") && !is_exploding:
		rotation -= ROTATION_SPEED * delta
	elif Input.is_action_pressed("turn_right") && !is_exploding:
		rotation += ROTATION_SPEED * delta
	
	if Input.is_action_pressed("thrust") && !is_exploding:
		thrust_stream_player.play()
		var direction = Vector2.UP.rotated(rotation)
		velocity += direction * ACCELERATION * delta
		gpu_particles_2d.emitting = true
	if Input.is_action_just_released("thrust"):
		thrust_stream_player.stop()
		gpu_particles_2d.emitting = false
	
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED
	
	global_position += velocity * delta
	
	if Input.is_action_pressed("shoot") && shoot_timer.is_stopped() && !is_exploding:
		_shoot()
	
	_handle_screen_wrap()


func _shoot():
	shoot_stream_player.pitch_scale = randf_range(0.9, 1.1)
	shoot_stream_player.play()
	
	var bullet_instance = BULLET_SCENE.instantiate()
	get_parent().find_child("Bullets").add_child(bullet_instance)
	bullet_instance.init(Vector2.UP.rotated(rotation))
	bullet_instance.global_position = bullet_spawn.global_position
	shoot_timer.start()


func _reset():
	global_position = start_pos
	velocity = Vector2.ZERO
	rotation = 0.0


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


func _on_area_2d_area_entered(_area):
	if !is_exploding:
		GameEvents.ship_destroyed.emit()
		
		var death_sound_roll: float = randf()
		if death_sound_roll >= 0.0 && death_sound_roll < 0.2:
			death_stream_player.stream = DEATH_SFX_01
		elif death_sound_roll >= 0.2 && death_sound_roll < 0.4:
			death_stream_player.stream = DEATH_SFX_02
		elif death_sound_roll >= 0.4 && death_sound_roll < 0.6:
			death_stream_player.stream = DEATH_SFX_03
		elif death_sound_roll >= 0.6 && death_sound_roll < 0.8:
			death_stream_player.stream = DEATH_SFX_04
		elif death_sound_roll >= 0.8 && death_sound_roll <+ 1.0:
			death_stream_player.stream = DEATH_SFX_05
		death_stream_player.play()
		
		#TODO: Keep or remove explosion?
		var explosion_instance = EXPLOSION_SCENE.instantiate()
		get_parent().add_child(explosion_instance)
		explosion_instance.global_position = global_position
		
		gpu_particles_2d.emitting = false
		animation_player.play("death")
		is_exploding = true
		await animation_player.animation_finished
		is_exploding = false
