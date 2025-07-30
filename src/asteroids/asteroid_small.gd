extends Asteroid


func _on_area_entered(area):
	area.queue_free()
	#TODO: Explosion sfx
	var explosion_instance = EXPLOSION_SCENE.instantiate()
	get_parent().add_child(explosion_instance)
	explosion_instance.global_position = global_position
	
	GameEvents.asteroid_destroyed.emit(100)
	
	call_deferred("queue_free")
