# LizardGame beta 1.0

extends KinematicBody2D

var debug = 1

var sprite_node # Safe to initialize in the _ready() function

var direction = 0 # 0 = stationary, 1 = right, -1 = left
var last_direction = 0 # The direction last moved, or the facing direction

var move_remainder
var speed_x = 0
var speed_y = 0
var velocity = Vector2(0, 0)
var collide_normal

var colliding_body

const MAX_SPEED_X = 250 # Right now there is no acceleration, but I'd like to add a little bit back in
const MAX_SPEED_Y = 300 # BUG - limits falling speed, not jump speed

const JUMP_FORCE = 420
const BOUNCE_FORCE = 200 # Should change this to be dependant on the enemy
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
	move_remainder = Vector2(0, 0)
	
	speed_y = clamp(speed_y, speed_y, MAX_SPEED_Y)
	speed_y += GRAVITY * delta # BUG - delta shouldn't be factored in twice, should it?
	
	velocity.x = speed_x * delta * direction
	velocity.y = speed_y * delta # BUG - this does not work perfectly with gravitational acceleration.
	
	# Movement
	move_remainder += move(velocity)
	
	if is_colliding():
		collide_normal = get_collision_normal()
		colliding_body = get_collider()
		
		if colliding_body.is_in_group("Enemies"):
			if collide_normal == Vector2(0, -1):
				print("Enemy head smashed")
				move_remainder += bounce(BOUNCE_FORCE, delta)
			else:
				print("You're toast!")
			
		velocity = collide_normal.slide(move_remainder)
		move(velocity)
		
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
	

func bounce(force, delta):
	# Needs to function more like code in _process(delta), ie throttle speed, etc.
	# This doesn't counterract gravity
	var bounce_speed_y = force * delta
	return move(Vector2(0, bounce_speed_y))