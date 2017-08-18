extends StaticBody2D

signal obtained_potion

var path_to_zone_node = "Area2D/"
var path_to_scoreboard_node = "/root/World/Scoreboard/"


func _ready():
	var zone_node = get_node(path_to_zone_node)
	var scoreboard_node = get_node(path_to_scoreboard_node)
	zone_node.connect("body_enter", self, "handle_body_enter", [])
	self.connect("obtained_potion", scoreboard_node, "handle_obtained_potion", [])
	

func handle_body_enter(entered_body):
	if entered_body.is_in_group("Players"):
		handle_looting(entered_body)
	

func handle_looting(entered_body):
	if self.is_in_group("Potions"):
		emit_signal("obtained_potion")
