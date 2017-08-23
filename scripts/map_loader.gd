# NOTE! THE BELOW MESSAGE WAS WRITTEN TO DESCRIBE AN IMPLEMENTATION BEFORE
# IT WAS IMPLEMENTED! THE BELOW IS NOT TRUE YET AND IS THERE TO SERVE AS A
# PROGRAMMER'S GUIDE
#
# This script is designed to make importing maps from Tiled map editor easy and
#   as a result, the successfully converted Tiled tilemaps (using vnen's
#   Tiled importer) should not be edited in Godot. This may come to be a
#   foolish design decision, as the importer isn't perfect. If that is the
#   case, this script doesn't have to be loaded onto maps.
#
# To make a map correctly in Tiled, simply make sure tilesets have the
#   collision boxes you wish for, be sure to include for now a Background and
#   Foreground layer, and add objects in the Objects layer for various effects,
#   Which are determined by the object's NAME.
# A texture for objects is not necessary. They will be set with this script
#   regardless of what texture you give them in Tiled, because they are
#   incorrectly imported.
# It is not clear whether custom properties will become importable in the
#   future (supposedly they are now "as metadata"), but the programmers don't
#   know how to access these custom properties and so they should not be used.
#
# To make a potion, for example, simply create a new object and name it
#   "Potion". This should be sufficient for a successful import.
#
# VALID OBJECT NAMES															|
# Potion		A delicious cherry red (healing) (but really point giving)
#				  potion. Box is resized to 32x32 from the top left orig pos
# End			Defines a point where the level can be "won" (currently a flag)
# Slime			Enemy
# Goblin		Enemy
#

extends Node2D

const potion_scene = preload("res://scenes/items/Potion.tscn/")
const end_level_scene = preload("res://scenes/effects/EndLevel.tscn/")
const slime_scene = preload("res://scenes/monsters/slime/Slime.tscn/")
const goblin_scene = preload("res://scenes/monsters/goblin/Goblin.tscn/")
#const test_scene = preload("res://scenes/Test.tscn")

func _ready():
	self.set_draw_behind_parent(true)
	var objects = self.get_node("Objects")
	for tiled_object in objects.get_children():
#		print(tiled_object.get_name())
		if "Potion" in tiled_object.get_name():
			print("There is a potion to import.")
			set_potion(tiled_object)
			
		if "End" in tiled_object.get_name():
			print("There is a flag to import.")
			set_flag("End", tiled_object)
			
		if "Slime" in tiled_object.get_name():
			print("There is a goblin to import.")
			set_monster("Slime", tiled_object)
			
		if "Goblin" in tiled_object.get_name():
			print("There is a goblin to import.")
			set_monster("Goblin", tiled_object)
			
	# End for
	
#	var test_node = self.get_node("Objects").get_node("Potion")
#	test_node.replace_by(test_node) 
#	print("Replacing the first potion as a test.")
	
	save_scene("res://scenes/maps/TempSceneName.tscn")
	

func set_potion(tiled_object):
	_replace_object(tiled_object, potion_scene)
#	tiled_object.replace_by(potion_node) # Only replaces one node with another, independent of children
	
	

func set_flag(flag_name, tiled_object):
	
	if flag_name == "End":
		_replace_object(tiled_object, end_level_scene)

func set_monster(monster_name, tiled_object):
	# Could a dictionary be used here?
	if monster_name == "Goblin":
		_replace_object(tiled_object, goblin_scene)
	if monster_name == "Slime":
		_replace_object(tiled_object, slime_scene)

#	var object_pos = tiled_object.get_node("CollisionShape2D").get_global_pos()
#	tiled_object.queue_free()
#	
#	var slime_node = slime_scene.instance()
#	self.add_child(slime_node)
#	slime_node.set_pos(object_pos)
	

func _replace_object(tiled_object, target_scene):
	var object_pos = tiled_object.get_node("CollisionShape2D").get_global_pos()
	tiled_object.queue_free()
	
	var target_node = target_scene.instance()
	self.add_child(target_node)
	target_node.set_pos(object_pos)

func save_scene(scene_save_path):
#	print("Packing current scene.")
	var packed_scene = PackedScene.new()
#	packed_scene.pack(get_node("/root/World/map-test"))
	packed_scene.pack(self)
	
	ResourceSaver.save(scene_save_path, packed_scene)
	
	print("Saving packed scene to " + scene_save_path)