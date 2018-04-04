extends Node

var is_grounded = true # DEV - Not currently implemented, but may solve the jumping problem
var player
var state_name = "StandingState"

func _init(controlled_player):
	player = controlled_player
	

func start():
	player.move_anim_node.stop()
	player.fall_anim_node.stop()
	player.idle_sprite_node.visible = true
	player.move_anim_node.visible = false
	player.fall_anim_node.visible = false
	
	player.jump_count = 0
	

func state_process(delta):
	# Set velocity caused by player input for handling by character.gd
	player.set_controller_velocity(Vector2(player.run_speed, 0))
	
	if is_in_air():
		player.set_state("JumpingState")
	

func update_direction():
	pass
	

func jump():
	player.default_jump()
	player.set_state("JumpingState")
	

func get_name():
	return state_name
	

func is_in_air():
	return not player.test_move(player.get_transform(), Vector2(0, 1))
	