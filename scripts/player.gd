extends "character.gd"


# Buglist
# Running Man Bug
#	Replicable: y
#	Sprites for protagonist's running animation don't align with idle
#	Fix: edit animation frames

# Sticky Walls and Floors
#	Replicable: y
#	Pressing against walls while falling slows a player

# Believe in Yourself Bug
#	Replicable: y
#	Running off a ledge makes the run animation continue to play


var debug = false

var fireball_scene = preload("res://scenes/effects/Fireball.tscn")

var idle_sprite_node # Safe to initialize in the _ready() function
var move_anim_node
var fall_anim_node
var scoreboard_node
var collision_handler_node
var center_box_node
var global_node
var root_node

signal exited_center_box
signal attacked_enemy
signal bumped_enemy
signal body_collided
signal shutdown

var direction = 0 # 0 = stationary, 1 = right, -1 = left
var last_direction = 1 # The direction last moved, or the facing direction
var start_pos_x = 128
var start_pos_y = 128
var move_remainder = Vector2(0, 0)
var force_x = 0
var force_y = 0
var velocity = Vector2(0, 0)
var collide_normal
var colliding_body
var is_moving = false # Running implies specifically FAST running, to be considered if there will be multiple speeds
var movement_mode = "idle"
var is_grounded = true
var time_since_grounded = 0

const RUN_SPEED    = 195
#const RUN_SPEED    = 1000
const MAX_VELOCITY = 600
const JUMP_FORCE   = 260
#const JUMP_FORCE   = 1000
const BOUNCE_FORCE = 200 # Likely to be enemy specific in the future
const GRAVITY      = 400 # Opposes jump force
#const GRAVITY      = 1000
const MAX_HEALTH = 3

var jump_count = 0
var max_jump_count = 2

var ActionHolder = preload("res://scripts/action_holder.gd")
var action

var name = "Protagonist"

func _ready():
	print("In ready of player.gd")
	print(self.name)
	print(self.health)
	set_health(MAX_HEALTH)
	
	set_fixed_process(true)
	set_process_input(true)
	
	var path_to_protagonist_node = "/root/World/Protagonist/"
	var path_to_scoreboard_node = "/root/World/Scoreboard/"
	var path_to_collision_handler_node = "/root/World/CollisionHandler/"
	var path_to_center_box_node = "/root/World/CenterBox/"
	var path_to_global_node = "/root/Global/"
	var idle_sprite_node_name = "IdleSprite/"
	var move_anim_node_name = "RunAnim/"
	var fall_anim_node_name = "FallAnim/"
	
	idle_sprite_node       = get_node(path_to_protagonist_node + idle_sprite_node_name)
	move_anim_node         = get_node(path_to_protagonist_node + move_anim_node_name)
	fall_anim_node         = get_node(path_to_protagonist_node + fall_anim_node_name)
	scoreboard_node        = get_node(path_to_scoreboard_node)
	collision_handler_node = get_node(path_to_collision_handler_node)
	global_node            = get_node(path_to_global_node)
	root_node              = get_node("/root/")
	center_box_node        = get_node(path_to_center_box_node)
	
	root_node.call_deferred("add_child", center_box_node)
	
	self.connect("body_collided", collision_handler_node, "handle_body_collided")
	self.connect("shutdown", global_node, "handle_shutdown")
	self.connect("exited_center_box", global_node, "handle_exited_center_box")
	action = ActionHolder.new()
	

func _fixed_process(delta):
	# Increase velocity due to gravity and other forces
	velocity.x = RUN_SPEED * direction + force_x
	velocity.y += GRAVITY * delta + force_y # v(t) = G*t + C
	
	# Clear forces after being applied to velocity
	force_x = 0
	force_y = 0
	
	# Maximize speed a character can be moved by forces
	velocity = velocity.normalized() * min(velocity.length(), MAX_VELOCITY)
	
	# Try to move initially. Move returns the remainder of movement after collision
	move_remainder = move(velocity * delta)

	# If there is a collision, there will be a nonzero move_remainder and is_colliding will return true
	if is_colliding():
		collide_normal = get_collision_normal()
		colliding_body = get_collider()
		
		# Make appropriate changes if colliding surface is horizontal
		if collide_normal == Vector2(0, -1):
			is_grounded = true
			if time_since_grounded != 0:
				update_direction()
			time_since_grounded = 0
			jump_count = 0
		else:
			time_since_grounded += delta
			if is_grounded and time_since_grounded > 0.00:
				update_direction()
				is_grounded = false
		
		move_remainder = collide_normal.slide(move_remainder)
		move(move_remainder)
		
		# Prevent incorrect acceleration due to gravity on surfaces 
		velocity.y = collide_normal.slide(Vector2(0, velocity.y)).y
		
		if colliding_body.is_in_group("Enemies"):
			handle_body_collided(colliding_body, collide_normal)
	else:
		time_since_grounded += delta
		if is_grounded and time_since_grounded > 0.00:
			update_direction()
			is_grounded = false
		if jump_count == 0: # If player fell off a ledge
			jump_count = 1
	# End if is_colliding():else
	

