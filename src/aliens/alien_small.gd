extends Alien

const MIN_SPEED_SMALL: float = 75.0
const MAX_SPEED_SMALL: float = 150.0
const MIN_SHOOT_TIME_SMALL: float = 2.5
const MAX_SHOOT_TIME_SMALL: float = 5.0


func _set_initial_velocity():
	if moving_left:
		velocity = Vector2(-randf_range(MIN_SPEED_SMALL, MAX_SPEED_SMALL), 0.0)
	else:
		velocity = Vector2(randf_range(MIN_SPEED_SMALL, MAX_SPEED_SMALL), 0.0)


func _set_verticle_velocity():
	if moving_up:
		velocity = Vector2(velocity.x, -randf_range(MIN_SPEED_SMALL, MAX_SPEED_SMALL))
	else:
		velocity = Vector2(velocity.x, randf_range(MIN_SPEED_SMALL, MAX_SPEED_SMALL))


func _set_shoot_timer():
	shoot_timer.wait_time = randf_range(MIN_SHOOT_TIME_SMALL, MAX_SHOOT_TIME_SMALL)
	shoot_timer.start()


func _add_score():
	GameEvents.score += 1000
	GameEvents.score_changed.emit(GameEvents.score)
