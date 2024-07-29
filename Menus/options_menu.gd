extends Node2D

@onready var menu_transition_controller = get_parent()
@onready var controller = $MenuControllerComponent

func on_action(selected_name, selected_type, action, slider_dir : int = 0):
	if action == "action_released":
		if selected_type == "button":
			if selected_name == "back":
				menu_transition_controller.go_to("main_menu")
				ConfigSaveLoad.save_config()
			if selected_name == "sound":
				menu_transition_controller.go_to("sound_options")
