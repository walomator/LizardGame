extends KinematicBody2D

func _ready():
	var idle_anim_node = get_node("IdleAnim/")
	idle_anim_node.play()
