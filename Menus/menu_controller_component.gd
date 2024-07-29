extends Node

@onready var menu_manager = get_parent()
@onready var sound_player = $AudioStreamPlayer

var selectables :Array = []

var selection = null
var selection_index :int = 0
var selectables_count :int = 0

func selection_change(dir :int):
	if selection_index + dir > selectables_count:
		selection_index = 0
	elif selection_index + dir < 0:
		selection_index = selectables_count
	else:
		selection_index += dir
	
	set_selection()
	#sound_player.play()

func set_selection():
	if selection:
		stop_selected_animation()
	selection = selectables[selection_index]
	play_selected_animation()

func play_selected_animation():
	selection.play("default")

func stop_selected_animation():
	selection.stop()

func set_selectables(_selectables :Array):
	selectables = []
	for s in _selectables:
		selectables.append(s)
	selection_index = 0
	set_selection()
	selectables_count = selectables.size() - 1









#-
