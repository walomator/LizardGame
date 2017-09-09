extends "monster.gd"
# parent class has _fixed_process

const BOUNCINESS = 200
const MAX_HEALTH = 2
const FLICKER_INTERVAL = 0.01
const PLAY_DEAD_TIME = 0.4


func _ready():
	set_health(MAX_HEALTH)
	

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
	

func handle_player_hit_enemy_top(player, enemy):
	set_health(get_health() - 1) # FEAT - Should be dependent on player's damage
	

func handle_player_hit_enemy_side(player, enemy):
	pass
	

func handle_timeout(object_timer, name):
	if name == "death":
		die()
	elif name == "flicker":
		flicker_switch()
		start_timer("flicker", FLICKER_INTERVAL)
	object_timer.queue_free()
	

func die():
	self.queue_free()
	
