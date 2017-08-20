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
	current_map.set_script(map_loader_script)
	self.add_child(current_map) # The ordering of the nodes is important, and will cause errors
	