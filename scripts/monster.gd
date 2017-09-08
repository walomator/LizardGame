extends KinematicBody2D


onready var collision_handler_node = get_node("/root/World/CollisionHandler")
var idle_anim_node
var collision_box_node
var monster_type
var health = 1

const BOUNCINESS = 100

signal body_collided


func _ready():
	set_fixed_process(true)
	
	self.connect("body_collided", collision_handler_node, "handle_body_collided")
	monster_type = get_name()
	
	idle_anim_node = get_node("IdleAnim/")
	collision_box_node = get_node("CollisionShape2D")
	idle_anim_node.play()
	

func _fixed_process(delta):
#	move(Vector2(5, 0)*delta)
	if is_colliding():
		if get_collider().is_in_group("Players"):
			emit_signal("body_collided", self, get_collider(), get_collision_normal())
	

func get_health():
	return health
	

func get_bounciness():
	return BOUNCINESS
	

func set_health(monster_health):
	if monster_health > 0:
		health = monster_health
	else:
		flash("death")
	

func flash(mode):
	if mode == "death":
		print("Enemy defeated.")
		die()
	

func die():
	self.queue_free()
	
