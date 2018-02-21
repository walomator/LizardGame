extends Node2D

signal obtained_potion
signal passed_end_level

var path_to_zone_node = "Area2D/"
var path_to_scoreboard_node = "/root/World/Scoreboard/"


func _ready():
	var zone_node = get_node(path_to_zone_node)
	var scoreboard_node = get_node(path_to_scoreboard_node)
	zone_node.connect("body_entered", self, "handle_body_entered", [])
	self.connect("obtained_potion", scoreboard_node, "handle_obtained_potion", [])
	self.connect("passed_end_level", scoreboard_node, "handle_passed_end_level", [])
	

func handle_body_entered(entered_body):
	if entered_body.is_in_group("Players"):
		if self.is_in_group("Items"):
			handle_looting(entered_body)
		if self.is_in_group("Flags"):
			handle_flag_passing(entered_body)
	

func handle_looting(entered_body):
	if self.is_in_group("Potions"):
		emit_signal("obtained_potion")
	self.queue_free()

func handle_flag_passing(entered_body):
	if self.is_in_group("EndLevel"):
		emit_signal("passed_end_level")
	