extends Node2D

@onready var parent = get_parent()

var max_health :int
var health :int

func set_health(value):
	max_health = value
	health = max_health

func take_damage(dmg):
	health -= dmg
	parent.update_health_bar()
	if health <= 0:
		parent.die()


