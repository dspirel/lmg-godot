extends Node

var master_volume_value :float 
var music_volume_value :float
var effects_volume_value :float
var language_value :String

func _ready():
	load_config()
	#set_volumes()

func set_volumes():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master_volume_value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), music_volume_value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), effects_volume_value)

func save_config():
	var config = ConfigFile.new()
	
	config.set_value("data", "master_volume", AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	config.set_value("data", "music_volume", AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	config.set_value("data", "effects_volume", AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Effects")))
	
	config.set_value("data", "language", "english") #TODO
	
	config.save("user://config_options.cfg")

func load_config():
	var config = ConfigFile.new()

	var err = config.load("user://config_options.cfg")

	if err != OK:
		#set default values TODO
		return

	master_volume_value = config.get_value("data", "master_volume")
	music_volume_value = config.get_value("data", "music_volume")
	effects_volume_value = config.get_value("data", "effects_volume")
	language_value = config.get_value("data", "language") #TODO
