extends Node2D

@onready var start_position = $StartPosition.global_position

func _on_spike_area_body_entered(body):
	body.return_to_start(start_position)
