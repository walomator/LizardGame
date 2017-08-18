extends StaticBody2D

var path_to_zone_node = "Area2D/"

func _ready():
	var zone_node = get_node(path_to_zone_node)
	zone_node.connect("body_enter", self, "handle_body_enter")
	

func handle_body_enter(entered_body):
	print("Hey world!")