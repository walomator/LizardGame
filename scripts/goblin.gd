extends "monster.gd"
# parent class has _fixed_process

const BOUNCINESS = 150
const MAX_HEALTH = 3


func _ready():
	print("Goblin loaded.")
	set_health(MAX_HEALTH)
	

func handle_player_hit_enemy_top(player, enemy):
	set_health(get_health() - 1)
	

func handle_player_hit_enemy_side(player, enemy):
	print("Enemy hit player.")
	
