extends Node2D


# Needs protection against signal spamming

signal player_hit_enemy_top
signal player_hit_enemy_side
signal player_hit_trap_top
signal player_hit_trap_side

onready var SimpleTimer = load("res://scripts/simple_timer.gd")

const HIT_TIME = 0.1

var recently_collided = []


func _ready():
	pass
	

func handle_body_collided(detecting, colliding, normal):
	if detecting.get_name() in recently_collided or colliding.get_name() in recently_collided:
		return
	var detecting_timer = SimpleTimer.new()
	recently_collided.append(detecting.get_name())
	detecting_timer.start(self, detecting.get_name(), HIT_TIME)
	
	var colliding_timer = SimpleTimer.new()
	recently_collided.append(colliding.get_name())
	colliding_timer.start(self, colliding.get_name(), HIT_TIME)
	
	var is_detecting_player = detecting.is_in_group("Players")
	var is_detecting_enemy = detecting.is_in_group("Enemies")
	var is_colliding_player = colliding.is_in_group("Players")
	var is_colliding_enemy = colliding.is_in_group("Enemies")
	var is_colliding_trap = colliding.is_in_group("Traps")
	
	if (is_detecting_player and is_colliding_enemy) or (is_detecting_enemy and is_colliding_player):
		_handle_player_enemy_collided(detecting, colliding, normal)
	elif is_detecting_enemy and is_colliding_enemy:
		pass
	elif is_detecting_player and is_colliding_player:
		pass
	elif is_detecting_player and is_colliding_trap:
		_handle_player_trap_collided(detecting, colliding, normal)
	

func _handle_player_enemy_collided(detecting, colliding, normal):
	var player
	var enemy
	if detecting.is_in_group("Players"):
		player = detecting
		enemy = colliding
	else:
		enemy = detecting
		player = colliding
		# Force the normal to be from enemy's collision box
		normal = -normal
	
	self.connect("player_hit_enemy_top", detecting, "handle_player_hit_enemy_top")
	self.connect("player_hit_enemy_side", detecting, "handle_player_hit_enemy_side")
	self.connect("player_hit_enemy_top", colliding, "handle_player_hit_enemy_top")
	self.connect("player_hit_enemy_side", colliding, "handle_player_hit_enemy_side")
	
	if normal == Vector2(0, -1): # Player landed from above
		emit_signal("player_hit_enemy_top", player, enemy)
	elif normal == Vector2(1, 0) or normal == Vector2(-1, 0):
		emit_signal("player_hit_enemy_side", player, enemy, normal)
	
	self.disconnect("player_hit_enemy_top", detecting, "handle_player_hit_enemy_top")
	self.disconnect("player_hit_enemy_side", detecting, "handle_player_hit_enemy_side")
	self.disconnect("player_hit_enemy_top", colliding, "handle_player_hit_enemy_top")
	self.disconnect("player_hit_enemy_side", colliding, "handle_player_hit_enemy_side")
	

func handle_player_trap_collided(detecting, colliding, normal):
	if normal == Vector2(0, -1): # Player landed from above
		emit_signal("player_hit_trap_top", detecting, colliding)
	elif normal == Vector2(1, 0) or normal == Vector2(-1, 0):
		emit_signal("player_hit_trap_side", detecting, colliding, normal)
	

func handle_timeout(object_timer, name):
	recently_collided.erase(name)
	
	object_timer.queue_free()