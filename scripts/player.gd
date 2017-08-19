# Buglist
# The Bugaroo Bug
#	Replicable: sometimes
#	Character becomes extra shaky when running against a slime.
#	Sometimes a vertical shakiness, sometimes a horizontal shakiness.
#	Matthew: glitched up on top of the slime from doing this from laptop.
#	Matthew: horizontal shakiness experienced on desktop, vertical shakiness on laptop
# The Didgeridoo Bug
#	Replicable: no (not reliably)
#	Character becomes shaky when standing still on the ground.
#	Usually does not occur, but then sometimes, for no reason, it does occur.
#	May be related to screen resolution.
#	Matthew: Luke may experience it the most often.
#	Matthew: has experienced it on desktop and laptop.
# Running Man Bug
#	Replicable: yes
#	Sprites for protagonist's running animation don't align with idle
#	Fix: edit animation frames


extends KinematicBody2D

var debug = 1

var fireball_scene = preload("res://scenes/Fireball.tscn")

var idle_sprite_node # Safe to initialize in the _ready() function
var move_anim_node
var scoreboard_node

signal attacked_enemy
signal bumped_enemy
signal bumped_end_level

var direction = 0 # 0 = stationary, 1 = right, -1 = left
var last_direction = 1 # The direction last moved, or the facing direction
var start_pos_x = 128
var start_pos_y = 128
var move_remainder = Vector2(0, 0)
var speed_x = 0
var speed_y = 0
var velocity = Vector2(0, 0)
var collide_normal

var colliding_body

var is_moving = false # Running implies specifically FAST running, to be considered if there will be multiple speeds
var movement_mode = "idle"
var is_grounded

# CLEANUP - A lot of these should not be constants
const MAX_SPEED_X = 250 # Right now there is no acceleration, but I'd like to add a little bit back in
const MAX_SPEED_Y = 300 # BUG - limits falling speed, not jump speed
# FEAT - There should exist a max fall speed and a max "launch" speed

const JUMP_FORCE = 420
const BOUNCE_FORCE = 300 # Should change this to be dependant on the enemy
const GRAVITY = 750 # Opposes jump force

var jump_count = 0
var max_jump_count = 2 # Should be 1, but I'm testing double jump

var path_to_protagonist_node = "/root/World/Protagonist/"
var path_to_scoreboard_node = "/root/World/Scoreboard/"
# Not sure if there is a reason to make the paths to nodes a variable if they are only used once

var idle_sprite_node_name = "IdleSprite/"
var move_anim_node_name = "AnimatedSprite/"


func _ready():
	set_process(true)
	set_process_input(true)
	idle_sprite_node = get_node(path_to_protagonist_node + idle_sprite_node_name)
	move_anim_node =  get_node(path_to_protagonist_node + move_anim_node_name)
	scoreboard_node = get_node(path_to_scoreboard_node)
	print(scoreboard_node)
	self.connect("attacked_enemy", scoreboard_node, "handle_attacked_enemy", [])
	self.connect("bumped_enemy", scoreboard_node, "handle_bumped_enemy", [])
	self.connect("bumped_end_level", scoreboard_node, "handle_bumped_end_level", [])


func _process(delta):
	speed_y = clamp(speed_y, speed_y, MAX_SPEED_Y)
	speed_y += GRAVITY * delta
	
	velocity.x = speed_x * delta * direction
	velocity.y = speed_y * delta # BUG - this does not work perfectly with gravitational acceleration.
	
	# Movement
	move_remainder = move(velocity)
	
	if is_colliding():
		is_grounded = true
		collide_normal = get_collision_normal()
		colliding_body = get_collider()
		
		velocity = collide_normal.slide(move_remainder)
		move(velocity)
		
		if colliding_body.is_in_group("Enemies"): # Should be done with signalling instead
			handle_enemy_collision()
		elif colliding_body.is_in_group("Flag"):
			handle_flag_collision(colliding_body)
		elif colliding_body.is_in_group("Item"):
			handle_item_collision(colliding_body)
		else:
			# This should be in a function run conditionally if the colliding object doesn't do something else like bounce the player
			if collide_normal == Vector2(0, -1): # Can't land on a sloped surface to refill jump_count
				jump_count = 0
			else:
				is_grounded = false
			
			speed_y = collide_normal.slide(Vector2(0, speed_y)).y
			# This keeps falling speed from accumulating where it shouldn't (eg. on the ground).
			# Possible BUG - it may mean that walking up slopes makes the character move slower, which isn't desired.
			# It may also mean that you cannot run up slopes, not sure
		
	else:
		is_grounded = false
		if jump_count == 0: # If player fell off a ledge
			jump_count = 1
	# End if is_colliding()


