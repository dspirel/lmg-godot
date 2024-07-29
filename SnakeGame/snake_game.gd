extends Game

var snake = preload("res://SnakeGame/snake.tscn")
var apple = preload("res://SnakeGame/apple.tscn")

@onready var overtime_label = get_node("CanvasLayer/OvertimeLabel")
@onready var countdown_label = get_node("CanvasLayer/GameTimeLabel")
@onready var winner_label = get_node("CanvasLayer/WinnerLabel")
@onready var game_timer = $GameTimer
@onready var slots = $Slots.get_children()
@onready var score_apple_timer :Timer = $ScoreAppleTimer
@onready var ice_apple_timer :Timer = $IceAppleTimer
@onready var golden_apple_timer :Timer = $GoldenAppleTimer
@onready var golden_apple_indicator :AnimatedSprite2D = $GoldenAppleSpawnIndicator

var snakes :Array = []
var if_overtime_string :String = ""
var golden_apple_spawn_position :Vector2
var golden_apple_indicator_highlighted :bool = false

func _ready():
	game_camera_zoom = Vector2(1,1)

func start_game():
	game_camera_zoom = Vector2(1,1)
	randomize()
	game_timer.start(90)
	for player in players:
		
		call_deferred("create_and_assign_snakes", player)
	call_deferred("set_player_positions")
	golden_apple_timer.start(randf_range(15.0,25.0))
	set_golden_apple_spawn_position()


func _physics_process(delta):
	countdown_label.text = str(floor(game_timer.time_left))
	if !golden_apple_indicator_highlighted and golden_apple_timer.time_left < 5.0:
		golden_apple_indicator.modulate = Color(1,0.6,0.6)
		golden_apple_indicator_highlighted = true

func spawn_apple():
	var new_apple = apple.instantiate()
	new_apple.position = Vector2(randi_range(-115,115),randi_range(-60,60))
	$Apples.add_child(new_apple)
	new_apple.set_apple_type("score")


func spawn_special_apple(apple_type :String):
	if apple_type == "ice":
		var new_apple = apple.instantiate()
		new_apple.position = Vector2(randi_range(-115,115),randi_range(-60,60))
		$SpecialApples.add_child(new_apple)
		new_apple.set_apple_type("ice")
	elif apple_type == "golden":
		var new_apple = apple.instantiate()
		new_apple.position = golden_apple_spawn_position
		$SpecialApples.add_child(new_apple)
		new_apple.set_apple_type("golden")
		golden_apple_indicator.visible = false

func set_golden_apple_spawn_position():
	golden_apple_indicator.modulate = Color(1,1,1)
	golden_apple_indicator_highlighted = false
	golden_apple_spawn_position = Vector2(randi_range(-35,35),randi_range(-20,20))
	golden_apple_indicator.position = golden_apple_spawn_position
	golden_apple_indicator.visible = true
	golden_apple_indicator.play("default")

func set_player_positions():
	for p in players:
		p.game_data.snake.global_position = slots[p.slot].get_node("Marker2D").global_position

func create_and_assign_snakes(player: Player):
	#ADD GAME SPECIFIC DATA
	player.add_game_data("snake", null)
	player.add_game_data("apples", 0)
	#CREATE SNAKE
	var new_snake = snake.instantiate()
	new_snake.get_node("Head").device_id = player.device
	new_snake.get_node("Head").slot = player.slot
	new_snake.get_node("Head").player = player
	
	player.game_data.snake = new_snake
	
	add_child(new_snake)
	snakes.append(new_snake)

func on_apple_eaten(body, apple_type):
	if apple_type == "score":
		body.eat_apple(2)
		body.player.game_data.apples += 1
		score_apple_timer.start(1)
	elif apple_type == "golden":
		body.eat_apple(6)
		body.player.game_data.apples += 5
		golden_apple_timer.start(randf_range(15.0,25.0))
		set_golden_apple_spawn_position()
	elif apple_type == "ice":
		ice_apple_timer.start(randf_range(6,10))
		var p_color = body.player.color
		for p in players:
			if p.color != p_color:
				p.game_data.snake.get_node("Head").stun()

func check_if_draw():
	var p_points = []
	for p in players:
		#if p.game_data.apples != 0:
		p_points.append(p.game_data.apples)
	
	var highest = 0
	for points in p_points:
		if points > highest:
			highest = points
	
	var draw_count = 0
	for points in p_points:
		if points == highest:
			draw_count += 1
	
	if draw_count >= 2:
		return true
	else:
		return false

func _on_game_timer_timeout():
	if check_if_draw():
		game_timer.start(10)
		overtime_label.visible = true
	else:
		find_and_declare_winner()

func find_and_declare_winner():
	var winner :Player = players[0]
	for p in players:
		if p.game_data.apples > winner.game_data.apples:
			winner = p
	
	winner.increase_score(1)
	winner_label.text = winner.color.capitalize() + " wins!"
	
	for p in players:
		p.game_data.snake.get_node("Head").speed = 0
		p.game_data.snake.get_node("Head").current_boost_energy = 0
		p.game_data.snake.get_node("Head").max_speed = 0
	var tween = create_tween()
	tween.tween_property($AudioStreamPlayer, "volume_db", -40, 3).set_trans(Tween.TRANS_LINEAR)
	countdown_label.visible = false
	overtime_label.visible = false
	end_game()

func _on_show_countdown_label_timer_timeout():
	countdown_label.visible = true

func _on_apple_timer_timeout():
	if $Apples.get_children().size() < 1:
		spawn_apple()

func _on_ice_apple_timer_timeout():
	spawn_special_apple("ice")

func _on_golden_apple_timer_timeout():
	spawn_special_apple("golden")
