extends KinematicBody2D

# Should extend a particle script instead

var spawner
var start_velocity = 100
var direction = 0
#var lifespan = 0
var timers

# Times overlap - ie fireball despawns 4 seconds after creation
const TIME_TO_START_FLICKER = 2.5
const FLICKER_INTERVAL = 0.05
const TIME_TO_DIE = 4

onready var sprite_node = self.get_node("Sprite")


func _ready():
	set_process(true)
	start_timer("TIME_TO_START_FLICKER", TIME_TO_START_FLICKER)
	start_timer("TIME_TO_DIE", TIME_TO_DIE)
	

func _process(delta):
	if direction:
		move(Vector2(direction * start_velocity * delta, 0))
	

func set_direction(object_direction):
	print(object_direction)
	if object_direction == "right":
		direction = 1
	elif object_direction == "left":
		direction = -1
	elif object_direction == "still":
		direction = 0
	

func set_spawner(object_spawner):
	spawner = object_spawner
	

func start_timer(name, time):
	var timer = Timer.new()
	timer.connect("timeout", self, "handle_timeout", [timer, name])
	self.add_child(timer)
	timer.set_wait_time(time)
	timer.set_one_shot(true)
	timer.start()

func flicker_switch():
#	sprite_node.set_hidden(true)
	sprite_node.set_hidden(not sprite_node.is_hidden())
	

func die():
	for child in self.get_children():
		child.queue_free()
	self.queue_free()
	

func handle_timeout(timer_object, name):
	if name == "TIME_TO_START_FLICKER":
		start_timer("FLICKER_INTERVAL", FLICKER_INTERVAL)
	elif name == "FLICKER_INTERVAL":
		flicker_switch()
		start_timer("FLICKER_INTERVAL", FLICKER_INTERVAL)
	elif name == "TIME_TO_DIE":
		die()
	
	timer_object.queue_free()