extends Node2D

@onready var game_manager = get_parent()
@onready var slots = [$Slots/Slot1,$Slots/Slot2,$Slots/Slot3,$Slots/Slot4]

var score_positions = [Vector2(-43, -25),Vector2(-43, -10),Vector2(-43, 5),Vector2(-43, 20)]
var players :Array[Player]
var win_ordered_players = []

#TODO RESET ON QUIT TO MENU

func order_slots_positions(ordered_players :Array):
	var index = 0
	for p in ordered_players:
		move_slot(slots[p.slot], score_positions[index])
		index += 1

func move_slot(slot :Node2D, pos :Vector2):
	var tween = create_tween()
	tween.tween_property(slot, "position", pos, 1)
	

func sort_players_by_wins():
	var ordered_players = players
	ordered_players.sort_custom(high_to_low)
	win_ordered_players = ordered_players
	order_slots_positions(ordered_players)

func high_to_low(a,b):
	return a["score"] > b["score"]

func update_player_scores():
	for p in players:
		slots[p.slot].get_node("ScoreLabel").text = str(p.score)

func setup_player_slots(game_players):
	players = game_players
	for p in players:
		slots[p.slot].visible = true
		slots[p.slot].get_node("NameLabel").set("theme_override_colors/font_color", get_color(p.color))
		slots[p.slot].get_node("NameLabel").text = p.color.capitalize()
		slots[p.slot].get_node("ScoreLabel").text = str(0)

func get_color(color):
	if color == "red":
		return Color(1, 0.2, 0.2, 1)
	elif color == "green":
		return Color(0.2, 1, 0.2, 1)
	elif color == "blue":
		return Color(0.2, 0.2, 1, 1)
	elif color == "yellow":
		return Color(1, 1, 0.2, 1)
