extends Node2D

var random_effect_sound = [
	preload("res://CarBombGame/car_explosion.wav"),
	preload("res://SnakeGame/snake_apple_bite.wav"),
	preload("res://SnakeGame/snake_hurt_sound.wav"),
	preload("res://Platformer/JumpSounds/jump4.wav"),
	preload("res://Platformer/DeathSounds/death_sound3.wav")
]

@onready var master_sound_volume_variation = $Selectables/MasterButton/VolumeVariation
@onready var effects_sound_volume_variation = $Selectables/EffectsButton/VolumeVariation
@onready var music_sound_volume_variation = $Selectables/MusicButton/VolumeVariation
@onready var effects_sound_samples_player = $EffectSoundsTest

var music_volume

func _ready():
	randomize()
	music_volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))

func play_random_effect_sound():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), -80)
	
	effects_sound_samples_player.set_stream(random_effect_sound[randi_range(0,random_effect_sound.size()-1)])
	effects_sound_samples_player.play()
	$EffectsTestingTimer.start(1)

func play_volume_variation_animation(node, dir):
	if node == "music":
		if dir == 1:
			music_sound_volume_variation.play("increase")
		elif dir == -1:
			music_sound_volume_variation.play("decrease")
	if node == "effects":
		if dir == 1:
			effects_sound_volume_variation.play("increase")
		elif dir == -1:
			effects_sound_volume_variation.play("decrease")
	if node == "master":
		if dir == 1:
			master_sound_volume_variation.play("increase")
		elif dir == -1:
			master_sound_volume_variation.play("decrease")
	
	$AnimResetTimer.start()

func change_bus_volume(bus, value):
	var current_volume = AudioServer.get_bus_volume_db(bus)
	var new_volume = current_volume - value
	
	AudioServer.set_bus_volume_db(bus, new_volume)
	
	if AudioServer.get_bus_index("Music") == bus:
		music_volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))

func _on_anim_reset_timer_timeout():
	master_sound_volume_variation.play("default")
	effects_sound_volume_variation.play("default")
	music_sound_volume_variation.play("default")

func _on_effects_testing_timer_timeout():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), music_volume)







#safsaf

