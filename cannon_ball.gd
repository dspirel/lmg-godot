extends Area2D

@onready var ball_sprite = $BallSprite
@onready var ball_shadow_sprite = $BallShadowSprite

var direction :Vector2
var speed :float = 200

func _physics_process(delta):
	position += direction * speed * delta
	ball_shadow_sprite.position = lerp(ball_shadow_sprite.position, ball_sprite.position, 0.01)

func _on_timer_timeout():
	get_parent().spawn_bs_anim(global_position)
	queue_free()

func _on_body_entered(body):
	body.health_component.take_damage(1)
	queue_free()
