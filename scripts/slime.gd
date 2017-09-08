extends "monster.gd"
# parent class has _fixed_process

const BOUNCINESS = 200
const MAX_HEALTH = 2


func _ready():
	print("Slime loaded.")
	set_health(MAX_HEALTH)
	

#func get_bounciness():
#	return BOUNCINESS

func handle_player_hit_enemy_top(player, enemy):
#	print("Enemy got stomped.")
	set_health(get_health() - 1)
	
	

func handle_player_hit_enemy_side(player, enemy):
	print("Enemy hit player.")
	
