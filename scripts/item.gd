extends StaticBody2D

var path_to_zone_node = "Area2D/"
var path_to_scoreboard_node = "/root/World/Scoreboard/"
var type = "NULL"
var valid_types = ["POTION", "WEAPON"]

func _ready():
	var zone_node = get_node(path_to_zone_node)
	var scoreboard_node = get_node(path_to_scoreboard_node)
	zone_node.connect("body_enter", self, "handle_body_enter")
	self.connect("obtained_potion", scoreboard_node, "handle_obtained_potion")
	

func handle_body_enter(entered_body):
	if entered_body.is_in_group("Players"):
		handle_looting(entered_body)
	

func set_item_type(item_type):
	if valid_types.has(item_type):
		type = item_type
	

func handle_looting(entered_body):
	if type == "POTION":
		emit_signal("obtained_potion")
