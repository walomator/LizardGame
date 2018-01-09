extends KinematicBody2D


const GRAVITY      = 400
const MAX_VELOCITY = 1000
const AIR_DRAG     = 0

var collision_box_node
var is_weighted = false
var health = 1
var velocity = Vector2(0, 0)

const SimpleTimer = preload("res://scripts/simple_timer.gd")

func _ready():
#	set_fixed_process(true)
	pass
	

func _fixed_process(delta):
	print("ping")
	if is_weighted == true:
		# Increase velocity due to gravity
		velocity.y += GRAVITY * delta
		
		# Set maximum speed a player can be moved by forces
		velocity = velocity.normalized() * min(velocity.length(), MAX_VELOCITY)
		
		# Try to move initially. Return the remainder of movement after collision
		var move_remainder = move(velocity * delta)
		
		# If there is a collision, there will be a nonzero move_remainder and is_colliding will return true
		if is_colliding():
			var collide_normal = get_collision_normal()
			var colliding_body = get_collider()
			
			move_remainder = collide_normal.slide(move_remainder)
			move(move_remainder)
			
			# Prevent incorrect acceleration due to gravity on surfaces 
			velocity.y = collide_normal.slide(Vector2(0, velocity.y)).y
			
	

func increase_velocity(velocity_increase):
	velocity += velocity_increase
	

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
	
