extends "monster.gd"
# parent class has _fixed_process

const BOUNCINESS = 150
const MAX_HEALTH = 3
const FLICKER_INTERVAL = 0.01
const PLAY_DEAD_TIME = 0.4


func _ready():
	set_health(MAX_HEALTH)
	set_fixed_process(true)
	
	self.connect("body_collided", collision_handler_node, "handle_body_collided")
	
	idle_anim_node = get_node("IdleAnim/")
	collision_box_node = get_node("CollisionShape2D")
	idle_anim_node.play()
	

func handle_death():
	start_timer("death", PLAY_DEAD_TIME)
	play_dead()
	

func play_dead():
	flicker("death")
	sound_node.play("death")
	

func flicker(mode):
	if mode == "death":
		start_timer("flicker", FLICKER_INTERVAL)
	

func flicker_switch():
	idle_anim_node.set_hidden(not idle_anim_node.is_hidden())
	

func handle_timeout(object_timer, name):
	if name == "death":
		die()
	elif name == "flicker":
		flicker_switch()
		start_timer("flicker", FLICKER_INTERVAL)
	object_timer.queue_free()
	

func die():
	self.queue_free()
	
