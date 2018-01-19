extends "character.gd"


# Times overlap - ie fireball despawns 4 seconds after creation
const START_VELOCITY = 0
const TIME_TO_START_FLICKER = 0
const FLICKER_INTERVAL = 0
const TIME_TO_DIE = 0

# Perhaps particles should inherit from a high level class
var spawner # Use node type
var direction = 0

onready var sprite_node = self.get_node("Sprite")

var SimpleTimer = preload("res://scripts/simple_timer.gd")


func _ready():
	# Need to set fixed_process to true in subclasses
	pass
	

func _fixed_process(delta): # FEAT - Should be more dynamic
	if direction:
		move(Vector2(direction * velocity.x * delta, 0))
	

func set_velocity(particle_velocity):
	velocity = Vector2(particle_velocity, 0)
	

func set_direction(object_direction):
	direction = object_direction
	

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
	