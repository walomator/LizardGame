extends KinematicBody2D


var idle_anim_node
var collision_box_node
var monster_type

#var Monster


func _ready():
	set_fixed_process(true)
	monster_type = get_name()
	# Stop what you're doing and use subclasses instead
#	_set_monster_class(monster_type)
	
	idle_anim_node = get_node("IdleAnim/")
	collision_box_node = get_node("CollisionShape2D")
	idle_anim_node.play()
	

func _fixed_process(delta):
	if get_collider():
		print("Oof ow ouch.")
	

func _set_monster_class(type):
#	if type == "Slime":
#		Monster = load("res://scripts/slime.gd")
#	elif type == "Goblin":
#		Monster = load("res://scripts/goblin.gd")
#	else:
#		pass # Should have a fallback to prevent crashes
	pass
