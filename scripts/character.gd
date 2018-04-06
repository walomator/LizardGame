extends KinematicBody2D

# Buglist
# Nonviolent-Head-Stomper
#	Replicable: y
#	Player is not bouncing on enemies because move_and_slide generally hates
#	colliding with the ground. However, it seems the first bounce always works,
#	so it may be something else.
#	Fix: switch to using move_and_collide then move_and_slide, or use Area2D
#	boxes instead of collision boxes on enemies

const GRAVITY      = 400
const MAX_VELOCITY = 1000
const AIR_DRAG     = 0

var collision_box_node # Implemented in monster.gd, but not player.gd
var is_weighted = false
var health = 1
var velocity = Vector2(0, 0)
var controller_velocity = Vector2(0, 0)
var move_remainder = Vector2(0, 0)
var collide_normal = Vector2(0, 0)
var colliding_body = null

const SimpleTimer = preload("res://scripts/simple_timer.gd")

func _ready():
	pass
	

func _physics_process(delta):
	if is_weighted == true:
		# Increase velocity due to gravity
		velocity.y += GRAVITY * delta
		
		# Set maximum speed a player can be moved by forces
		velocity = velocity.normalized() * min(velocity.length(), MAX_VELOCITY)
		
		# Try to move initially. Return the remainder of movement after collision
		# 1st arg is linear_velocity, no delta
		# 2nd arg is the expected normal vector of the floor
		move_and_slide(velocity + controller_velocity, Vector2(0, -1))
		
		var entity_collision = null
		if _is_on_surface():
			# If there is a collision on the ground, stop acceleration due to gravity 
			if is_on_floor():
				velocity.y = 0
				
			
			# If there is a collision with an entity, collect information
			if get_slide_count() > 0:
				entity_collision = get_slide_collision(0)
				collide_normal = entity_collision.normal
				colliding_body = entity_collision.collider
			
		# End if is on a surface
		if entity_collision == null:
			collide_normal = Vector2(0, 0)
			colliding_body = null
		
	# End if is_weighted

func _is_on_surface():
	return is_on_floor() or is_on_wall() or is_on_ceiling()
	

func is_char_colliding():
	var test = true
	if collide_normal == Vector2(0, 0):
		test = false
	return test
	

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
	

func drag(ground_drag, delta):
	var moving_direction = sign(velocity.x)
	velocity.x -= moving_direction * ground_drag * delta # Decelerate player if sliding without input
	if moving_direction != sign(velocity.x):
		velocity.x = 0
	
func set_controller_velocity(char_controller_velocity):
	controller_velocity = char_controller_velocity
	

func start_timer(timer_name, time):
	var simple_timer = SimpleTimer.new()
	simple_timer.start(self, timer_name, time)
	

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
	