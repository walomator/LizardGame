# Buglist
# The Bugaroo Bug
#	Replicable: sometimes
#	Character becomes extra shaky when running against a slime.
#	Particularly occurs when pushing from the right in my case.
#	Matthew glitched up on top of the slime from doing this from laptop.
#	Could not replicate on desktop
# The Didgeridoo Bug
#	Replicable: no (not reliably)
#	Character becomes shaky when standing still on the ground.
#	Usually does not occur, but then sometimes, for no reason, it does occur.
#	May be related to screen resolution.
#	Luke may experience it the most often.
#	Matthew has experienced it on desktop and laptop.
# Running Man Bug
#	Replicable: yes
#	Sprites for protagonist's running animation don't align with idle


extends KinematicBody2D

var debug = 1

var idle_sprite_node # Safe to initialize in the _ready() function
var move_anim_node
var scoreboard_node

signal attacked_enemy
signal bumped_enemy

var direction = 0 # 0 = stationary, 1 = right, -1 = left
var last_direction = 0 # The direction last moved, or the facing direction

var move_remainder = Vector2(0, 0)
var speed_x = 0
var speed_y = 0
var velocity = Vector2(0, 0)
var collide_normal

var colliding_body

var is_running = false # Running implies specifically FAST running, to be considered if there will be multiple speeds

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
	self.connect("attacked_enemy", scoreboard_node, "handle_attacked_enemy", [])
#	self.connect("bumped_enemy", scoreboard_node, "handle_bumped_enemy", [])


func _process(delta):
	#move_remainder = Vector2(0, 0)
	
	speed_y = clamp(speed_y, speed_y, MAX_SPEED_Y)
	speed_y += GRAVITY * delta
	
	velocity.x = speed_x * delta * direction
	velocity.y = speed_y * delta # BUG - this does not work perfectly with gravitational acceleration.
	
	# Movement
	move_remainder = move(velocity)
	
	if is_colliding():
		collide_normal = get_collision_normal()
		colliding_body = get_collider()
		
		velocity = collide_normal.slide(move_remainder)
		move(velocity)
		
		if colliding_body.is_in_group("Enemies"): # Should be done with signalling instead
			if collide_normal == Vector2(0, -1): # Landed from above
#				print("Enemy head smashed")
				emit_signal("attacked_enemy")
				speed_y = -BOUNCE_FORCE # Fixed bounciness, no matter the fall distance
				jump_count = 1
			else:
#				print("You're toast!")
				emit_signal("bumped_enemy")
				speed_y = collide_normal.slide(Vector2(0, speed_y)).y
				# This line may be the cause of a BUG.
				# I am calling it the Bugaroo Bug for no apparent reason. See above.
			
		else:
			if collide_normal == Vector2(0, -1): # Can't land on a sloped surface to refill jump_count
				jump_count = 0
			
			speed_y = collide_normal.slide(Vector2(0, speed_y)).y
			# This keeps falling speed from accumulating where it shouldn't (eg. on the ground).
			# Possible BUG - it may mean that walking up slopes makes the character move slower, which isn't desired.
			# It may also mean that you cannot run up slopes, not sure
		
	elif jump_count == 0: # If player fell off a ledge
		jump_count = 1
	# End if is_colliding()


func _input(event):
	if direction:
		last_direction = direction
		# last_direction currently does nothing
	
	# Input
	if event.is_action_pressed("ui_right"):
		print("right")
#		direction = 1
		set_direction("right")
		flip_sprite(false, is_running)
	elif event.is_action_pressed("ui_left"):
		print("left")
#		direction = -1
		set_direction("left")
		flip_sprite(true, is_running)
	elif (event.is_action_released("ui_right") and direction == 1) or (event.is_action_released("ui_left") and direction == -1):
		print("stopped")
#		direction = 0
		set_direction("still")
	
	if event.is_action_pressed("ui_up") and jump_count < max_jump_count:
		print("jump")
		speed_y = -JUMP_FORCE
		
		jump_count += 1
		# FEAT - Variable jump length should be a feature later
	
	if direction:
		speed_x = MAX_SPEED_X


func flip_sprite(is_flipped, player_is_running):
	# It is fairly unnecessary to check if the player is moving before flipping. Maybe it won't always be.
	if player_is_running:
#		move_anim_node.set_hidden(false)
#		idle_sprite_node.set_hidden(true)
		move_anim_node.set_flip_h(is_flipped)
		print("player is running at time of flip_sprite call")
	else:
#		idle_sprite_node.set_hidden(false)
#		move_anim_node.set_hidden(true)
		idle_sprite_node.set_flip_h(is_flipped)
		print("player is still at time of flip_sprite call")
	

func set_direction(player_direction):
	if player_direction == "right":
		direction = 1
		is_running = true
	if player_direction == "left":
		direction = -1
		is_running = true
	if player_direction == "still":
		direction = 0
		is_running = false
	print("is_running set to ", is_running)
	if is_running:
		move_anim_node.set_hidden(false)
		idle_sprite_node.set_hidden(true)
	else:
		idle_sprite_node.set_hidden(false)
		move_anim_node.set_hidden(true)