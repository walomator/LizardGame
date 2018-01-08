extends KinematicBody2D


const GRAVITY = 0

var collision_box_node
var is_weighted = false
var health = 1

const SimpleTimer = preload("res://scripts/simple_timer.gd")

func _ready():
#	set_fixed_process(true)
	pass
	

func _fixed_process(delta):
	if is_weighted == true:
		pass

func start_timer(name, time):
	var simple_timer = SimpleTimer.new()
	simple_timer.start(self, name, time)
	

func _set_health(character_health):
	if character_health > 0:
		health = character_health
	else:
		handle_death()
	
func _set_is_weighted(char_is_weighted):
	is_weighted = char_is_weighted
	

func get_health():
	return health
	

func handle_death():
	die()
	

func die():
	self.queue_free()
	
