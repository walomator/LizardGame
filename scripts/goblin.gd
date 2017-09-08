extends "monster.gd"
# parent class has _fixed_process

const BOUNCINESS = 200
const MAX_HEALTH = 3


func _ready():
	print("Goblin loaded.")
	set_health(MAX_HEALTH)
	

func handle_player_hit_enemy_top():
	print("Enemy got stomped.")
	set_health(get_health() - 1)
	

func handle_player_hit_enemy_side():
	print("Enemy hit player.")
	
