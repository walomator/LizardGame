extends Node

# This is a class similar to an array, but can have some extra functionality

# Possible extra functionality:
# Store combos and emit signal when combo is complete
# That's all I can think of for now
# It's possible it could handle all input
# Or I might go back to using a simple array
var valid_actions = ["right", "left", "up", "down"]
var active_actions = []

func _ready():
	pass


func add(action):
	if (action in valid_actions) and not (action in active_actions):
		active_actions.append(action)
#		print("Added action: ", action)
	

func remove(action):
	if action in valid_actions:
		active_actions.erase(action)
#		print("Removed action: ", action)
	

func clear():
	active_actions = []
	

func get_actions():
	return active_actions