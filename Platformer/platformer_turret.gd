extends Node2D

var bullet = preload("res://Platformer/platformer_turret_bullet.tscn")
@export var turret_direction :Vector2 = Vector2.ZERO
@export var shoot_time :float = 1.0
@export var start_marker :Marker2D
@export var bullet_speed :int

func _ready():
	$Timer.wait_time = shoot_time
	$Timer.start()

func _on_timer_timeout():
	var new_bullet = bullet.instantiate()
	new_bullet.direction = turret_direction
	new_bullet.level_start_pos = start_marker.global_position
	new_bullet.speed = bullet_speed
	add_child(new_bullet)
