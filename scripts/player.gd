extends KinematicBody2D

var debug = 1

var direction = 0 # 0 for stationary, 1 for right, and -1 for left
var last_direction = 0
var speed = 0
const MAX_SPEED = 300
var velocity = Vector2(0, 0)
const ACCELERATION = 160
const DECELERATION = 400

func _ready():
	set_process(true)
	set_process_input(true)


func _process(delta):
	
	if direction:
		last_direction = direction
	
	# Input
#	if Input.is_action_pressed("ui_right"):
#		print("right")
#		direction = 1
#	elif Input.is_action_pressed("ui_right"):
#		print("left")
#		direction = -1
#	else:
#		direction = 0
	
	if direction == - last_direction:
		speed /= 3
	if direction:
		speed += ACCELERATION * delta
	else:
		speed -= DECELERATION * delta
	
	speed = clamp(speed, 0, MAX_SPEED)
	
	velocity = Vector2(speed * delta * last_direction, 0)
	move(velocity)


func _input(event):
	pass
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
		direction = 0