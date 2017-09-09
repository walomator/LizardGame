extends KinematicBody2D

signal body_collided

onready var collision_handler_node = get_node("/root/World/CollisionHandler")
onready var sound_node = get_node("Sound") 
var idle_anim_node
var collision_box_node
var health = 1

const BOUNCINESS = 100

const SimpleTimer = preload("res://scripts/simple_timer.gd")

func _ready():
	set_fixed_process(true)
	
	self.connect("body_collided", collision_handler_node, "handle_body_collided")
	
	idle_anim_node = get_node("IdleAnim/")
	collision_box_node = get_node("CollisionShape2D")
	idle_anim_node.play()
	

func _fixed_process(delta):
#	move(Vector2(5, 0)*delta)
	if is_colliding():
		if get_collider().is_in_group("Players"):
			emit_signal("body_collided", self, get_collider(), get_collision_normal())
	

func get_health():
	return health
	

func get_bounciness():
	return BOUNCINESS
	

func set_health(monster_health):
	if monster_health > 0:
		health = monster_health
	else:
		handle_death()
	

func start_timer(name, time):
	var simple_timer = SimpleTimer.new()
	simple_timer.start(self, name, time)
	

func handle_timeout():
	pass # Overloaded in subclass
	

func handle_death():
	die()
	

func flash(mode):
	pass
	

func die():
	self.queue_free()
	
