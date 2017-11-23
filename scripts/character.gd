extends KinematicBody2D


var health = 1

const SimpleTimer = preload("res://scripts/simple_timer.gd")


func start_timer(name, time):
	var simple_timer = SimpleTimer.new()
	simple_timer.start(self, name, time)
	

func set_health(monster_health):
	if monster_health > 0:
		health = monster_health
	else:
		handle_death()
	

func handle_death():
	die()
	

func die():
	self.queue_free()
	
