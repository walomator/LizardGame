extends KinematicBody2D

# Perhaps particles should inherit from a high level class
var spawner
var direction = 0


# Times overlap
const START_VELOCITY = 0
const TIME_TO_START_FLICKER = 0
const FLICKER_INTERVAL = 0
const TIME_TO_DIE = 0

onready var sprite_node = self.get_node("Sprite")

var SimpleTimer = preload("res://scripts/simple_timer.gd")


func _ready():
	# Need to set fixed_process to true in subclasses
	pass
	

func _fixed_process(delta): # FEAT - Should be more dynamic
	if direction:
		move(Vector2(direction * START_VELOCITY * delta, 0))
	

func set_direction(object_direction):
	if object_direction == "right":
		direction = 1
	elif object_direction == "left":
		direction = -1
	elif object_direction == "still":
		direction = 0
	

func set_spawner(object_spawner):
	spawner = object_spawner
	

func start_timer(name, time):
	var simple_timer = SimpleTimer.new()
	simple_timer.start(self, name, time)
	

func flicker_switch():
	sprite_node.set_hidden(not sprite_node.is_hidden())
	

func die():
	self.queue_free()
	

func handle_timeout(timer_object, name):
	# Should be overloaded by subclass
	timer_object.queue_free()