extends Area2D

var direction = Vector2.ZERO
var speed = 20
var level_start_pos = Vector2.ZERO

func _ready():
	pass

func _physics_process(delta):
	position += direction * delta * speed

func _on_body_entered(body):
	if body is CharacterBody2D:
		body.return_to_start(level_start_pos)
	queue_free()
