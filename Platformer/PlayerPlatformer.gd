extends CharacterBody2D

var death_particles = preload("res://Platformer/platformer_spike_death_particles.tscn")
var step_sounds = [preload("res://Platformer/StepSounds/step1.wav"),preload("res://Platformer/StepSounds/step2.wav"),preload("res://Platformer/StepSounds/step3.wav"),preload("res://Platformer/StepSounds/step4.wav"),preload("res://Platformer/StepSounds/step5.wav")]
var jump_sounds = [preload("res://Platformer/JumpSounds/jump1.wav"),preload("res://Platformer/JumpSounds/jump2.wav"),preload("res://Platformer/JumpSounds/jump3.wav"),preload("res://Platformer/JumpSounds/jump4.wav"),preload("res://Platformer/JumpSounds/jump5.wav")]
var death_sounds = [preload("res://Platformer/DeathSounds/death_sound1.wav"),preload("res://Platformer/DeathSounds/death_sound2.wav"),preload("res://Platformer/DeathSounds/death_sound3.wav")]
var land_sound = preload("res://Platformer/land_sound1.wav")

@onready var left_wall_raycasts = $WallRaycasts/LeftWallRaycasts
@onready var right_wall_raycasts = $WallRaycasts/RightWallRaycasts
@onready var wall_slide_cooldown = $WallSlideCooldown
@onready var wall_slide_sticky_timer = $WallSlideStickyTimer
@onready var coyote_timer = $CoyoteTimer
@onready var jump_buffer_timer = $JumpBufferTimer
@onready var anim = $AnimatedSprite2D
@onready var sound_player = $StepJumpSounds
@onready var sound_2_player = $LandSounds
@onready var death_sounds_player = $DeathSounds

@onready var step_sound_timer = $StepSoundTimer

const WALL_JUMP_VELOCITY = Vector2(20, -70)
const TILE_SIZE = 4.5

var direction = Vector2.ZERO
var move_direction = 0
var speed = 8 * TILE_SIZE
var wall_direction = 1
var wall_jump_speed = 0

var gravity
var max_jump_velocity
var min_jump_velocity

var on_floor = false

var max_jump_height = 3.25 * TILE_SIZE
var min_jump_height = 0.8 * TILE_SIZE
var jump_duration = 0.4

var device_id = 1
var color :String

func _ready():
	randomize()
	gravity = 2 * max_jump_height / pow(jump_duration, 2)
	max_jump_velocity = -sqrt(2 * gravity * max_jump_height)
	min_jump_velocity = -sqrt(2 * gravity * min_jump_height)

func change_color(color):
	anim.self_modulate = get_color(color)

func get_color(color):
	if color == "red":
		return Color(1, 0.2, 0.2, 1)
	elif color == "green":
		return Color(0.2, 1, 0.2, 1)
	elif color == "blue":
		return Color(0.2, 0.2, 1, 1)
	elif color == "yellow":
		return Color(1, 1, 0.2, 1)

func apply_movement(delta):
	move_and_slide()
	if is_on_floor() and !jump_buffer_timer.is_stopped():
		jump_buffer_timer.stop()
		jump()

func jump():
	velocity.y = max_jump_velocity
	sound_player.set_stream(jump_sounds[randi_range(0,jump_sounds.size()-1)])
	sound_player.volume_db = -12
	sound_player.play()

func handle_movement():
	velocity.x = lerp(velocity.x, direction.x * speed + wall_jump_speed, 0.5)

func wall_jump():
	var wall_jump_velocity = WALL_JUMP_VELOCITY
	wall_jump_velocity.x *= -wall_direction
	wall_jump_speed = wall_jump_velocity.x
	velocity.y = wall_jump_velocity.y
	sound_player.set_stream(jump_sounds[randi_range(0,jump_sounds.size()-1)])
	sound_player.volume_db = -12
	sound_player.play()

func cap_gravity_wall_slide():
	var joystick_y_dir = Input.get_joy_axis(device_id,JOY_AXIS_RIGHT_Y)
	var max_velocity = 20 if joystick_y_dir < 0.3 else 40
	velocity.y = min(velocity.y, max_velocity)

func handle_wall_slide_sticking():
	if move_direction != 0 and move_direction != wall_direction:
		if wall_slide_sticky_timer.is_stopped():
			wall_slide_sticky_timer.start()
	else:
		wall_slide_sticky_timer.stop()

#func update_move_direction():
#	if abs(Input.get_joy_axis(device_id,JOY_AXIS_RIGHT_X)) > 0.3:
#		if direction.x > 0:
#			move_direction = 1
#		elif direction.x < 0:
#			move_direction = -1
#	else:
#		move_direction = 0

func handle_move_input():
	if abs(Input.get_joy_axis(device_id,JOY_AXIS_RIGHT_X)) > 0.3:
		direction.x = Input.get_joy_axis(device_id,JOY_AXIS_RIGHT_X)
		if direction.x > 0.3:
			move_direction = 1
			anim.scale.x = 1
		else:
			move_direction = -1
			anim.scale.x = -1
	else:
		direction.x = 0
		move_direction = 0

func apply_gravity(delta):
	velocity.y += gravity * delta

func update_wall_direction():
	var is_near_wall_left = check_is_valid_wall(left_wall_raycasts)
	var is_near_wall_right = check_is_valid_wall(right_wall_raycasts)
	
	if is_near_wall_left and is_near_wall_right:
		wall_direction = move_direction
	
	wall_direction = -int(is_near_wall_left) + int(is_near_wall_right)

func check_is_valid_wall(wall_raycasts):
	for raycast in wall_raycasts.get_children():
		if raycast.is_colliding():
			var dot = acos(Vector2.UP.dot(raycast.get_collision_normal()))
			if dot > PI * 0.35 and dot < PI * 0.55:
				return true
	return false

func instantiate_death_particles():
	var particles = death_particles.instantiate()
	particles.global_position = global_position
	get_parent().add_child(particles)
	particles.emitting = true

func return_to_start(pos):
	play_death_sound()
	instantiate_death_particles()
	velocity = Vector2.ZERO
	global_position = pos

func play_death_sound():
	death_sounds_player.set_stream(death_sounds[randi_range(0,death_sounds.size()-1)])
	death_sounds_player.volume_db = -6
	death_sounds_player.play()

func _on_step_sound_timer_timeout():
	sound_player.set_stream(step_sounds[randi_range(0,step_sounds.size()-1)])
	sound_player.volume_db = -6
	sound_player.play()
