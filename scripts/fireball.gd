extends "particle.gd"

# Times overlap - ie fireball despawns 4 seconds after creation
const START_VELOCITY = 200
const TIME_TO_START_FLICKER = 1
const FLICKER_INTERVAL = 0.05
const TIME_TO_DIE = 1.4


func _ready():
	set_fixed_process(true)
	start_timer("TIME_TO_START_FLICKER", TIME_TO_START_FLICKER)
	start_timer("TIME_TO_DIE", TIME_TO_DIE)
	

func handle_timeout(timer_object, name):
	if name == "TIME_TO_START_FLICKER":
		start_timer("FLICKER_INTERVAL", FLICKER_INTERVAL)
	elif name == "FLICKER_INTERVAL":
		flicker_switch()
		start_timer("FLICKER_INTERVAL", FLICKER_INTERVAL)
	elif name == "TIME_TO_DIE":
		die()
	
	timer_object.queue_free()