# Buglist
# Running Man Bug
#	Replicable: yes
#	Sprites for protagonist's running animation don't align with idle
#	Fix: edit animation frames

# Sticky Walls
#	Replicable: y
#	Pressing against walls while falling slows a player


extends KinematicBody2D

var debug = 1

var fireball_scene = preload("res://scenes/effects/Fireball.tscn")

var idle_sprite_node # Safe to initialize in the _ready() function
var move_anim_node
var fall_anim_node
var scoreboard_node

signal attacked_enemy
signal bumped_enemy
#signal passed_end_level

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
var is_grounded
var was_grounded

const RUN_SPEED    = 4
const MAX_VELOCITY = 11
const JUMP_FORCE   = 5
const BOUNCE_FORCE = 3 # Likely to be enemy specific in the future
const GRAVITY      = 8 # Opposes jump force

var jump_count = 0
var max_jump_count = 2

var path_to_protagonist_node = "/root/World/Protagonist/"
var path_to_scoreboard_node = "/root/World/Scoreboard/"

var idle_sprite_node_name = "IdleSprite/"
var move_anim_node_name = "RunAnim/"
var fall_anim_node_name = "FallAnim/"

var ActionHolder = preload("res://scripts/action_holder.gd")
var action

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	idle_sprite_node = get_node(path_to_protagonist_node + idle_sprite_node_name)
	move_anim_node =  get_node(path_to_protagonist_node + move_anim_node_name)
	fall_anim_node =  get_node(path_to_protagonist_node + fall_anim_node_name)
	scoreboard_node = get_node(path_to_scoreboard_node)
	self.connect("attacked_enemy", scoreboard_node, "handle_attacked_enemy", [])
	self.connect("bumped_enemy", scoreboard_node, "handle_bumped_enemy", [])
	self
	
	action = ActionHolder.new()
	

func _fixed_process(delta):
	# Increase velocity due to gravity and other forces
	velocity.x = RUN_SPEED * direction + force_x # Missing delta
	velocity.y += GRAVITY * delta + force_y # v(t) = G*t + C
	
	# Clear forces after being applied to velocity
	force_x = 0
	force_y = 0
	
	# Maximize speed a character can be moved by forces
	velocity = velocity.normalized() * min(velocity.length(), MAX_VELOCITY)
	
	# Try to move initially
	move_remainder = move(velocity) # move(velocity) returns the remainder of movement after collision
	
	if is_colliding():
		is_grounded = true
		if is_grounded != was_grounded:
			set_direction()
		was_grounded = true
		collide_normal = get_collision_normal()
		colliding_body = get_collider()
		
		velocity = collide_normal.slide(move_remainder)
		move(velocity)
		
		# Should be done with signalling instead
		if colliding_body.is_in_group("Enemies"):
			handle_enemy_collision()
		else:
			# This should be rewritten in cleaner code
			velocity.y = collide_normal.slide(Vector2(0, velocity.y)).y
			
			if collide_normal == Vector2(0, -1): # Can't refill jump_count on slopes
				jump_count = 0
			else:
				is_grounded = false
		# End if colliding_body.is_in_group("Enemies"):else
		
	else:
		is_grounded = false
		if is_grounded != was_grounded:
			set_direction()
		was_grounded = false
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
		set_direction("right")
	if event.is_action_pressed("move_left"):
#		print("left")
		action.add("left")
		set_direction("left")
	if event.is_action_released("move_right"):
		print("right released")
		action.remove("right")
		set_direction()
	if event.is_action_released("move_left"):
		print("left released")
		action.remove("left")
		set_direction()
	
	if event.is_action_pressed("move_up") and jump_count < max_jump_count:
		print("jump")
		is_grounded = false
		set_direction()
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
	

func set_direction(player_direction = "update"):
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
	

func switch_mode(character_mode):
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
	elif character_mode == "air": # Currently the same as "moving"
		move_anim_node.stop()
		fall_anim_node.play()
		idle_sprite_node.set_hidden(true)
		move_anim_node.set_hidden(true)
		fall_anim_node.set_hidden(false)
	

func reset_position():
	self.set_pos(Vector2(start_pos_x, start_pos_y))
	velocity = Vector2(0, 0)
	

func handle_enemy_collision():
	if collide_normal == Vector2(0, -1): # Landed from above
		emit_signal("attacked_enemy")
		is_grounded = false
		velocity = Vector2(0, 0)
		force_y = -BOUNCE_FORCE # Fixed bounciness, no matter the fall distance
		jump_count = 1
	else:
		emit_signal("bumped_enemy")
		velocity.y = collide_normal.slide(Vector2(0, velocity.y)).y
	

func launch_particle(particle_type):
	if particle_type == "fireball":
		var particle = fireball_scene.instance()
		get_tree().get_root().add_child(particle)
		particle.set_direction(self.get_last_direction())
		particle.set_spawner("Protagonist")
		particle.set_pos(self.get_pos()) # BUG - Not centered
		

func debug():
	print(velocity)
	
