extends Area2D
class_name Bullet

const ACCELERATION = 10000.0
const MAX_SPEED = 750.0

var velocity: Vector2
var direction


func init(dir: Vector2):
	direction = dir


func _physics_process(delta):
	velocity += direction * ACCELERATION * delta
	
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED
	
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


func _on_timer_timeout():
	queue_free()
