extends Node2D

@onready var cannon = $body/Cannon
@onready var joy_axis_sprite = $body/JoyAxis
@onready var body = $body

var device = 1
var rotation_speed = 4

func _ready():
	pass

func _physics_process(delta):
	update_input_dir(delta)

func _input(event):
	pass

func update_input_dir(delta):
	var cannon_input_direction = Vector2(Input.get_joy_axis(device,JOY_AXIS_RIGHT_X),Input.get_joy_axis(device,JOY_AXIS_RIGHT_Y))
	if cannon_input_direction.length() > 0.3:
		joy_axis_sprite.position = cannon_input_direction * 20
		var v = joy_axis_sprite.global_position -cannon.global_position
		var angle = v.angle()
		var angle_delta = rotation_speed * delta
		angle = lerp_angle(cannon.global_rotation, angle, 1.0)
		angle = clamp(angle, cannon.global_rotation - angle_delta, cannon.global_rotation + angle_delta)
		cannon.global_rotation = angle
#		cannon.look_at(joy_axis_sprite.global_position)
