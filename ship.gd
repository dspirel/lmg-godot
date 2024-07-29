extends CharacterBody2D

var cannon_ball = preload("res://cannon_ball.tscn")

@onready var front_marker :Marker2D = $FrontDirection
@onready var water_particles :GPUParticles2D = $WaterParticles
@onready var aim_directions :Array = $AimDirections.get_children()
@onready var reload_timer_left :Timer = $ReloadTimerLeft
@onready var reload_timer_right :Timer = $ReloadTimerRight
@onready var reload_timer_front :Timer = $ReloadTimerFront
@onready var reload_timer_back :Timer = $ReloadTimerBack
@onready var health_component = $HealthComponent
@onready var health_bar = $HealthBar

var front_direction :Vector2

var last_tdir :int
var input_turn_direction :int = 0
var turn_direction: Vector2

var max_rotation_speed :float = 1.5
var rotation_speed :float = 0
var rotation_acceleration :float = 0.5

var max_speed :float = 40
var speed :float = 0
var acceleration :float = 15
var accelerating :bool = false

var aim_direction :String

var reload_time_lr :float = 2
var reload_time_fb :float = 1

var device :int = 0
var spawn_pos :Vector2
var starting_health = 20

func _ready():
	randomize()
	health_component.set_health(starting_health)
	health_bar.max_value = health_component.max_health
	health_bar.value = health_component.health

func _physics_process(delta):
	update_input_direction()
	handle_turning(delta)
	handle_velocity(delta)
	handle_particles()
	handle_aiming()
	move_and_slide()

func update_health_bar():
	health_bar.value = health_component.health

func die():
	global_position = Vector2(1251,1251)
	$ReviveTimer.start(3)

func fire():
	if aim_direction != "":
		var firing_points :Array
		if aim_direction == "left" and reload_timer_left.is_stopped():
			firing_points = aim_directions[0].get_children()
			reload_timer_left.start(reload_time_lr)
		
		elif aim_direction == "right" and reload_timer_right.is_stopped():
			firing_points = aim_directions[1].get_children()
			reload_timer_right.start(reload_time_lr)
		
		elif aim_direction == "front" and reload_timer_front.is_stopped():
			firing_points = aim_directions[2].get_children()
			reload_timer_front.start(reload_time_fb)
		
		elif aim_direction == "back" and reload_timer_back.is_stopped():
			firing_points = aim_directions[3].get_children()
			reload_timer_back.start(reload_time_fb)
		
		firing_points.shuffle()
		for i in firing_points:
			await get_tree().create_timer(randf_range(0.05,0.1)).timeout
			var fire_dir = (i.global_position - i.get_node("Marker2D").global_position).normalized()
			var cball = cannon_ball.instantiate()
			cball.global_position = i.global_position
			cball.direction = fire_dir
			cball.speed = 200 + randi_range(-10,10)
			get_parent().add_child(cball)

func handle_aiming():
	var joy_axis = Vector2(Input.get_joy_axis(device, JOY_AXIS_RIGHT_X), Input.get_joy_axis(device, JOY_AXIS_RIGHT_Y))
	if joy_axis.length() > 0.4:
		if joy_axis.x == -1:
			aim_directions[0].visible = true
			aim_direction = "left"
		else:
			aim_directions[0].visible = false
		if joy_axis.x == 1:
			aim_directions[1].visible = true
			aim_direction = "right"
		else:
			aim_directions[1].visible = false
		if joy_axis.y == 1:
			aim_directions[3].visible = true
			aim_direction = "back"
		else:
			aim_directions[3].visible = false
		if joy_axis.y == -1:
			aim_directions[2].visible = true
			aim_direction = "front"
		else:
			aim_directions[2].visible = false
	else:
		aim_direction = ""

func handle_turning(delta):
	if last_tdir != input_turn_direction:
		rotation_speed = 0
	if input_turn_direction != 0:
		rotation_speed = lerpf(rotation_speed,max_rotation_speed,0.005)
	elif input_turn_direction == 0:
		rotation_speed = lerpf(rotation_speed,0.0,0.005)
	rotate((rotation_speed + (speed / 60)) * input_turn_direction * delta)
	front_direction = (front_marker.global_position - global_position).normalized()

func handle_velocity(delta):
	if accelerating:
		speed = lerpf(speed, max_speed, 0.005)
	else:
		speed = lerpf(speed, 0, 0.005)
	
	clampf(speed,0.0,max_speed)
	velocity = front_direction * speed

func _input(event):
	if event.device == device:
		if event.is_action_pressed("R1"):
			accelerating = true
		elif event.is_action_released("R1"):
			accelerating = false
		elif event.is_action_pressed("L1"):
			fire()

func update_input_direction():
	var input_direction = Input.get_joy_axis(device,JOY_AXIS_LEFT_X)
	if abs(input_direction) > 0.3:
		if  input_direction < 0:
			input_turn_direction = -1
			last_tdir = -1
		elif input_direction > 0:
			input_turn_direction = 1
			last_tdir = 1
	else:
		input_turn_direction = 0

func handle_particles():
	if !water_particles.emitting and speed > 15:
		water_particles.emitting = true
	elif water_particles.emitting and speed < 15:
		water_particles.emitting = false
	if speed > 15:
		water_particles.process_material.initial_velocity_min = speed / 5
		water_particles.process_material.initial_velocity_max = speed / 3

func _on_revive_timer_timeout():
	health_component.set_health(starting_health)
	update_health_bar()
	global_position = spawn_pos
