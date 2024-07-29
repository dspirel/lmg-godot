extends Sprite2D

func _on_item_rect_changed():
	material.set_shader_parameter("aspect_ratio", scale.y / scale.x)
	print(material.get_shader_parameter("aspect_ratio"))
