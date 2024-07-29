extends Node
class_name Game

@onready var game_manager = get_parent()

var game_name :String
var game_camera_zoom :Vector2
var players :Array[Player]

func start_game():
	pass

func end_game():
	for player in players:
		player.clear_game_data()
	game_manager.next_game()


