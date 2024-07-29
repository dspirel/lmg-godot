extends Node2D

@onready var camera = get_parent().get_node("Camera2D")
@onready var ingame_menu = $InGameMenu
@onready var fade_color_rect = $FadeColorRect
@onready var transition_input_pause_timer = $TransitionInputPauseTimer
@onready var game_info = $GameInfo
@onready var score_info = $ScoreInfo

@onready var state_label = $StateLabel

var simon_says_game = preload("res://SSGame/simon_says_game.tscn")
var snake_game = preload("res://SnakeGame/snake_game.tscn")
var platformer_race_game = preload("res://Platformer/platformer_game.tscn")
var car_bomb_game = preload("res://CarBombGame/car_bomb_level.tscn")
var tank_game = preload("res://TankBattleGame/tank_battle_game.tscn")
#TODO CREATE QUEUED GAMES LIST AND THAN LOAD???
var queued_games :Array = ["car_bomb", "tank_battle", "snake", "platformer_race"]
var next_game_index :int = 0

var players :Array[Player]
var current_game = null

#var last_state :States
var state :States = States.GAME_INFO
enum States {GAME_RUNNING, SCORE_INFO, GAME_INFO, GAME_PAUSED}

func _process(delta):
	state_label.text = States.keys()[state]

func _input(event):
	if current_game:
		#NEXT TRANSITION INPUT
		if event.is_action_pressed("cross"):
			if [States.GAME_INFO, States.SCORE_INFO].has(state) and transition_input_pause_timer.is_stopped():
				next_transition()
		#PAUSE GAME INPUT
		elif event.is_action_released("start"):
			if state == States.GAME_RUNNING:
				pause_game()

func next_transition():
	if state == States.GAME_INFO:
		start_transition("game")
	elif state == States.SCORE_INFO:
		start_transition("game_info")

func start_transition(to):
	transition_input_pause_timer.start(1.5)
	if to == "game_info":
		hide_score_info()
		change_state(States.GAME_INFO)
		await get_tree().create_timer(1).timeout
		show_game_info()
	elif to == "score_info":
		change_state(States.SCORE_INFO)
		score_info.update_player_scores()
		await get_tree().create_timer(1).timeout
		set_camera_zoom(Vector2(1,1))
		show_score_info()
	elif to == "game":
		set_camera_zoom(current_game.game_camera_zoom)
		change_state(States.GAME_RUNNING)
		current_game.visible = true
		hide_game_info()
		fade_out()
		await get_tree().create_timer(1).timeout
		current_game.start_game()

func show_score_info():
	score_info.visible = true
	score_info.sort_players_by_wins()

func hide_score_info():
	score_info.visible = false

func show_game_info():
	game_info.update_info(current_game.game_name)
	game_info.visible = true

func hide_game_info():
	game_info.visible = false

func next_game():
	fade_in()
	start_transition("score_info")
	await get_tree().create_timer(1.6).timeout
	current_game.queue_free()
	load_new_game(queued_games[next_game_index])
	current_game.players = players

func start_game_session(dict_players):
	#FIRST GAME OF GAME SESSION
	load_new_game(queued_games[next_game_index])
	fade_in()
	start_transition("game_info")
	create_players(dict_players)
	current_game.visible = false
	current_game.players = players
	
	score_info.setup_player_slots(players)

func change_state(new_state :States):
	#last_state = old_state
	state = new_state

func pause_game():
	change_state(States.GAME_PAUSED)
	ingame_menu.show_menu()
	current_game.process_mode = PROCESS_MODE_DISABLED

func unpause_game():
	change_state(States.GAME_RUNNING)
	ingame_menu.hide_menu()
	current_game.process_mode = PROCESS_MODE_ALWAYS


func create_players(dict_players :Array):
	var new_players :Array[Player]
	for player in dict_players:
		new_players.append(add_player(player))
	players = new_players

func add_player(p :Dictionary):
	var player = Player.new()
	player.color = p.color
	player.device = p.device
	player.slot = p.slot
	player.score = p.score
	return player

func set_camera_zoom(zoom :Vector2):
	camera.zoom = zoom

func fade_in():
	var tween = create_tween()
	tween.tween_property(fade_color_rect, "color", Color(0,0,0,1), 1.5).set_trans(Tween.TRANS_QUAD)
	#await get_tree().create_timer(2.1).timeout

func fade_out():
	var tween = create_tween()
	tween.tween_property(fade_color_rect, "color", Color(0,0,0,0), 1.5).set_trans(Tween.TRANS_QUAD)

func unload_game():
	if current_game:
		current_game.queue_free()

func load_new_game(game_name :String):
	#games: snake, simon, platformer_race, car_bomb
	if game_name == "snake":
		var new_game = snake_game.instantiate()
		new_game.game_name = "snake"
		add_child(new_game)
		current_game = new_game
	elif game_name == "tank_battle":
		var new_game = tank_game.instantiate()
		new_game.game_name = "tank_battle"
		add_child(new_game)
		current_game = new_game
	
	elif game_name == "simon":
		var new_game = simon_says_game.instantiate()
		add_child(new_game)
		current_game = new_game
	
	elif game_name == "platformer_race":
		var new_game = platformer_race_game.instantiate()
		add_child(new_game)
		current_game = new_game
	
	elif game_name == "car_bomb":
		var new_game = car_bomb_game.instantiate()
		new_game.game_name = "car_bomb"
		add_child(new_game)
		current_game = new_game

	
	#INCREASE NEXT_GAME_INDEX
	var queued_games_size :int = queued_games.size() - 1
	if next_game_index + 1 > queued_games_size:
		next_game_index = 0
	else:
		next_game_index += 1
