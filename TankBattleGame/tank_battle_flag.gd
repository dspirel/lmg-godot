extends Area2D

@onready var reset_timer :Timer = $ResetTimer

var carried :bool = false
var carrier :CharacterBody2D

func _ready():
	$AnimatedSprite2D.play("wave")

func _physics_process(delta):
	if carrier:
		global_position = carrier.carry_flag_marker.global_position
		set_rotation_degrees(carrier.body.rotation)

func drop_flag():
	carried = false
	carrier = null

func reset_flag():
	carrier = null
	carried = false
	global_position = Vector2.ZERO

func _on_body_entered(body):
	if !carried:
		carrier = body
		carried = true
		
		carrier.carrying_flag = true

func _on_reset_timer_timeout():
	reset_flag()
