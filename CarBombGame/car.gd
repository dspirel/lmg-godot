extends CharacterBody2D

@onready var car_tires_anim = $CarTires
@onready var car_body_color = $CarBody
@onready var tire_particles = [$TireSmoke1,$TireSmoke2]
@onready var engine_audio = $EngineAudio
@onready var tire_skid_audio = $TireSkidAudio
@onready var bomb = $BombSprite
@onready var bomb_pass_cooldown = $BombPassCooldown

var wheel_base = 4
var steering_angle = 8

var steer_angle

var engine_power = 140  # Forward acceleration force.

var acceleration = Vector2.ZERO
var friction = -0.2
var drag = -0.0015
var accelerating = false
var braking = false

var brake_power = -80
var max_speed_reverse = 30

var slip_speed = 500  # Speed where traction is reduced
var traction_fast = 0.01  # High-speed traction
var traction_slow = 0.001  # Low-speed traction

var bomb_carry = false
var bomb_modulate_toggle = true

var device_id :int

func _ready():
	engine_audio.play()

func _physics_process(delta):
	acceleration = Vector2.ZERO
	get_input()
	
	if accelerating:
		acceleration = transform.x * engine_power
	if braking:
		acceleration = transform.x * brake_power
	
	apply_friction()
	calculate_steering(delta)
	velocity += acceleration * delta
	move_and_slide()
	update_engine_sound_volume()
	
	if get_slide_collision_count():
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider().has_method("take_bomb"):
				if bomb_carry and bomb_pass_cooldown.is_stopped():
					collision.get_collider().take_bomb()
					pass_bomb()
#			else:
#				velocity = velocity.bounce(collision.get_normal())


func update_engine_sound_volume():
	engine_audio.volume_db = -20 + (velocity.length() / 8)

func get_input():
	var turn = 0
	if Input.get_joy_axis(device_id,JOY_AXIS_LEFT_X) > 0.3:
		turn += Input.get_joy_axis(device_id,JOY_AXIS_LEFT_X)
	if Input.get_joy_axis(device_id,JOY_AXIS_LEFT_X) < -0.3:
		turn -= -Input.get_joy_axis(device_id,JOY_AXIS_LEFT_X)
	steer_angle = turn * deg_to_rad(steering_angle)
	
	if turn < 0:
		car_tires_anim.play("Left")
	if turn > 0:
		car_tires_anim.play("Right")
	if turn == 0:
		car_tires_anim.play("Straight")

func _input(event):
	if event.device == device_id:
		if event.is_action_pressed("R1"):
			accelerating = true
		if event.is_action_released("R1"):
			accelerating = false
		if event.is_action_pressed("L1"):
			braking = true
		if event.is_action_released("L1"):
			braking = false

func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_angle) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
	var d = new_heading.dot(velocity.normalized())
	if d < 0.6 and !tire_particles[0].emitting and velocity.length() > 50:
		for tp in tire_particles:
			tp.emitting = true
		if !tire_skid_audio.playing:
			tire_skid_audio.play()
	elif d > 0.6 and tire_particles[0].emitting:
		for tp in tire_particles:
			tp.emitting = false
		if tire_skid_audio.playing:
			tire_skid_audio.stop()
	if d > 0:
		velocity = velocity.lerp(new_heading * velocity.length(), traction)
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	rotation = new_heading.angle()

func apply_friction():
#	if velocity.length() < 5:
#		velocity = Vector2.ZERO
	var friction_force = velocity * friction
	var drag_force = velocity * velocity.length() * drag
#	if velocity.length() < 100:
#		friction_force *= 3
	acceleration += drag_force + friction_force

func take_bomb():
	bomb_carry = true
	bomb.visible = true
	bomb_pass_cooldown.start()

func pass_bomb():
	bomb_carry = false
	bomb.visible = false

func set_car_color(color):
	if color == "red":
		$CarBody.animation = "Red"
	elif color == "green":
		$CarBody.animation = "Green"
	elif color == "blue":
		$CarBody.animation = "Blue"
	elif color == "yellow":
		$CarBody.animation = "Yellow"

func _on_bomb_flash_timer_timeout():
	if bomb_carry:
		if bomb_modulate_toggle:
			bomb.modulate = Color(0.89, 0, 0.43, 1)
			bomb_modulate_toggle = false
			return
		if !bomb_modulate_toggle:
			bomb.modulate = Color(1, 1, 1, 1)
			bomb_modulate_toggle = true
			return

