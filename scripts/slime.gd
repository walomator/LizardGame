extends KinematicBody2D

func _ready():
	var idle_sprite_node = get_node("Idle/")
	idle_sprite_node.play()
