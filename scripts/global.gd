extends Node2D

var root_node
var player_node
#var center_box_node
var resolution

enum {TOP, BOTTOM, LEFT, RIGHT}

func _ready():
	root_node = get_node("/root/")
	player_node = get_node("/root/World/Protagonist/")
#	center_box_node = get_node("/root/World/CenterBox")
	
	resolution = Vector2(Globals.get("display/width"), Globals.get("display/height"))
	
	root_node.connect("size_changed", self, "handle_size_changed")
	
	var canvas_transform = get_viewport().get_canvas_transform()
	canvas_transform[2] = -(player_node.get_pos() - resolution / 2)
	get_viewport().set_canvas_transform(canvas_transform)
	

func handle_size_changed():
	pass
	

func handle_shutdown():
	print("Shutting down")
	get_tree().quit()
	

func camera_move(offset):
	var canvas_transform = get_viewport().get_canvas_transform()
	canvas_transform[2] -= offset
	get_viewport().set_canvas_transform(canvas_transform)
	

func handle_exited_center_box(center_box):
	var offset = center_box.get_offset()
	camera_move(offset)
	
#	print("Exited box. Here's how far out you are:")
#	print(offset)


