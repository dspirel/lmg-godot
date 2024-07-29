extends GPUParticles2D

func _ready():
	pass

func _physics_process(delta):
	if emitting == false:
		queue_free()
