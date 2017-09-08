extends Label

# Problems: This is a score system that doesn't follow the player

var score = 0
var score_locked = false

func _ready():
	_update_score(score)

func _update_score(new_score):
	if not score_locked:
		score = new_score
		set_text(str(score))
	

func _write_scoreboard(scoreboard_message):
	set_text(str(scoreboard_message))


func handle_attacked_enemy():
#	print("Enemy head smashed.")
	print("Player stomped enemy.")
	_update_score(score + 5)
	

func handle_bumped_enemy():
#	print("You're toast!")
	print("Enemy hit player.")
	_update_score(0)
	

func handle_passed_end_level():
	print("Level complete!")
	get_node("/root/World/Protagonist/Camera2D/Sprite").set_hidden(false)
	_write_scoreboard("Level complete!")
	score_locked = true
	

func handle_obtained_potion():
	print("The potion has been pocketed.")
	_update_score(score + 25)