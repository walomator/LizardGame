extends "particle.gd"

signal body_collided

var START_VELOCITY = 100
const TIME_TO_START_FLICKER = 0
const FLICKER_INTERVAL = 0.05
const TIME_TO_DIE = 0

onready var is_pulling = false
var path_to_zone_node = "Area2D/"


func _ready():
	set_velocity(START_VELOCITY)
	set_fixed_process(true)
	var zone_node = get_node(path_to_zone_node) # DEV - Particles should possibly have a parent class that has zones
	zone_node.connect("body_enter", self, "handle_body_enter", [])
	

func fixed_process(delta):
	if is_colliding():
		handle_body_colliding(get_collider())
	if is_pulling == true:
		pass
	

func handle_body_enter(entered_body):
	if entered_body.is_in_group("Tiles"):
		set_velocity(0)
	
