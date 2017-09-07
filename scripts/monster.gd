extends KinematicBody2D


var idle_anim_node
var collision_box_node
var monster_type

signal collided_with_body


func _ready():
	set_fixed_process(true)
	monster_type = get_name()
	
	idle_anim_node = get_node("IdleAnim/")
	collision_box_node = get_node("CollisionShape2D")
	idle_anim_node.play()
	

func _fixed_process(delta):
#	move(Vector2(5, 0)*delta)
	if is_colliding():
		print("Oof ow ouch.")
	

func flash(mode):
	if mode == "death":
		print("Enemy defeated.")
		die()
	

func die():
	for child in get_children():
		child.queue_free() # BUG - Is this necessary?
	self.queue_free()


