extends KinematicBody2D
var health = 1


func set_health(monster_health):
	if monster_health > 0:
		health = monster_health
	else:
		handle_death()
	

func handle_death():
	die()
	

func die():
	self.queue_free()
	



