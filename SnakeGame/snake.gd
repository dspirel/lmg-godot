extends CharacterBody2D

var snake_joint = preload("res://SnakeGame/snake_joint.tscn")
var tpb = preload("res://SnakeGame/texture_progress_bar.tscn")

@onready var look_direction = get_parent().get_node("LookDirection")
@onready var joint_nodes = get_parent().get_node("Joints")
@onready var flash_stun_timer = get_parent().get_node("FlashStunTimer")
@onready var head_sprite = $Sprite2D
@onready var slither_sound = get_parent().get_node("SnakeSlitherSound")

#COLLISION LAYER == SLOT+1

var device_id:int
var direction:Vector2
var stunned_time:float = 0
var slot:int
var player :Player = null
var head_color

var speed = 0
var max_speed = 60
var acceleration = 25
var max_boost_speed = 25
var current_boost_speed = 0

var boost_toggle = false
var max_boost_energy = 75
var current_boost_energy = 0
var main_joints_tpbs = []
var main_joint_tpb

var deferred = false

func _ready():
	call_deferred("setup_collision_layers")
	for i in 3:
		call_deferred("add_snake_joint")
	await get_tree().process_frame
	deferred = true
	
	head_color = Color(1,1,1,1)


func _physics_process(delta):
	if deferred:
		if stunned_time < 0 and direction.length() > 0.3:
			if !slither_sound.is_playing():
				slither_sound.play()
			update_steer_position()
			if speed < max_speed:
				speed += acceleration * delta
			look_at(look_direction.global_position)
			var collision = move_and_collide(direction.normalized() * (speed + current_boost_speed) * delta)
		elif speed > 0:
			speed -= acceleration * 4 * delta
		if speed < 4:
			slither_sound.stop()
		
		if boost_toggle and current_boost_energy > 1 and stunned_time < -4 and speed > 10:
			current_boost_speed = max_boost_speed
			current_boost_energy -= delta * 20
			if current_boost_energy < 5:
				boost_toggle = false
				current_boost_speed = 0
		elif current_boost_energy < max_boost_energy:
			current_boost_energy += delta * 8

		if stunned_time > 0.1 and flash_stun_timer.is_stopped():
			speed = 0
			head_sprite.self_modulate = Color8(255,255,255,255)
			flash_stun_timer.start(0.5)
		elif !flash_stun_timer.is_stopped() and stunned_time < 0:
			flash_stun_timer.stop()
			head_sprite.self_modulate = head_color

		stunned_time -= delta
		update_main_joints_tpb_values()

func eat_apple(growth):
	get_parent().get_node("AppleBiteSound").play()
	for i in growth:
		call_deferred("add_snake_joint")

func add_boost_energy(amount):
	current_boost_energy += amount
	if current_boost_energy > max_boost_energy:
		current_boost_energy = max_boost_energy

func update_main_joints_tpb_values():
	if current_boost_energy < 25:
		main_joints_tpbs[0].value = current_boost_energy
	elif current_boost_energy > 25 and current_boost_energy < 50:
		main_joints_tpbs[1].value = current_boost_energy - 25
	elif current_boost_energy > 50 and current_boost_energy < 75:
		main_joints_tpbs[2].value = current_boost_energy - 50

	if current_boost_energy < 50:
		main_joints_tpbs[2].value = 0
	if current_boost_energy < 25:
		main_joints_tpbs[1].value = 0

func add_snake_joint():
	var joints = joint_nodes.get_children()
	var joint = snake_joint.instantiate()
	
	if joints.size() < 3:
		if !joints.size():
			joint.speed = max_speed + max_boost_speed
			joint.target = self
			joint.position = position
			joint.follow_distance = 5
			
			var new_tpb = tpb.instantiate()
			joint.add_child(new_tpb)
			main_joints_tpbs.append(new_tpb)
		else:
			var new_tpb = tpb.instantiate()
			joint.add_child(new_tpb)
			main_joints_tpbs.append(new_tpb)
			
			joint.speed = max_speed + max_boost_speed
			joint.target = joints.back()
			joint.position = joints.back().position
			joint.follow_distance = 5
	else:
		joint.speed = max_speed + max_boost_speed
		joint.target = joints.back()
		joint.position = joints.back().position
		joint.follow_distance = 5

	joint.set_color(player.color)
	joint_nodes.add_child(joint)

	if joints.size() < 2:
		joint.setup_collision_layers(slot, false)
	else:
		joint.setup_collision_layers(slot, true)

func setup_main_joint_tpb():
	main_joint_tpb.max_value = 75
	main_joint_tpb.min_value = 0
#		print("max: " + str(joint_tpb.max_value) + "min: " + str(joint_tpb.min_value) + "/n")

func stun():
	if stunned_time < -2:
		get_parent().get_node("SnakeHurtSound").play()
		stunned_time = 3
		current_boost_energy -= 25
		if current_boost_energy < 0:
			current_boost_energy = 0

func setup_collision_layers():
	var layers = [1,2,3,4]
	
	set_collision_layer_value(1,false) #reset
	set_collision_mask_value(1,false)
	
	set_collision_layer_value(5,true) #apples
	
	set_collision_layer_value(slot+1,true) #own layer
	for l in layers:
		if l != slot+1:
			set_collision_mask_value(l,true)#other players

func update_steer_position():
	look_direction.position = (direction * 15) + position

func _input(event):
	if event.device == device_id:
		#ADD DEADZONE TODO
		direction.x = Input.get_joy_axis(device_id,JOY_AXIS_RIGHT_X)
		direction.y = Input.get_joy_axis(device_id,JOY_AXIS_RIGHT_Y)

		if event.is_action_pressed("L1"):
			boost_toggle = true
		if event.is_action_released("L1"):
			boost_toggle = false
			current_boost_speed = 0

func _on_flash_stun_timer_timeout():
	if head_sprite.self_modulate == head_color:
		head_sprite.self_modulate = Color(0.7,0.7,0.7,1)
	else:
		head_sprite.self_modulate = head_color

#		look_direction.position = lerp(look_direction.position.normalized()*148, motion.normalized() * 150, 0.03)

