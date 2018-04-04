extends "character.gd"

# Buglist
# Running Man Bug
#	Replicable: y
#	Sprites for protagonist's running animation don't align with idle
#	Fix: edit animation frames

# Floating Bug
#	Replicable: y
#	Pressig against a wall will cause the air animation to switch on and off
#	Fix: There needs to be some sort of flag when jumping that allows air animation to play

var debug = false

var fireball_scene = preload("res://scenes/effects/Fireball.tscn")
var hookshot_scene = preload("res://scenes/effects/Hookshot.tscn")

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
var run_speed = 0
var force_x = 0
var force_y = 0
var is_moving = false # Running implies specifically FAST running, to be considered if there will be multiple speeds
var is_grounded = true
var time_since_liftoff = 0 # DEV - Should be local to _physics_process
var is_stunned = false
var item_1 = "hookshot"

const MAX_RUN_SPEED    = 195
const MAX_VELOCITY     = 400 # DEV - note: adjustment to MAX_VELOCITY of character.gd class
const JUMP_FORCE       = 260
const BOUNCE_FORCE     = 200 # Likely to be enemy specific in the future
#const GRAVITY          = 400 # Opposes jump force
const HURT_FORCE       = 80
const STUN_TIME        = 0.5
const MAX_HEALTH       = 3
const GROUND_DRAG      = 300
const AIR_ACCELERATION = 4

var jump_count = 0
var max_jump_count = 2
var airborn = true

const ActionHolder = preload("res://scripts/action_holder.gd")
var action

# State machine possible states.
const StandingState = preload("res://scripts/states/StandingState.gd")
const JumpingState  = preload("res://scripts/states/JumpingState.gd")
var state = StandingState.new(self)

func _ready():
	_set_health(MAX_HEALTH)
	_set_is_weighted(true)
	
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
	
	root_node.call_deferred("add_child", center_box_node) # DEV - This should be handled elsewhere
	self.connect("body_collided", collision_handler_node, "handle_body_collided")
	self.connect("shutdown", global_node, "handle_shutdown") # BUG - The user loses control if the player object is gone
	self.connect("exited_center_box", global_node, "handle_exited_center_box")
	
	action = ActionHolder.new()
	
#	set_state("StandingState") # This is already instantiated beforehand
	

func _physics_process(delta):
	state.state_process(delta)
	

func _input(event):
	if event.is_action_pressed("shutdown"):
		emit_signal("shutdown")
	
	if is_stunned == true:
		return # BUG - This should not disable ALL input, e.g., shutdown
	
	if direction:
		last_direction = direction
	
	# Input
	if event.is_action_pressed("move_right"):
		action.add("right")
		update_direction()
	if event.is_action_pressed("move_left"):
		action.add("left")
		update_direction()
	if event.is_action_released("move_right"):
		action.remove("right")
		update_direction()
	if event.is_action_released("move_left"):
		action.remove("left")
		update_direction()
	
	if event.is_action_pressed("move_up") and jump_count < max_jump_count:
		state.jump()
	
	if event.is_action_pressed("reset"):
#		print("reset")
		reset_position()
	
	if event.is_action_pressed("combat_action_1"):
#		print("fireball")
		launch_particle(item_1)
	
	if event.is_action_pressed("debug"):
		debug()
	

func set_state(new_state): # These don't need to be instances right _now_
	print("State changed.")
	var old_state = state
	if new_state == "StandingState":
		state = StandingState.new(self)
	elif new_state == "JumpingState":
		state = JumpingState.new(self)
	else:
		return
		
	state.start()
	old_state.queue_free()
	

func handle_landing(): # Should be handled by state machine
	is_grounded = true
	update_direction()
	jump_count = 0
	print("landed")
	
#	var moving_direction = sign(velocity.x)
#	velocity.x -= moving_direction * GROUND_DRAG * delta # Decelerate player if sliding without input
#	if moving_direction != sign(velocity.x):
#		velocity.x = 0
	

