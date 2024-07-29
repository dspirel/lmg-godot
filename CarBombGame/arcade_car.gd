extends CharacterBody2D

@onready var bomb_pass_cooldown_timer :Timer = $BombPassCooldownTimer
@onready var collision_slow_timer :Timer = $CollisionSlowTimer
@onready var bomb_sprite :Sprite2D = $BombSprite
@onready var bomb_flash_timer :Timer = $BombFlashTimer
@onready var tires_anim :AnimatedSprite2D = $TiresAnim
@onready var engine_sound :AudioStreamPlayer = $EngineSound
@onready var take_bomb_slow_timer :Timer = $SlowTimer

var device :int = 1

var input_accelerating :bool = false
var input_reverse :bool = false
var acceleration :float = 30.0
var direction :Vector2
var last_direction :int
var max_speed :float = 180.0
var reverse_max_speed :float = 110.0
var speed :float = 0.0
var motion :Vector2
var slow_multiplier :float = 1.0

var last_turn_direction :int = 0
var turn_direction :int = 0
var turn_speed :float
var max_turn_speed :float = 2.0
var turn_rotation :float

var player_color :String

var bomb_carry :bool = false
var bomb_modulate_toggle :bool = false

func _ready():
	pass

func _physics_process(delta):
	update_front_direction()
	update_input_turn_direction()
	handle_body_turning(delta)
	handle_acceleration()
	velocity = direction.normalized() * (speed * slow_multiplier)
	move_and_slide()
	if get_slide_collision_count():
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider().has_method("take_bomb"):
				if bomb_carry and bomb_pass_cooldown_timer.is_stopped():
					pass_bomb(collision.get_collider())
		if collision_slow_timer.is_stopped():
			speed /= 4
			collision_slow_timer.start(0.5)
	engine_sound.volume_db = -30 + (abs(speed) / 20)

func handle_acceleration():
	if input_accelerating:
		speed = lerpf(speed, max_speed, 0.15)
	
	elif input_reverse:
		speed = lerpf(speed, -reverse_max_speed, 0.15)

	else:
		speed = lerpf(speed, 0.0, 0.03)
		if is_zero_approx(speed):
			speed = 0
	
	speed = clampf(speed, -reverse_max_speed, max_speed)

func take_bomb():
	max_speed += 25
	bomb_carry = true
	bomb_sprite.visible = true
	bomb_pass_cooldown_timer.start()
	take_bomb_slow_timer.start(2.0)
	slow_multiplier = 0.5

func pass_bomb(car):
	max_speed -= 25
	bomb_carry = false
	bomb_sprite.visible = false
	car.take_bomb()

func handle_body_turning(delta):
	if turn_direction:
		turn_rotation = turn_direction
		if speed > 50:
			turn_speed = abs(speed / 100) + 1.4
		else:
			turn_speed = abs(speed / 100) + 1.6
	if abs(speed) < 5 or !turn_direction:
		turn_rotation = 0
	
	if turn_speed > 0:
		rotate(turn_rotation * turn_speed * delta)
#		#$CollisionShape2D.rotate(turn_rotation * turn_speed * delta)

func update_input_turn_direction():
	var input_direction = Input.get_joy_axis(device,JOY_AXIS_LEFT_X)
	if abs(input_direction) > 0.3:
		if  input_direction < 0:
			turn_direction = -1
			last_turn_direction = -1
			tires_anim.play("left")
		elif input_direction > 0:
			turn_direction = 1
			last_turn_direction = 1
			tires_anim.play("right")
	else:
		turn_direction = 0
		tires_anim.play("straight")

func update_front_direction():
	direction = $FrontDirection.global_position - global_position

func _input(event):
	if event.device == device:
		if event.is_action_pressed("R1"):
			input_accelerating = true
		elif event.is_action_released("R1"):
			input_accelerating = false
		
		elif event.is_action_pressed("L1"):
			input_reverse = true
		elif event.is_action_released("L1"):
			input_reverse = false

func _on_bomb_flash_timer_timeout():
	if bomb_carry:
		if bomb_modulate_toggle:
			bomb_sprite.modulate = Color(0.89, 0, 0.43, 1)
			bomb_modulate_toggle = false
			return
		if !bomb_modulate_toggle:
			bomb_sprite.modulate = Color(1, 1, 1, 1)
			bomb_modulate_toggle = true
			return

func _on_slow_timer_timeout():
	var tween = create_tween()
	tween.tween_property(self, "slow_multiplier", 1.0, 1.0)
