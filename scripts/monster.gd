extends KinematicBody2D


var idle_anim_node
var collision_box_node


func _ready():
	idle_anim_node = get_node("IdleAnim/")
	collision_box_node = get_node("CollisionShape2D")
	idle_anim_node.play()
	

func _process(delta):
	if collision_box_node.get_colliders():
		print("oof ow ouch.")