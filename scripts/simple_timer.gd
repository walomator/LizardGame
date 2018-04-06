extends Node2D

func _ready():
	pass
	

func start(initiator, timer_name, time):
	var timer = Timer.new()
	timer.connect("timeout", initiator, "handle_timeout", [timer, timer_name])
	initiator.add_child(timer)
	timer.set_wait_time(time)
	timer.set_one_shot(true)
	timer.start()
	