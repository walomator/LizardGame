extends KinematicBody2D


var health = 1

const SimpleTimer = preload("res://scripts/simple_timer.gd")


func start_timer(name, time):
	var simple_timer = SimpleTimer.new()
	simple_timer.start(self, name, time)
	

func get_health():
	return health
	

func set_health(character_health):
	if character_health > 0:
		health = character_health
	else:
		handle_death()
	

func handle_death():
	die()
	

func die():
	self.queue_free()
	
