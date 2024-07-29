extends "res://FSM.gd"


func _ready():
	add_state("idle")
	add_state("run")
	add_state("jump")
	add_state("fall")
	add_state("wall_slide")
	call_deferred("_set_state", states.idle)

func _input(event):
	if parent.device_id == event.device:
		if event.is_action_pressed("L1"):
			if [states.idle, states.run].has(state) or !parent.coyote_timer.is_stopped():
				parent.coyote_timer.stop()
				parent.jump()
			else:
				parent.jump_buffer_timer.start()
		
		if state == states.wall_slide:
			if event.is_action_pressed("L1"):
				parent.wall_jump()
				_set_state(states.jump)
		
		if state == states.jump:
			if event.is_action_released("L1") and parent.velocity.y < parent.min_jump_velocity:
				parent.velocity.y = parent.min_jump_velocity

func _state_logic(delta):
	parent.handle_move_input()
	#parent.update_move_direction()
	parent.update_wall_direction()
	if state != states.wall_slide:
		parent.handle_movement()
	parent.apply_gravity(delta)
	if state == states.wall_slide:
		parent.cap_gravity_wall_slide()
		parent.handle_wall_slide_sticking()
	parent.apply_movement(delta)

func _get_transition(delta):
	match state:
		states.idle:
			if !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			elif parent.velocity.x != 0:
				return states.run
		states.run:
			if !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			elif parent.velocity.x == 0:
				return states.idle
		states.jump:
			if parent.wall_direction != 0 and parent.wall_slide_cooldown.is_stopped():
				return states.wall_slide
			elif parent.is_on_floor():
				return states.idle
			elif parent.velocity.y >= 0:
				return states.fall
		states.fall:
			if parent.wall_direction != 0 and parent.wall_slide_cooldown.is_stopped():
				return states.wall_slide
			elif parent.is_on_floor():
				return states.idle
			elif parent.velocity.y < 0:
				return states.jump
		states.wall_slide:
			if parent.is_on_floor():
				return states.idle
			elif parent.wall_direction == 0:
				return states.fall
	
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.fall:
			parent.anim.play("jump")
			if old_state != states.jump:
				parent.coyote_timer.start()
		states.run:
			if old_state == states.fall:
				parent.sound_2_player.set_stream(parent.land_sound)
				parent.sound_2_player.volume_db = -14
				parent.sound_2_player.play()
			parent.anim.play("run")
			parent.step_sound_timer.start()
		states.idle:
			parent.anim.play("idle")
			if old_state == states.fall:
				parent.sound_2_player.set_stream(parent.land_sound)
				parent.sound_2_player.volume_db = -14
				parent.sound_2_player.play()
		states.jump:
			parent.anim.play("jump")

func _exit_state(old_state, new_state):
	match old_state:
		states.wall_slide:
			parent.wall_slide_cooldown.start()
		states.jump:
			parent.wall_jump_speed = 0
		states.run:
			parent.step_sound_timer.stop()


func _on_wall_slide_sticky_timer_timeout():
	if state == states.wall_slide:
		_set_state(states.fall)
