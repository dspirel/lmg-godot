extends Game

var platform_char = preload("res://Platformer/player_platformer.tscn")

@onready var level = $PlatformerLevel1

var level_finished = false

func _ready():
	game_camera_zoom = Vector2(0.8,0.8)

func start_game():
	for p in players:
		var new_player = platform_char.instantiate()
		new_player.device_id = p.device
		new_player.global_position = level.start_position
		add_child(new_player)
		new_player.change_color(p.color)
		new_player.color = p.color

func _on_finish_body_entered(body):
	if !level_finished:
		level_finished = true
		for p in players:
			if p.color == body.color:
				p.score += 1
	
	$WinnerLabel.text = body.color.capitalize() + " wins!"
	end_game()
