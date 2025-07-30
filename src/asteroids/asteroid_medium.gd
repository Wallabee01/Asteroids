extends Asteroid


func _on_asteroid_destroyed():
	call_deferred("_spawn_asteroids", "Small")
	
	GameEvents.asteroid_destroyed.emit(50)
