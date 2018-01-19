extends "character.gd"

signal body_collided

onready var collision_handler_node = get_node("/root/World/CollisionHandler")
onready var sound_node = get_node("Sound") 
var idle_anim_node

var bounciness = 100
var damage     = 1

const SimpleTimer = preload("res://scripts/simple_timer.gd")

func _ready():
	set_fixed_process(true)
	
	self.connect("body_collided", collision_handler_node, "handle_body_collided")
	
	idle_anim_node = get_node("IdleAnim/")
	collision_box_node = get_node("CollisionShape2D")
	idle_anim_node.play()
	

func _fixed_process(delta):
	if is_colliding():
		if get_collider().is_in_group("Players"):
			emit_signal("body_collided", self, get_collider(), get_collision_normal())
	

func _set_bounciness(new_bounciness):
	bounciness = new_bounciness
	

func _set_damage(new_damage):
	damage = new_damage
	

func get_bounciness():
	return bounciness
	

func get_damage():
	return damage
	

func start_timer(name, time):
	var simple_timer = SimpleTimer.new()
	simple_timer.start(self, name, time)
	

func handle_timeout():
	pass # Overloaded in subclass
	

func handle_player_hit_enemy_top(player, enemy):
	_set_health(get_health() - 1) # FEAT - Should be dependent on player's damage
	

func handle_player_hit_enemy_side(player, enemy, normal):
	pass
	

func handle_death():
	die()
	

func flash(mode):
	pass
	