extends "monster.gd"
# parent class has _fixed_process

const BOUNCINESS = 400


func _ready():
	print("Slime loaded.")


func handle_enemy_collided(direction):
	if direction.angle() == 0:
		print("Landed from above")