func _input(event):
	if direction:
		last_direction = direction
	
	# Input
	if event.is_action_pressed("ui_right"):
		print("right")
		set_direction("right")
		flip_sprite(false, is_moving)
	elif event.is_action_pressed("ui_left"):
		print("left")
		set_direction("left")
		flip_sprite(true, is_moving)
	elif (event.is_action_released("ui_right") and direction == 1) or (event.is_action_released("ui_left") and direction == -1):
		print("stopped")
		set_direction("still")
	
	if event.is_action_pressed("ui_up") and jump_count < max_jump_count:
		print("jump")
		speed_y = -JUMP_FORCE
		jump_count += 1
		# FEAT - Variable jump length should be a feature later
	
	if direction:
		speed_x = MAX_SPEED_X
	
	if event.is_action_pressed("reset"):
		reset_position()
	
	if event.is_action_pressed("combat_action_1"):
		launch_particle("fireball")
	

func flip_sprite(is_flipped, player_is_moving):
	move_anim_node.set_flip_h(is_flipped)
	idle_sprite_node.set_flip_h(is_flipped)
	

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
	

func set_direction(player_direction):
	# Should be a simpler setter that calls a handle_change_direction
	if player_direction == "right":
		direction = 1
		is_moving = true
	if player_direction == "left":
		direction = -1
		is_moving = true
	if player_direction == "still":
		direction = 0
		is_moving = false
	if is_grounded:
		if is_moving:
			switch_mode("moving")
		else:
			switch_mode("still")
	else:
		# Should be an animated sprite
		switch_mode("air")
	
func switch_mode(character_mode):
	if character_mode == "moving":
		move_anim_node.play()
		move_anim_node.set_hidden(false)
		idle_sprite_node.set_hidden(true)
	elif character_mode == "air": # Currently the same as "moving"
		move_anim_node.play()
		move_anim_node.set_hidden(false)
		idle_sprite_node.set_hidden(true)
	elif character_mode == "still":
		move_anim_node.stop()
		idle_sprite_node.set_hidden(false)
		move_anim_node.set_hidden(true)


func reset_position():
	self.set_pos(Vector2(start_pos_x, start_pos_y))
	speed_x = 0
	speed_y = 0
	

func handle_enemy_collision():
	if collide_normal == Vector2(0, -1): # Landed from above
		emit_signal("attacked_enemy")
		speed_y = -BOUNCE_FORCE # Fixed bounciness, no matter the fall distance
		jump_count = 1
	else:
		emit_signal("bumped_enemy")
		speed_y = collide_normal.slide(Vector2(0, speed_y)).y
		# This line may be the cause of a BUG.
		# I am calling it the Bugaroo Bug for no apparent reason. See above.
	

func handle_flag_collision(flag_object):
	if flag_object.is_in_group("EndLevel"):
		emit_signal("bumped_end_level")
	

func handle_item_collision(item_object):
	if item_object.is_in_group("Potion"):
		print("No more room for potions!")
	

func launch_particle(particle_type):
	if particle_type == "fireball":
		var particle = fireball_scene.instance()
		get_tree().get_root().add_child(particle)
		particle.set_direction(self.get_last_direction())
		particle.set_spawner("Protagonist")
		particle.set_pos(get_pos()) # Not really centered