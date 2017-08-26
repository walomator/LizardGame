extends Node

var valid_actions = ["right", "left", "up"]
var active_actions = []

func _ready():
	pass


func add(action):
	if action in valid_actions:
		active_actions.append(action)
	

func get_actions():
	return active_actions