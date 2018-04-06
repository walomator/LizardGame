extends Node

var exiting = false # Prevents double state-setting
var is_grounded = true # DEV - Not currently implemented, but may solve the jumping problem
var player
var state_name = "RunningState"

func _init(controlled_player):
	player = controlled_player
	

func start():
	player.move_anim_node.play()
	player.move_anim_node.visible = true
	

func state_process(delta):
	if not player.is_moving:
		set_state("StandingState")
	
	if is_in_air():
		set_state("JumpingState")
	
	# Set velocity caused by player input for handling by character.gd
	player.set_controller_velocity(Vector2(player.run_speed, 0))
	

func handle_timeout(timer_name):
	pass
	

func set_state(new_state):
	if exiting == true:
		return
	exiting = true
	
	player.move_anim_node.stop()
	player.move_anim_node.visible = false
	player.set_state(new_state)
	

func jump():
	player.default_jump()
	set_state("JumpingState")
	

func get_name():
	return state_name
	

func is_in_air():
	return not player.test_move(player.get_transform(), Vector2(0, 1))
	