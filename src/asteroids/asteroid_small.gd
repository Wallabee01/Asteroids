extends Asteroid


func _on_asteroid_destroyed():
	GameEvents.asteroid_destroyed.emit(100)
