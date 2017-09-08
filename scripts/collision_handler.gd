extends Node2D


signal player_hit_enemy_top
signal player_hit_enemy_side

func _ready():
	pass
	

func handle_body_collided(detecting, colliding, normal):
	var is_detecting_player = detecting.is_in_group("Players")
	var is_detecting_enemy = detecting.is_in_group("Enemies")
	var is_colliding_player = colliding.is_in_group("Players")
	var is_colliding_enemy = colliding.is_in_group("Enemies")
	
	if (is_detecting_player and is_colliding_enemy) or (is_detecting_enemy and is_colliding_player):
		_handle_player_enemy_collided(detecting, colliding, normal)
	elif is_detecting_enemy and is_colliding_enemy:
		pass
	elif is_detecting_player and is_colliding_player:
		pass
	

func _handle_player_enemy_collided(detecting, colliding, normal):
	self.connect("player_hit_enemy_top", detecting, "handle_player_hit_enemy_top")
	self.connect("player_hit_enemy_side", detecting, "handle_player_hit_enemy_side")
	self.connect("player_hit_enemy_top", colliding, "handle_player_hit_enemy_top")
	self.connect("player_hit_enemy_side", colliding, "handle_player_hit_enemy_side")
	
	# Force the normal to be from enemy's collision box
	if detecting.is_in_group("Enemies"):
		normal = -normal
	
	if normal == Vector2(0, -1): # Player landed from above
		emit_signal("player_hit_enemy_top")
	elif normal == Vector2(1, 0) or normal == Vector2(-1, 0):
		emit_signal("player_hit_enemy_side")
	
	self.disconnect("player_hit_enemy_top", detecting, "handle_player_hit_enemy_top")
	self.disconnect("player_hit_enemy_side", detecting, "handle_player_hit_enemy_side")
	self.disconnect("player_hit_enemy_top", colliding, "handle_player_hit_enemy_top")
	self.disconnect("player_hit_enemy_side", colliding, "handle_player_hit_enemy_side")
