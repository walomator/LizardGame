extends "particle.gd"


signal body_collided

const START_VELOCITY = 100

var is_pulling = false
var path_to_zone_node = "Area2D/"


func _ready():
	set_velocity(START_VELOCITY)
#	set_fixed_process(true)
	var zone_node = get_node(path_to_zone_node) # DEV - Particles should possibly have a parent class that has zones
	zone_node.connect("body_enter", self, "handle_body_enter", [])
	

func handle_body_enter(entered_body):
	if entered_body.is_in_group("Tiles"):
		set_velocity(0)
	