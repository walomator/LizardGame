extends KinematicBody2D

var debug = 1

var direction = 0 # 0 = stationary, 1 = right, -1 = left
var last_direction = 0 # The direction last moved, or the facing direction
var speed = 0
const MAX_SPEED = 250
var velocity = Vector2(0, 0)
#const ACCELERATION = 160
#const DECELERATION = 400

func _ready():
	set_process(true)
	set_process_input(true)


func _process(delta):
	
	velocity = Vector2(speed * delta * direction, 0)
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
	
	if direction:
		speed = MAX_SPEED