func _input(event):
	if direction:
		last_direction = direction
	
	# Input
	if event.is_action_pressed("move_right"):
#		print("right")
		action.add("right")
		update_direction("right")
	if event.is_action_pressed("move_left"):
#		print("left")
		action.add("left")
		update_direction("left")
	if event.is_action_released("move_right"):
		print("right released")
		action.remove("right")
		update_direction()
	if event.is_action_released("move_left"):
		print("left released")
		action.remove("left")
		update_direction()
	
	if event.is_action_pressed("move_up") and jump_count < max_jump_count:
		print("jump")
		is_grounded = false
		update_direction()
		velocity = Vector2(0, 0)
		force_y = -JUMP_FORCE
		jump_count += 1
		# FEAT - Variable jump length needed
	
	if event.is_action_pressed("reset"):
#		print("reset")
		reset_position()
	
	if event.is_action_pressed("combat_action_1"):
#		print("fireball")
		launch_particle("fireball")
	
	if event.is_action_pressed("debug"):
		debug()

	if event.is_action_pressed("shutdown"):
		emit_signal("shutdown")
	

func flip_sprite(is_flipped):
	idle_sprite_node.set_flip_h(is_flipped)
	move_anim_node.set_flip_h(is_flipped)
	fall_anim_node.set_flip_h(is_flipped)
	

func get_direction():
	var player_direction
	if direction == 1:
		player_direction = "right"
	elif direction == -1:
		player_direction = "left"
	elif direction == 0:
		player_direction = "still"
	return player_direction
	

func get_last_direction():
	var player_direction = "still"
	if last_direction == 1:
		player_direction = "right"
	elif last_direction == -1:
		player_direction = "left"
	return player_direction
	

func update_direction(player_direction = "update"): # Decides how to update sprite
	direction = 0
	if "right" in action.get_actions():
		direction += 1
	if "left" in action.get_actions():
		direction -= 1
	
	if direction == 0:
		is_moving = false
	else:
		is_moving = true
	
	if is_grounded:
		if is_moving:
			switch_mode("moving")
		else:
			switch_mode("still")
	else:
		switch_mode("air")
	
	if direction > 0:
		flip_sprite(false)
	if direction < 0:
		flip_sprite(true)
	

func switch_mode(character_mode): # Updates sprite
	if character_mode == "still":
		move_anim_node.stop()
		fall_anim_node.stop()
		idle_sprite_node.set_hidden(false)
		move_anim_node.set_hidden(true)
		fall_anim_node.set_hidden(true)
	elif character_mode == "moving":
		move_anim_node.play()
		fall_anim_node.stop()
		idle_sprite_node.set_hidden(true)
		move_anim_node.set_hidden(false)
		fall_anim_node.set_hidden(true)
	elif character_mode == "air":
		move_anim_node.stop()
		fall_anim_node.play()
		idle_sprite_node.set_hidden(true)
		move_anim_node.set_hidden(true)
		fall_anim_node.set_hidden(false)
	if debug == true:
		print("character_mode: " + str(character_mode))
	

func bounce(bounce_force): # Should be called externally
	is_grounded = false
	update_direction()
	velocity = Vector2(0, 0)
	force_y = -bounce_force
	jump_count = 1
	

func reset_position():
	self.set_pos(Vector2(start_pos_x, start_pos_y))
	velocity = Vector2(0, 0)
	

func launch_particle(particle_type):
	if particle_type == "fireball":
		var particle = fireball_scene.instance()
		get_tree().get_root().add_child(particle)
		particle.set_direction(self.get_last_direction())
		particle.set_spawner("Protagonist")
		particle.set_pos(self.get_pos()) # BUG - Not centered
	

func debug():
	print(velocity)
	

func handle_body_collided(colliding_body, collision_normal):
	emit_signal("body_collided", self, colliding_body, collision_normal)
	

func handle_player_hit_enemy_top(player, enemy):
	emit_signal("attacked_enemy")
	bounce(enemy.get_bounciness())
	

func handle_player_hit_enemy_side(player, enemy):
	emit_signal("bumped_enemy")
	
