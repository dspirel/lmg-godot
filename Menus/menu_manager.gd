extends Node2D

@onready var game_manager = get_parent().get_node("GameManager")
@onready var menu_controller = $MenuControllerComponent

@onready var main_menu = $Menus/MainMenu
@onready var options_menu = $Menus/OptionsMenu
@onready var sound_options_menu = $Menus/SoundOptionsMenu
@onready var game_setup_menu = $Menus/GameSetupMenu

@onready var audio_player = $AudioStreamPlayer

var current_menu = null

var control = true

func _ready():
	change_current_menu(main_menu)

func change_current_menu(new_menu):
	current_menu = new_menu
	set_menu_controller_selectables()
	go_to(current_menu)

func go_to(menu):
	control = false
	audio_player.play()
	var menu_position = current_menu.global_position
	var tween = create_tween()
	tween.tween_property(self, "position", -menu_position + position, 0.6).set_trans(Tween.TRANS_QUART)
	
	await get_tree().create_timer(0.4).timeout
	control = true

func set_menu_controller_selectables():
	menu_controller.set_selectables(current_menu.get_node("Selectables").get_children())

func _input(event):
	if control:
		if event.is_action_released("cross"): 
			#X CONFIRM INPUT
			if menu_controller.selection.type == "button":
			
				if current_menu == main_menu: # MAIN MENU
					if menu_controller.selection.button_text == "start":
						change_current_menu(game_setup_menu)
					elif menu_controller.selection.button_text == "options":
						change_current_menu(options_menu)
					elif menu_controller.selection.button_text == "exit":
						get_tree().quit()
				
				elif current_menu == game_setup_menu: # GAME MENU
					if menu_controller.selection.button_text == "start":
						#PASS CONTROL TO GAME MANAGER
						if current_menu.players.size() >= 2:
							game_manager.start_game_session(current_menu.players)
							control = false
							await get_tree().create_timer(1.6).timeout
							visible = false
					elif menu_controller.selection.button_text == "back":
						current_menu.reset_players_data()
						change_current_menu(main_menu)
				
				elif current_menu == options_menu: # OPTIONS MENU
					if menu_controller.selection.button_text == "sound":
						change_current_menu(sound_options_menu)
					elif menu_controller.selection.button_text == "back":
						change_current_menu(main_menu)
				
				elif current_menu == sound_options_menu: # SOUND OPTIONS MENU
					if menu_controller.selection.button_text == "back":
						ConfigSaveLoad.save_config()
						change_current_menu(options_menu)
		
		elif event.is_action_released("start"):
			#START INPUT
			if current_menu == game_setup_menu:
				current_menu.add_player(event.device)
		
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
			
			elif menu_controller.selection.type == "slider":
				if current_menu == sound_options_menu:
					
					if menu_controller.selection.button_text == "master":
						current_menu.change_bus_volume(AudioServer.get_bus_index("Master"), 1)
						current_menu.play_volume_variation_animation("master", -1)
					
					elif menu_controller.selection.button_text == "music":
						current_menu.change_bus_volume(AudioServer.get_bus_index("Music"), 1)
						current_menu.play_volume_variation_animation("music", -1)
					
					elif menu_controller.selection.button_text == "effects":
						current_menu.change_bus_volume(AudioServer.get_bus_index("Effects"), 1)
						current_menu.play_volume_variation_animation("effects", -1)
						current_menu.play_random_effect_sound()
		
		elif event.is_action_released("right"):
			#RIGHT INPUT
			if menu_controller.selection.type == "button":
				menu_controller.selection_change(1)
			
			elif menu_controller.selection.type == "slider":
				if current_menu == sound_options_menu:
					
					if menu_controller.selection.button_text == "master":
						current_menu.change_bus_volume(AudioServer.get_bus_index("Master"), -1)
						current_menu.play_volume_variation_animation("master", 1)
					
					elif menu_controller.selection.button_text == "music":
						current_menu.change_bus_volume(AudioServer.get_bus_index("Music"), -1)
						current_menu.play_volume_variation_animation("music", 1)
					
					elif menu_controller.selection.button_text == "effects":
						current_menu.change_bus_volume(AudioServer.get_bus_index("Effects"), -1)
						current_menu.play_volume_variation_animation("effects", 1)
						current_menu.play_random_effect_sound()

