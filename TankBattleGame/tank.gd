extends CharacterBody2D

var shell = preload("res://TankBattleGame/shell.tscn")
var shot_sounds = [preload("res://TankBattleGame/tank_shot_1.wav"),preload("res://TankBattleGame/tank_shot_2.wav"),preload("res://TankBattleGame/tank_shot_3.wav")]

@onready var body :Node2D = $Body
@onready var cannon :Node2D = get_node("Cannon")
@onready var cannon_marker :Marker2D = cannon.get_node("Marker2D")
@onready var cannon_aim_position :Marker2D = $CannonAimPosition
@onready var cannon_area :Area2D = get_node("Cannon/CannonArea2D")
@onready var cannon_anim :AnimatedSprite2D = get_node("Cannon/CannonFireAnim")
@onready var carry_flag_marker :Marker2D = get_node("Body/CarryFlagPosition")
@onready var engine_sound_player :AudioStreamPlayer = get_node("EngineSoundPlayer")
@onready var cannon_rotation_sound_player :AudioStreamPlayer = get_node("CannonRotationSoundPlayer")
@onready var shooting_sound_player :AudioStreamPlayer = get_node("ShootingSoundPlayer")
@onready var reload_timer :Timer = get_node("ReloadTimer")
@onready var reload_tpb :TextureProgressBar = get_node("Cannon/ReloadTPB")
@onready var death_anim :AnimatedSprite2D = get_node("DeathAnim")
@onready var hurt_sound_player :AudioStreamPlayer = get_node("HurtSoundPlayer")
@onready var disable_timer :Timer = $DisableTimer
@onready var health_component :Node2D = $HealthComponent

var device :int = 1

var input_accelerating :bool = false
var input_b_accelerating :bool = false
var acceleration :float = 5
var direction :Vector2
var max_speed :float = 50
var speed :float = 0
var motion :Vector2

var last_turn_direction :int = 0
var turn_direction :int = 0
var turn_speed :float = 0
var turn_speed_power :float = 1.5
var max_turn_speed :float = 1.2
var turn_rotation :float

#var cannon_last_turn_direction :int = 0
#var cannon_input_direction :Vector2
#var cannon_turn_speed :float = 0
#var cannon_turn_speed_power :float = 0.5
#var cannon_max_turn_speed :float = 1.3
#var cannon_turn_rotation :float
var cannon_rotation_speed :float = 3.0

var reload_time :float = 3
var shell_speed :float = 800

var player_color :String
var carrying_flag :bool = false
var flag :Area2D
var starting_pos_rot :Array = []

func _ready():
	health_component.set_health(3)
	reload_tpb.max_value = reload_time

func _physics_process(delta):
	if disable_timer.is_stopped():
		update_front_direction()
		update_input_turn_direction()
		handle_body_turning(delta)
		handle_acceleration()
		motion = direction.normalized() * speed

		#CANNON
		handle_cannon_turning(delta)
		handle_engine_sound()
		handle_cannon_collision(cannon_area.get_overlapping_bodies(), delta)
		move_and_collide(motion * delta)

		if !reload_timer.is_stopped():
			reload_tpb.value = reload_timer.time_left
		if motion.length() < 1:
			motion = Vector2.ZERO

func handle_cannon_collision(bodies, delta):
	for b in bodies:
		if b != self:
			var col_dir =  global_position - cannon_marker.global_position
			move_and_collide(col_dir.normalized() * 30 * delta)

func handle_cannon_turning(delta):
	var cannon_input_direction = Vector2(Input.get_joy_axis(device,JOY_AXIS_RIGHT_X),Input.get_joy_axis(device,JOY_AXIS_RIGHT_Y))
	if cannon_input_direction.length() > 0.9:
		cannon_aim_position.position = cannon_input_direction * 20
		var v = cannon_aim_position.global_position - cannon.global_position
		var angle = v.angle()
		var angle_delta = cannon_rotation_speed * delta
		angle = lerp_angle(cannon.global_rotation, angle, 1.0)
		angle = clamp(angle, cannon.global_rotation - angle_delta, cannon.global_rotation + angle_delta)
		cannon.global_rotation = angle

func handle_acceleration():
	if input_accelerating:
		speed = lerp(speed, max_speed, 0.05)
	else:
		speed = lerp(speed, 0.0, 0.04)
		if is_zero_approx(speed):
			speed = 0
	
	speed = clampf(speed, 0, max_speed)

