extends KinematicBody2D
# Should extend a particle script instead

var spawner
var start_velocity = 100
var direction = 0
var lifespan = 0
var extinguish_time = 5


func _ready():
	set_process(true)


func _process(delta):
	if direction:
		move(Vector2(direction * start_velocity * delta, 0))
	lifespan += delta
	if lifespan >= extinguish_time:
		direction = 0

func set_direction(object_direction):
	if object_direction == "right":
		direction = 1
	elif object_direction == "left":
		direction = -1
	elif object_direction == "still":
		direction = 0
	

func set_spawner(object_spawner):
	spawner = object_spawner