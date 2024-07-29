extends Area2D

var target
var speed = 44
var follow_distance

func _physics_process(delta):
	look_at(target.global_position)

	if position.distance_to(target.position) > follow_distance:
		position += position.direction_to(target.position) * speed * delta

func setup_collision_layers(slot, coll_disable):
	var layers = [1,2,3,4]
	
	set_collision_layer_value(1,false)
	set_collision_mask_value(1,false)
	
	set_collision_layer_value(slot+1,true)
	if coll_disable:
		set_collision_mask_value(slot+1, true)

	for l in layers:
		if l != slot+1:
			set_collision_mask_value(l,true)

func set_color(color_name):
	$Sprite.play(color_name)

func _on_body_entered(body):
	body.stun()

