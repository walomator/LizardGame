extends Area2D

signal exited_center_box

var player_body
var global_node
var extents
var direction = Vector2(0, 0)

func _ready():
	player_body = get_node("/root/World/Protagonist/")
	global_node = get_node("/root/Global/")
	
	extents = Vector2(get_node("CollisionShape2D").get_shape().get_extents())
	
	self.connect("body_exit", self, "handle_body_exit")
	self.connect("exited_center_box", global_node, "handle_exited_center_box", [direction])
	

func handle_body_exit(exiting_body):
	if exiting_body == player_body:
		emit_signal("exited_center_box")
	