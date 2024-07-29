extends Area2D

@onready var game = get_parent().get_parent()
@onready var anim = $AnimatedSprite2D

var apple_type :String

func _on_body_entered(body):
	game.on_apple_eaten(body, apple_type)
	queue_free()

func set_apple_type(type):
	if type == "score":
		apple_type = "score"
		anim.play("score")
	elif type == "ice":
		apple_type = "ice"
		anim.play("ice")
	elif type == "golden":
		anim.offset = Vector2(0.5,0.5)
		apple_type = "golden"
		anim.play("golden")
