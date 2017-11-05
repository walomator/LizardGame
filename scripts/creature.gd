extends KinematicBody2D
var health = 1


func _ready():
	print("In ready of character.gd")
	

func set_heatlh(player_health):
	if player_health > 0:
		health = player_health
	else:
		handle_death()
	

func handle_death():
	die()
	

func die():
	self.queue_free()