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
#				  potion
# End			Defines a point where the level can be "won" (currently a flag)

extends Node2D

func _ready():
	self.set_draw_behind_parent(true)
	var objects = self.get_node("Objects")
	for tiled_object in objects.get_children():
		if "Potion" in tiled_object.get_name():
			print("There is a potion to import.")
		if "End" in tiled_object.get_name():
			print("There is a flag to import.")
	# End for
