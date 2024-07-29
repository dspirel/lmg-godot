extends Node2D

@onready var MAIN = get_node("/root/Main")

@onready var blue_button = $BlueSSButtonAnim
@onready var red_button = $RedSSButtonAnim
@onready var yellow_button = $YellowSSButtonAnim
@onready var green_button = $GreenSSButtonAnim

@onready var round_pause_timer = $RoundPauseTimer
@onready var round_duration_timer = $RoundDurationTimer
@onready var after_highlights_timer = $AfterHighlightsTimer

@onready var countdown_sound_timer = $CountdownSoundTimer

@onready var countdown_sound = $CountdownSound
@onready var button_push_sound = $ButtonPushSound

@onready var round_pause_timer_label = $RoundPauseTimerLabel
@onready var round_duration_timer_label = $RoundDurationTimerLabel

@onready var round_state_anim = $RoundStateAnim

@onready var winner_label = $WinnerLabel
@onready var load_level_fade_timer = $LoadLevelFadeTimer

@onready var player_slots :Array = $PlayerSlots.get_children()

var between_highlights_timer :float = 0.3
var highlight_duration_timer :float = 1.0
var round_duration :float = 10.0

var slots :Array = []
var players :Array = []
var memories :Array = []
var player_control :bool = false

signal button_animation_finished
#blue == 0 == square , red == 1 == triangle , yellow == 2 == circle, green == 3 == cross

func _ready():
	randomize()

func _physics_process(delta):
	if !round_pause_timer.is_stopped():
		round_pause_timer_label.text = str("%.1f" % round_pause_timer.time_left)
	elif !round_duration_timer.is_stopped():
		round_duration_timer_label.text = str("%.1f" % round_duration_timer.time_left)

func start_game():
	setup_player_slots()
	connect_SS_buttons_signals()
	add_memories(4)
	round_state_anim.play("stop")
	round_pause_timer.start(1.5)

func next_round():
	add_memories(1)
	reset_player_guesses()
	toggle_round_state()
	round_pause_timer.start(1.3)
	reset_players_states_highlights()

func add_memories(count :int):
	for i in count:
		memories.append(randi_range(0,3))

func play_memory_sequence():
	for m in memories:
		play_button_animation(m)
		await button_animation_finished
	
	after_highlights_timer.start(1)

func play_button_animation(button :int):
	#blue == 0 == square , red == 1 == triangle , yellow == 2 == circle, green == 3 == cross
	button_push_sound.play()
	if button == 0:
		blue_button.play("default")
	elif button == 1:
		red_button.play("default")
	elif button == 2:
		yellow_button.play("default")
	elif button == 3:
		green_button.play("default")

func toggle_round_state():
	if player_control:
		round_state_anim.play("stop")
		player_control = false
		return
	if !player_control:
		round_state_anim.play("go")
		player_control = true
		return

# --- TIMER SIGNALS ---
func _on_round_pause_timer_timeout():
	round_pause_timer_label.text = ""
	play_memory_sequence()

func _on_round_duration_timer_timeout():
	round_duration_timer_label.text = ""
	check_players_guesses_size()
	if get_alive_player_count() > 1:
		next_round()
	else:
		end_game()
	countdown_sound_timer.stop()
	countdown_sound.stop()

func _on_after_highlights_timer_timeout():
	toggle_round_state()
	round_duration_timer.start(memories.size() * 1.5)
	countdown_sound_timer.start()

func end_game():
	round_state_anim.play("stop")
	if get_alive_player_count() == 1:
		for p in players:
			if !p.missed:
				winner_label.text = p.color.capitalize() + " wins!"
	else:
		winner_label.text = "No winner!"
	player_control = false
	load_level_fade_timer.start(2.5)


func connect_SS_buttons_signals():
	var buttons :Array = [blue_button,red_button,yellow_button,green_button]
	for b in buttons:
		b.animation_finished.connect(_on_button_animation_finished)

func _on_button_animation_finished():
	button_animation_finished.emit()

func get_alive_player_count():
	var alive_count :int = 0
	for p in players:
		if !p.missed:
			alive_count += 1
	return alive_count

func check_if_players_finished():
	var players_count :int = players.size()
	var players_finished :int = 0
	for p in players:
		if p.missed or p.guesses == memories:
			players_finished += 1
	if players_finished == players_count:
		round_duration_timer.start(0.1)

func check_players_guesses_size():
	for p in players:
		if p.guesses.size() != memories.size():
			set_player_state_animation(p, "X")
			p.missed = true

func check_player_guess_on_input(player):
	if player.guesses.size() != memories.size():
		if player.guesses.back() == memories[player.guesses.size()-1]:
			highlight_player_state_on_correct_guess(player)
		else:
			player.missed = true
			set_player_state_animation(player, "X")
	else:
		set_player_finish_state_highlight(player)
	check_if_players_finished()

func set_player_state_animation(player, state):
	player_slots[player.slot].get_node("StateAnim").play(state)

func highlight_player_state_on_correct_guess(player):
	player_slots[player.slot].get_node("StateAnim").modulate = Color(0,1,0,1)
	await get_tree().create_timer(0.3).timeout
	player_slots[player.slot].get_node("StateAnim").modulate = Color(1,1,1,1)

func set_player_finish_state_highlight(player):
	player_slots[player.slot].get_node("StateAnim").modulate = Color(0,1,0,1)

func reset_players_states_highlights():
	for p in players:
		player_slots[p.slot].get_node("StateAnim").modulate = Color(1,1,1,1)

func get_player(device):
	for p in players:
		if p.device == device:
			return p

func add_player(p):
	var player :Dictionary = {"guesses": [], "missed": false}
	player["color"] = p.color
	player["device"] = p.device
	player["slot"] = p.slot
	player["wins"] = p.wins
	players.append(player)

func _input(event):
	if event is InputEventJoypadButton and player_control:
		var player = get_player(event.device)
		if !player.missed and player.guesses.size() < memories.size():
			if event.is_action_released("square"):
				player.guesses.append(0)
				check_player_guess_on_input(player)
			elif event.is_action_released("triangle"):
				player.guesses.append(1)
				check_player_guess_on_input(player)
			elif event.is_action_released("circle"):
				player.guesses.append(2)
				check_player_guess_on_input(player)
			elif event.is_action_released("cross"):
				player.guesses.append(3)
				check_player_guess_on_input(player)

func reset_player_guesses():
	for p in players:
		p.guesses = []

func setup_player_slots():
	var current_slot :int = 0
	for p in players:
		player_slots[current_slot].get_node("PlayerSprite").modulate = get_color(p.color)
		player_slots[current_slot].visible = true
		player_slots[current_slot].get_node("StateAnim").play("O")
		current_slot += 1

func get_color(color):
	if color == "red":
		return Color(1, 0.2, 0.2, 1)
	elif color == "green":
		return Color(0.2, 1, 0.2, 1)
	elif color == "blue":
		return Color(0.2, 0.2, 1, 1)
	elif color == "yellow":
		return Color(1, 1, 0.2, 1)

func load_new_level():
	for p in players:
		for k in p.keys():
			p.erase("guesses")
			p.erase("missed")
	MAIN.next_level(players)

func _on_countdown_sound_timer_timeout():
	countdown_sound.play()

func _on_load_level_fade_timer_timeout():
	load_new_level()




