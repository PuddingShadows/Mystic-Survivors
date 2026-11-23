extends Node2D

@onready var label = $Label

var velocity := Vector2(0, -80)
var lifetime := 1.0

func setup(value: float, is_crit: bool):
	label.text = str(int(value))
	
	if is_crit:
		label.modulate = Color(1, 0.9, 0.2)
		scale = Vector2(1.5, 1.5)
	else:
		label.modulate = Color(1, 1, 1)
		scale = Vector2(1.2, 1.2)


func _ready() -> void:
	pass

func _process(delta):
	position += velocity * delta
	velocity *= 0.9
	
	lifetime -= delta
	modulate.a = lifetime + 0.1
	
	if scale > Vector2.ZERO:
		scale -= Vector2(0.01, 0.01)
	
	if lifetime <= 0:
		queue_free()
