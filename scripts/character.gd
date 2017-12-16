extends KinematicBody2D


var collision_box_node
var health = 1

const SimpleTimer = preload("res://scripts/simple_timer.gd")


func start_timer(name, time):
	var simple_timer = SimpleTimer.new()
	simple_timer.start(self, name, time)
	

func _set_health(character_health):
	if character_health > 0:
		health = character_health
	else:
		handle_death()
	

func get_health():
	return health
	

func handle_death():
	die()
	

func die():
	self.queue_free()
	
