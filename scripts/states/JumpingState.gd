extends Node

# This state describes any in which the player is in the air, including falling
# after running off a ledge. It is not limited to voluntarily jumping.

# Buglist
# Mid-air Freeze
#   The player goes back to a standing animation despite being in JumpingState
#   When running off a ledge

var is_grounded = true
var player
var state_name = "JumpingState"

func _init(controlled_player):
	player = controlled_player
	

func start():
	player.move_anim_node.stop()
	player.fall_anim_node.play()
	player.idle_sprite_node.visible = false
	player.move_anim_node.visible = false
	player.fall_anim_node.visible = true

func state_process(delta):
	# Set velocity caused by player input for handling by character.gd
	player.set_controller_velocity(Vector2(player.run_speed, 0))
	
	if is_on_ground(): # BUG - This returns true instantly, b/c player is on floor
		player.set_state("StandingState")
	

func jump():
	pass # FEAT - Allow for double jumps or holding jumps
	

func get_name():
	return state_name
	

func is_on_ground(): # DEV - Should check if player just jumped
	return player.test_move(player.get_transform(), Vector2(0, 1))
	