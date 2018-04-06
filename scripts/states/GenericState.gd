extends Node

# This state is a generic. All functions already included are essential and
# must include "pass" if nothing else. Logic in functions are mostly essential.
# Leave the vars 'exiting' and 'player' as they are. Change 'state_name' and
# otherwise add more variables as necessary.

# Must also add the following to player.gd:
# -----------------------------------------------------------------------------
#const StandingState = preload("res://scripts/states/StandingState.gd")
#
#...
#func set_state(new_state):
#	...
#	elif new_state == "RunningState":
#		state = GenericState.new(self)
#	...
# -----------------------------------------------------------------------------

var exiting = false # Prevents double state-setting
var player
var state_name = "GenericState" # Must match class name without ".gd"

func _init(controlled_player):
	player = controlled_player
	

func start():
	player.idle_sprite_node.visible = true # Must make something visible
	

func state_process(delta): # Called every _process(d) of the player
	pass
	

func handle_timeout(timer_name): # Called by timer after it times out
	pass
	

func set_state(new_state):
	if exiting == true:
		return
	exiting = true
	
	player.idle_sprite_node.visible = false # Must hide everything previously set visible
	player.set_state(new_state)
	

func jump():
	player.default_jump()
	

func get_name():
	return state_name
	