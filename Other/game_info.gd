extends Node2D

@onready var label = $Label

var snake_info = "SNAKE!!!!"
var car_bomb_info = "CAR BOMB!!!"
var platformer_race_info = "PLATFORMER"
var simon_info = "SIMON"

func update_info(game_name):
	if game_name == "snake":
		label.text = snake_info
		return
	elif game_name == "car_bomb":
		label.text = car_bomb_info
		return
	elif game_name == "simon":
		label.text = simon_info
		return
	elif game_name == "platformer_race":
		label.text = platformer_race_info
		return
