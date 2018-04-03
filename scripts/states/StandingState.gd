extends Node

var is_grounded = true
var player

func _init(controlled_player):
	player = controlled_player
	

func _ready():
	pass

func state_process(delta):
	# Set additional velocity caused by player input
	player.set_controller_velocity(Vector2(player.run_speed, 0))
	

func update_direction():
	pass