extends Node2D

const path_to_maps = "res://scenes/maps/"
const current_map_name = "map-test"
const path_to_current_map = path_to_maps + current_map_name + ".scn/"
var current_map_scene = preload(path_to_current_map)
var current_map

const path_to_scripts = "res://scripts/"
const path_to_map_loader_script = path_to_scripts + "map_loader.gd/"
var map_loader_script = preload(path_to_map_loader_script)

func _ready():
	current_map = current_map_scene.instance()
	print("current_map has been instanced from the scene " + current_map_name + ".scn.")
	print("Here's the scene variable:")
	print(current_map_scene)
	print("And here's the object:")
	print(current_map)
	
	print("")
	print("Now, trying to set the script object from preload(path_to_map_loader_script).")
	print("Here's the script (a resource):")
	print(map_loader_script)
	current_map.set_script(map_loader_script)
	
	print("")
	print("Attempted current_map.set_script(map_loader_script)")
	print("However, it doesn't work if there isn't a dialog below saying map_loader_script was run.")
	print(" v v v ")
	self.add_child(current_map) # The ordering of the nodes is important, and will cause errors
	
	print("")
	print("current_map was just added as a child to the scene this script runs off of, World.tscn")
	print("It is assumed that only after this happens will the script run. Possibly incorrect assumption") 
	