extends "character.gd"

#onready var sound_node = get_node("Sound")
var sprite_node
var damage = 1

func _ready():
	pass
	

func _set_damage(new_damage):
	damage = new_damage
	

func get_damage():
	return damage