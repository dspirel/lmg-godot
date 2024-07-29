extends Node2D

var ship = preload("res://ship.tscn")

@onready var label :Label = $Label
@onready var ball_splash_anim :AnimatedSprite2D = $BallSplashAnim
#@onready var ship :CharacterBody2D = $Ship

func _ready():
	$Water.visible = true
	var spos = $SpawnPositions.get_children()
	for i in 2:
		var nship = ship.instantiate()
		nship.device = i
		nship.global_position = spos[i].global_position
		nship.spawn_pos = spos[i].global_position
		add_child(nship)

func spawn_bs_anim(pos):
	var bs_anim = ball_splash_anim.duplicate()
	add_child(bs_anim)
	bs_anim.global_position = pos
	bs_anim.connect("animation_finished", delete_anim.bind(bs_anim))
	bs_anim.play("default")

func delete_anim(anim):
	anim.queue_free()



#func _physics_process(delta):
#	pass

#func update_label():
#	label.text = "speed: " + str(snapped(ship.speed, 0.1)) + "\nvelocity: " + str(ship.velocity) + "\nrot_speed: " + str(snapped(ship.rotation_speed, 0.1))
