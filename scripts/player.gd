extends KinematicBody2D

# Some of these values have not been tested to be good for gameplay
# What gameplay? Ha ha ha!
var debug = 1

var direction = 0 # 0 = stationary, 1 = right, -1 = left
var last_direction = 0 # The direction last moved, or the facing direction

var speed_x = 0
var speed_y = 0
var velocity = Vector2(0, 0)

const MAX_SPEED_X = 250 # Right now there is no acceleration, but I'd like to add a little bit back in
const MAX_SPEED_Y = 250 # BUG - limits falling speed, not jump speed

const JUMP_FORCE = 350
const GRAVITY = 750 # Opposes jump force

func _ready():
	set_process(true)
	set_process_input(true)


func _process(delta):
	speed_y = clamp(speed_y, speed_y, MAX_SPEED_Y)
	speed_y += GRAVITY * delta
	
	velocity.x = speed_x * delta * direction
	velocity.y = speed_y * delta # BUG - this does not work perfectly with gravitational acceleration. Causes "Fallout 4 physics"
	move(velocity)


func _input(event):
	if direction:
		last_direction = direction
	
	# Input
	if event.is_action_pressed("move_right"):
		print("right")
		direction = 1
	elif event.is_action_pressed("move_left"):
		print("left")
		direction = -1
	elif event.is_action_released("move_right") or event.is_action_released("move_left"):
		print("stopped")
		direction = 0
	
	if event.is_action_pressed("ui_up"):
		print("jump")
		speed_y = -JUMP_FORCE
		# Variable jump length should be a feature later
	
	if direction:
		speed_x = MAX_SPEED_X