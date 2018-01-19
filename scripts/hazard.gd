extends "character.gd"

# Hazards have collision and deal damage
# Hazards inherit from characters
# Traps do not have collision and can trigger events

var sprite_node
var damage = 1

func _ready():
	pass
	

func _set_damage(new_damage):
	damage = new_damage
	

func get_damage():
	return damage
	