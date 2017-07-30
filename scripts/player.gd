# Buglist
# The Bugaroo Bug
#	Replicable: yes
#	Character becomes extra shaky when running against a slime.
#	Particularly occurs when pushing from the right in my case.
#	I glitched up on top of the slime from doing this.
# The Didgeridoo Bug
#	Replicable: no (not reliably)
#	Character becomes shaky when standing still on the ground.
#	Usually does not occur, but then sometimes, for no reason, it does occur.
#	May be related to screen resolution.
#	Luke may experience it the most often.
#	Matthew has only experienced in once without an idea on how to replicate it.

extends KinematicBody2D

var debug = 1

var sprite_node # Safe to initialize in the _ready() function

var direction = 0 # 0 = stationary, 1 = right, -1 = left
var last_direction = 0 # The direction last moved, or the facing direction

var move_remainder = Vector2(0, 0)
var speed_x = 0
var speed_y = 0
var velocity = Vector2(0, 0)
var collide_normal

var colliding_body

# CLEANUP - A lot of these should not be constants
const MAX_SPEED_X = 250 # Right now there is no acceleration, but I'd like to add a little bit back in
const MAX_SPEED_Y = 300 # BUG - limits falling speed, not jump speed
# FEAT - There should exist a max fall speed and a max "launch" speed

const JUMP_FORCE = 420
const BOUNCE_FORCE = 420 # Should change this to be dependant on the enemy
const GRAVITY = 750 # Opposes jump force

var jump_count = 0
var max_jump_count = 2 # Should be 1, but I'm testing double jump

var path_to_protagonist_node = "/root/World/Protagonist/"

var idle_sprite_node_name = "IdleSprite/"
var move_anim_node_name = "AnimatedSprite/"


func _ready():
	set_process(true)
	set_process_input(true)
	sprite_node = get_node(path_to_protagonist_node + idle_sprite_node_name)


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
				print("Enemy head smashed")
				speed_y = -BOUNCE_FORCE # Fixed bounciness, no matter the fall distance
				jump_count = 1
			else:
				print("You're toast!")
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
	
	# Input
	if event.is_action_pressed("ui_right"):
		print("right")
		direction = 1
		sprite_node.set_flip_h(false)
	elif event.is_action_pressed("ui_left"):
		print("left")
		direction = -1
		sprite_node.set_flip_h(true)
	elif (event.is_action_released("ui_right") and direction == 1) or (event.is_action_released("ui_left") and direction == -1):
		print("stopped")
		direction = 0
	
	if event.is_action_pressed("ui_up") and jump_count < max_jump_count:
		print("jump")
		speed_y = -JUMP_FORCE
		
		jump_count += 1
		# FEAT - Variable jump length should be a feature later
	
	if direction:
		speed_x = MAX_SPEED_X