func handle_body_turning(delta):
	if turn_direction != last_turn_direction:
		turn_speed = 0
	if turn_direction:
		turn_speed += turn_speed_power * delta
		turn_rotation = lerpf(turn_rotation, turn_direction, 0.2)
	else:
		turn_speed -= turn_speed_power * delta #NE DELA
		turn_rotation = lerpf(turn_rotation , 0, 0.25)
	
	turn_speed = clampf(turn_speed, 0, max_turn_speed)
	
	if turn_speed > 0:
		body.rotate(turn_rotation * turn_speed * delta)
		$CollisionShape2D.rotate(turn_rotation * turn_speed * delta)

func update_input_turn_direction():
	#TANK BODY
	var input_direction = Input.get_joy_axis(device,JOY_AXIS_LEFT_X)
	if abs(input_direction) > 0.3:
		if  input_direction < 0:
			turn_direction = -1
			last_turn_direction = -1
		elif input_direction > 0:
			turn_direction = 1
			last_turn_direction = 1
	else:
		turn_direction = 0

func update_front_direction():
	if input_b_accelerating: 
		direction = global_position - $Body/FrontDirection.global_position
	else:
		direction = $Body/FrontDirection.global_position - global_position

func fire():
	if reload_timer.is_stopped() and disable_timer.is_stopped():
		var new_shell :RigidBody2D = shell.instantiate()
		var projectile_direction :Vector2
		new_shell.global_position = cannon_marker.global_position
		projectile_direction = cannon_marker.global_position - cannon.global_position
		new_shell.shell_owner = player_color 
		get_parent().add_child(new_shell)
		new_shell.look_at(projectile_direction * 100)
		new_shell.apply_central_impulse(projectile_direction.normalized() * shell_speed)
		play_fire_sound()
		var new_fire_anim = cannon_anim.duplicate()
		get_parent().add_child(new_fire_anim)
		new_fire_anim.global_transform = cannon_anim.global_transform
		new_fire_anim.connect("animation_finished", delete_anim.bind(new_fire_anim))
		new_fire_anim.play()
		reload_timer.start(reload_time)

func spawn_death_anim():
	var new_death_anim = death_anim.duplicate()
	get_parent().add_child(new_death_anim)
	new_death_anim.global_position = global_position
	new_death_anim.connect("animation_finished", delete_anim.bind(new_death_anim))
	new_death_anim.play("explode")

func delete_anim(anim):
	anim.queue_free()

func hurt():
	hurt_sound_player.play()
	
	health_component.take_damage(1)

func die():
	spawn_death_anim()
	if carrying_flag:
		flag.drop_flag()
		carrying_flag = false
	
	global_position = Vector2(1500,1500) + Vector2(randi_range(0,200),randi_range(0,200))
	disable_timer.start(5)
	health_component.set_health(3)

func play_fire_sound():
	shooting_sound_player.set_stream(shot_sounds[randi_range(0,shot_sounds.size()-1)])
	shooting_sound_player.volume_db = 0
	shooting_sound_player.play()

func handle_engine_sound():
	if motion.length() < 25 and !input_accelerating :
		engine_sound_player.volume_db -= 0.3
		if motion.length() < 3:
			engine_sound_player.volume_db = -30
			engine_sound_player.stop()

func start_engine_sound():
	engine_sound_player.volume_db = -30
	engine_sound_player.play()
	var tween = create_tween()
	tween.tween_property(engine_sound_player, "volume_db", 0, 2.5)

func _input(event):
	if event.device == device:
		if event.is_action_pressed("L1"):
			input_accelerating = true
			if !engine_sound_player.playing and disable_timer.is_stopped():
				start_engine_sound()
		elif event.is_action_released("L1"):
			input_accelerating = false
		
		elif event.is_action_pressed("L2"):
			input_b_accelerating = true
			input_accelerating = true
			if !engine_sound_player.playing and disable_timer.is_stopped():
				start_engine_sound()
		elif event.is_action_released("L2"):
			input_accelerating = false
			input_b_accelerating = false
			speed = 0
		
		elif event.is_action_pressed("R1"):
			fire()

func _on_disable_timer_timeout():
	global_position = starting_pos_rot[0]
	set_rotation_degrees(starting_pos_rot[1])
