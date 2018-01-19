extends KinematicBody2D


const GRAVITY      = 400
const MAX_VELOCITY = 1000
const AIR_DRAG     = 0

var collision_box_node
var is_weighted = false
var health = 1
var velocity = Vector2(0, 0)
var controller_velocity = Vector2(0, 0)
var move_remainder = Vector2(0, 0)
var collide_normal = Vector2(0, 0)
var colliding_body = null

const SimpleTimer = preload("res://scripts/simple_timer.gd")

func _ready():
#	set_fixed_process(true)
	pass
	

func _fixed_process(delta):
	if is_weighted == true:
		# Increase velocity due to gravity
		velocity.y += GRAVITY * delta
		
		# Set maximum speed a player can be moved by forces
		velocity = velocity.normalized() * min(velocity.length(), MAX_VELOCITY)
		
		# Try to move initially. Return the remainder of movement after collision
		move_remainder = move((velocity + controller_velocity) * delta)
		var controller_velocity = Vector2(0, 0)
		
		# If there is a collision, there will be a nonzero move_remainder and is_colliding will return true
		if is_colliding():
			collide_normal = get_collision_normal()
			colliding_body = get_collider()
			
			move(collide_normal.slide(move_remainder))
			
			# Prevent incorrect acceleration due to gravity on surfaces 
			velocity.y = collide_normal.slide(Vector2(0, velocity.y)).y
		else:
			collide_normal = Vector2(0, 0)
			colliding_body = null
	

func char_colliding():
	var state = true
	if move_remainder == Vector2(0, 0):
		state = false
	return state
	

func get_char_collision_normal():
	return collide_normal
	

func get_char_collider():
	return colliding_body
	

func get_move_remainder():
	return move_remainder
	

func increase_velocity(velocity_increase):
	velocity += velocity_increase
	

func reset_velocity():
	velocity = Vector2(0, 0)
	

func set_controller_velocity(char_controller_velocity):
	controller_velocity = char_controller_velocity
	

func start_timer(name, time):
	var simple_timer = SimpleTimer.new()
	simple_timer.start(self, name, time)
	

func _set_health(character_health):
	if character_health > 0:
		health = character_health
	else:
		handle_death()
	
func _set_is_weighted(char_is_weighted):
	is_weighted = char_is_weighted
	

func get_health():
	return health
	

func handle_death():
	die()
	

func die():
	self.queue_free()
	