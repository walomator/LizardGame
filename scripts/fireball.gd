extends KinematicBody2D

var start_velocity = 200
var direction

func _ready():
	set_process(true)
	print("Yeah but nothing happened")


func _process(delta):
	pass

func set_direction(object_direction):
	print("Direction set")
	if object_direction == 1 or object_direction == 0 or object_direction == -1:
		direction = object_direction
	else:
		pass