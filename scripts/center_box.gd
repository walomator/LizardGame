extends KinematicBody2D

enum {NULL = 0, TOP = 1, BOTTOM = 2, LEFT = 4, RIGHT = 7,
      TOPLEFT = 5, TOPRIGHT = 8, BOTTOMLEFT = 6, BOTTOMRIGHT = 9}

signal exited_center_box

var area_node
var area_collision_node
var global_node
var player_body
var extents # distance from center
#var x_pos
#var y_pos
var center_pos
var offset

func _ready():
	area_node = get_node("Area2D")
	area_collision_node = area_node.get_node("CollisionShape2D")
	global_node = get_node("/root/Global/")
	player_body = get_node("/root/World/Protagonist/")
	
#	extents = Vector2(area_collision_node.get_shape().get_extents())
	extents = area_collision_node.get_shape().get_extents()
	center_pos = Vector2(area_collision_node.get_global_pos().x + extents.x, area_collision_node.get_global_pos().y + extents.y)
#	x_pos = self.get_global_pos().x
#	y_pos = self.get_global_pos().y
	
	area_node.connect("body_exit", self, "handle_body_exit")
	self.connect("exited_center_box", global_node, "handle_exited_center_box", [self])
	

func handle_body_exit(exiting_body):
	if exiting_body == player_body:
		offset = Vector2(0, 0)
		
		var player_coll = player_body.get_node("CollisionShape2D")
		var player_extents = player_coll.get_shape().get_extents()
		var player_pos = Vector2(player_coll.get_global_pos().x + player_extents.x, player_coll.get_global_pos().y + player_extents.y)
		
		
#		var exit_direction = NULL
		var x_distance = player_pos.x - center_pos.x
		var y_distance = player_pos.y - center_pos.y
		
		if x_distance > extents.x:
			offset.x += (x_distance - extents.x)
		elif x_distance < -extents.x:
			offset.x += (x_distance + extents.x)
			
		if y_distance > extents.y:
			offset.y += (y_distance - extents.y)
		elif y_distance < -extents.y:
			offset.y += (y_distance + extents.y)
			
		move(offset)
		print(offset)
		emit_signal("exited_center_box")
		
		
	

func get_offset():
	return offset
