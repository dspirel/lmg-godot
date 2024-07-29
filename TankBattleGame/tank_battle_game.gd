extends Game

var tank = preload("res://TankBattleGame/tank.tscn")
@onready var spawn_positions = $SpawnPositions.get_children()
@onready var flag = $Flag
@onready var shell_explosion_anim = $ShellExplosionAnim

var game_ended = false

func _ready():
	game_camera_zoom = Vector2(0.2, 0.2)

func start_game():
	var tank_rotations = [90, -90, 90, -90]
	var index = 0
	for p in players:
		var new_tank :CharacterBody2D = tank.instantiate()
		new_tank.device = p.device
		new_tank.global_position = spawn_positions[index].global_position
		spawn_positions[index].get_children()[0].get_node("AnimatedSprite2D").play(p.color)
		add_child(new_tank)
		new_tank.body.set_rotation_degrees(tank_rotations[index])
		new_tank.get_node("CollisionShape2D").set_rotation_degrees(tank_rotations[index])
		new_tank.starting_pos_rot = [spawn_positions[index].global_position, tank_rotations[index]]
		new_tank.player_color = p.color
		new_tank.flag = flag
		set_tank_color(new_tank, p)
		index += 1
		
		p.add_game_data("tank", new_tank)
		p.add_game_data("flag_score", 0)

func add_flag_score(player_color):
	for p in players:
		if p.color == player_color:
			p.game_data.flag_score += 1
			p.game_data.tank.carrying_flag = false
			flag.global_position = Vector2(1000,1000)
			flag.drop_flag()
			flag.reset_timer.start(8)
			if p.game_data.flag_score > 1 and !game_ended:
				p.score += 1
				game_ended = true
				end_game()

func play_shell_explode_animation(pos):
	var new_shell_explosion_anim = shell_explosion_anim.duplicate()
	new_shell_explosion_anim.global_position = pos
	get_parent().add_child(new_shell_explosion_anim)
	new_shell_explosion_anim.connect("animation_finished", delete_anim.bind(new_shell_explosion_anim))
	new_shell_explosion_anim.play("default")

func delete_anim(anim):
	anim.queue_free()

func set_tank_color(tank,player):
	if player.color == "red":
		tank.get_node("Body/BodySprite").animation = "red"
		tank.get_node("Cannon/CannonSprite").animation = "red"
	elif player.color == "blue":
		tank.get_node("Body/BodySprite").animation = "blue"
		tank.get_node("Cannon/CannonSprite").animation = "blue"
	elif player.color == "green":
		tank.get_node("Body/BodySprite").animation = "green"
		tank.get_node("Cannon/CannonSprite").animation = "green"
	elif player.color == "yellow":
		tank.get_node("Body/BodySprite").animation = "yellow"
		tank.get_node("Cannon/CannonSprite").animation = "yellow"


