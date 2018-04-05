extends Node

# This state describes when a player has been stunned. It is up to an
# externally set timer to release the player from this state.
var player
var state_name = "StunnedState"

func _init(controlled_player):
	player = controlled_player
	player.set_controller_velocity(Vector2(0, 0))


func start():
	player.idle_sprite_node.visible = true


func state_process(delta):
	pass


func set_state(new_state): # Should be called externally by a timer
	player.idle_sprite_node.visible = false
	player.set_state(new_state)


func jump():
	pass


func get_name():
	return state_name


func is_in_air():
	return not player.test_move(player.get_transform(), Vector2(0, 1))
