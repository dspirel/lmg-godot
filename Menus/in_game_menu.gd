extends Node2D

@onready var menu_controller = $MenuControllerComponent
@onready var game_manager = get_parent()

var control = false

func _ready():
	set_menu_controller_selectables()

func set_menu_controller_selectables():
	menu_controller.set_selectables(get_node("Selectables").get_children())

func show_menu():
	control = true
	visible = true

func hide_menu():
	control = false
	visible = false

func _input(event):
	if control:
		if event.is_action_released("cross"): 
			#X CONFIRM INPUT
			if menu_controller.selection.type == "button":
				if menu_controller.selection.button_text == "resume":
						game_manager.unpause_game()
		
		elif event.is_action_released("up"):
			#UP INPUT
			menu_controller.selection_change(-1)
			
		elif event.is_action_released("down"):
			#DOWN INPUT
			menu_controller.selection_change(1)
		
		elif event.is_action_released("left"):
			#LEFT INPUT
			if menu_controller.selection.type == "button":
				menu_controller.selection_change(-1)
		
		elif event.is_action_released("right"):
			#RIGHT INPUT
			if menu_controller.selection.type == "button":
				menu_controller.selection_change(-1)
