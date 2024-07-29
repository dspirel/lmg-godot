extends Area2D

@onready var game = get_parent().get_parent().get_parent()

func _on_body_entered(body):
	if body.carrying_flag:
		game.add_flag_score(body.player_color)
