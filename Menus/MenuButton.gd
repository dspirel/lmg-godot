extends AnimatedSprite2D

@export var button_text :String
@export var type :String
@onready var label :Label = $Label

func _ready():
	set_text(button_text)

func set_text(text :String):
	label.text = text.to_upper()
