extends Resource
class_name Player

#RefCounted

var color :String
var device: int
var slot: int
var score: int
var game_data: Dictionary = {}

func increase_score(value: int):
	score += value

func add_game_data(key: String, value):
	game_data[key] = value

func clear_game_data():
	game_data = {}
