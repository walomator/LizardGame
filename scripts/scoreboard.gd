extends Label

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func handle_attacked_enemy():
	print("Enemy head smashed")


func handle_bumped_enemy():
	print("You're toast!")