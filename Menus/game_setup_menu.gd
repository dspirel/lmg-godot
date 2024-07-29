extends Node2D

@onready var slots = $Slots.get_children()

var colors = ["red","green","blue","yellow"]
var players = []

func _ready():
	set_slots_labels_empty()

func add_player(device):
	if check_if_device_joined(device):
		return
	var current_player_count = players.size()
	if current_player_count < 4:
		var new_player = {
			"color": colors[current_player_count],
			"device": device,
			"slot": current_player_count,
			"score": 0
		}
		players.append(new_player)
		set_slot_player_joined(new_player)

func reset_players_data():
	players = []
	set_slots_labels_empty()

func set_slot_player_joined(player):
	slots[player.slot].play("joined")
	slots[player.slot].get_node("Label").text = ""
	await slots[player.slot].animation_finished
	slots[player.slot].get_node("Label").text = get_slot_label_text()
	slots[player.slot].get_node("Label").set("theme_override_colors/font_color", get_color(player.color))

func set_slots_labels_empty():
	for slot in slots:
		slot.get_node("Label").text = "empty"
		slot.play("empty")
		slot.get_node("Label").set("theme_override_colors/font_color", Color(1,1,1,1))

func get_color(color):
	if color == "red":
		return Color(1, 0.2, 0.2, 1)
	elif color == "green":
		return Color(0.2, 1, 0.2, 1)
	elif color == "blue":
		return Color(0.2, 0.2, 1, 1)
	elif color == "yellow":
		return Color(1, 1, 0.2, 1)

func get_slot_label_text():
	var format_string = "player " + "{p}" + " joined!"
	var player_string = get_slot_label_player_string()
	var final_string = format_string.format({"p": player_string})
	return final_string

func get_slot_label_player_string():
	var current_player_count = players.size()
	if current_player_count == 1:
		return "one"
	elif current_player_count == 2:
		return "two"
	elif current_player_count == 3:
		return "three"
	elif current_player_count == 4:
		return "four"

func check_if_device_joined(device):
	var joined = false
	for p in players:
		if p.device == device:
			joined = true
	
	return joined