func handle_timeout(object_timer, name): # Called by timer after it times out
	if name == "unstun":
		is_stunned = false
	object_timer.queue_free()
	

func flip_sprite(is_flipped):
	idle_sprite_node.set_flip_h(is_flipped)
	move_anim_node.set_flip_h(is_flipped)
	fall_anim_node.set_flip_h(is_flipped)
	

func update_direction(): # Decides how to update sprite
	direction = 0
	if "right" in action.get_actions():
		direction += 1
	if "left" in action.get_actions():
		direction -= 1
	
	run_speed = MAX_RUN_SPEED * direction # This makes the next line seem redundant, and it is as long as there is no speed ramp
	run_speed = min(abs(run_speed), MAX_RUN_SPEED) * direction # FEAT - Hacky thing number 2, write this better
	
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
	

func switch_mode(character_mode): # Updates sprite # DEV - Should be phased out for state system
	if character_mode == "still":
#		print("grounded")
		move_anim_node.stop()
		fall_anim_node.stop()
		idle_sprite_node.visible = true
		move_anim_node.visible = false
		fall_anim_node.visible = false
	elif character_mode == "moving":
		move_anim_node.play()
		fall_anim_node.stop()
		idle_sprite_node.visible = false
		move_anim_node.visible = true
		fall_anim_node.visible = false
	elif character_mode == "air":
#		print("airborn")
		move_anim_node.stop()
		fall_anim_node.play()
		idle_sprite_node.visible = false
		move_anim_node.visible = false
		fall_anim_node.visible = true
	elif character_mode == "stunned":
		pass
	

func bounce(bounce_force): # Should be called externally
	is_grounded = false
	update_direction()
	reset_velocity()
#	force_y = -bounce_force
	increase_velocity(Vector2(0, -bounce_force))
	jump_count = 1
	

func reel(reel_force, normal):
	is_stunned = true
#	is_grounded = false
#	update_direction()
	reset_velocity()
#	force_x = normal.x * reel_force
	increase_velocity(Vector2(normal.x * reel_force, 0))
#	jump_count = 1
	direction = 0
	action.clear()
	update_direction()
	switch_mode("stunned")
	

func reset_position():
	self.position = Vector2(start_pos_x, start_pos_y)
	reset_velocity()
	

func default_jump():
	reset_velocity()
	increase_velocity(Vector2(0, -JUMP_FORCE))
	jump_count += 1
	# FEAT - Variable jump length needed
	

func launch_particle(particle_type):
	var particle = "null"
	if particle_type == "fireball":
		particle = fireball_scene.instance()
	if particle_type == "hookshot":
		particle = hookshot_scene.instance()
	
	# DEV - This code limits usage of the launch_particle function
	get_tree().get_root().add_child(particle)
	particle.set_direction(last_direction)
	particle.set_spawner(self)
	particle.set_global_pos(self.position) # BUG - Not centered
	

func debug():
	print("jump_count: ", jump_count)
	print("state: ", state.get_name())
	

func handle_body_collided(colliding_body, collision_normal): # DEV - This function name is misleading
	emit_signal("body_collided", self, colliding_body, collision_normal)
	

func handle_player_hit_enemy_top(player, enemy):
	emit_signal("attacked_enemy")
	bounce(enemy.get_bounciness())
	

func handle_player_hit_enemy_side(player, enemy, normal):
	reel(HURT_FORCE, normal)
	var damage = enemy.get_damage()
	_set_health(get_health() - damage)
	start_timer("unstun", STUN_TIME)
	

func handle_player_hit_hazard_top(player, hazard, normal):
	var damage = hazard.get_damage()
	_set_health(get_health() - damage)
	

func handle_player_hit_hazard_side(player, hazard, normal):
	pass # DEV - It should be in the code of the hazard whether sides hurt the player
	