extends Node2D

var root_node
var player_node

enum {TOP, BOTTOM, LEFT, RIGHT}

func _ready():
	root_node = get_node("/root/")
	player_node = get_node("/root/World/Protagonist/")
	
	root_node.connect("size_changed", self, "handle_size_changed")
	

func handle_size_changed():
	pass
	

func handle_shutdown():
	print("Shutting down")
	get_tree().quit()
	

func camera_move(offset_vector):
	var canvas_transform = get_viewport().get_canvas_transform()
	canvas_transform.y += offset_vector
	canvas_transform.y = -canvas_transform.y
	get_viewport().set_canvas_transform(canvas_transform)
	

func handle_exited_center_box(direction):
	camera_move(direction)
	print("Signal received.")


