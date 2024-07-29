extends RigidBody2D

@onready var game = get_parent()

var shell_owner :String

func _on_body_entered(body):
	if body.has_method("hurt"):
		body.hurt()
	game.play_shell_explode_animation(global_position)
	queue_free()
