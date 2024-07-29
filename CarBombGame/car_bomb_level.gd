extends Game

var car = preload("res://CarBombGame/arcade_car.tscn")

@onready var bomb_tick_sound = $BombTickSound
@onready var bomb_tick_timer = $BombBeepTick
@onready var bomb_timer = $BombTimer
@onready var winner_label = $WinnerLabel
@onready var explosion_anim = $BombExplosionAnim

var round_time:float = 35

func _ready():
	game_camera_zoom = Vector2(0.25,0.25)

func start_game():
	instantiate_cars()
	set_car_positions()
	bomb_timer.start(round_time)
	bomb_tick_timer.wait_time = 1
	bomb_tick_timer.start(1)
	set_bomb()

func instantiate_cars():
	for p in players:
		var new_car = car.instantiate()
		new_car.device = p.device
		$Cars.add_child(new_car)
		new_car.get_node("AnimatedSprite2D").play(p.color)
		
		p.add_game_data("car", new_car)
		p.add_game_data("car_alive", true)

func set_bomb():
	var alive_players = []
	for p in players:
		#print(p.game_data)
		if p.game_data.car_alive:
			alive_players.append(p)
	var player_count = alive_players.size()
	alive_players[randi_range(0,player_count-1)].game_data.car.take_bomb()

func set_car_positions():
	var positions = $StartingPositions.get_children()
	var slot = 0
	for p in players:
		if p.game_data.car_alive:
			if slot == 1 or slot == 4:
				p.game_data.car.rotation_degrees = -180
			p.game_data.car.global_position = positions[slot].global_position
			slot += 1

func _on_bomb_timer_timeout():
	$BombExplosionSound.play()
	for p in players:
		if is_instance_valid(p.game_data.car):
			if p.game_data.car.bomb_carry:
				explosion_anim.global_position = p.game_data.car.global_position
				explosion_anim.play("default")
				p.game_data.car_alive = false
				p.game_data.car.queue_free()
	if check_if_last_car_alive():
		for p in players:
			if p.game_data.car_alive:
				winner_label.text = p.color.capitalize() + " wins!"
				p.score += 1
		end_game()
	else:
		set_bomb()
		bomb_timer.start(round_time)
		bomb_tick_timer.wait_time = 1

func check_if_last_car_alive():
	var alive_count = 0
	for p in players:
		if p.game_data.car_alive:
			alive_count += 1
	if alive_count == 1:
		return true
	else:
		return false

func _on_bomb_beep_tick_timeout():
	bomb_tick_sound.play()
	if bomb_timer.time_left < 15.0 and bomb_timer.time_left > 11.0:
		bomb_tick_timer.wait_time = 0.7
	elif bomb_timer.time_left < 10 and bomb_timer.time_left > 6.0:
		bomb_tick_timer.wait_time = 0.4
	elif bomb_timer.time_left < 4:
		bomb_tick_timer.wait_time = 0.2
	if bomb_timer.is_stopped():
		bomb_tick_timer.stop()

