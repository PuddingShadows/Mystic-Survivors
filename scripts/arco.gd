extends Node2D

var flecha_scene = preload("res://scenes/flecha.tscn")
var angle := 0.0
var direction : Vector2 = Vector2.ZERO
var target = null

@export_category("attributes")
@export var radius := 50.0
@export var speed := 2.0
@export var cooldown := 1.0
@export var time := 1.0

func _process(delta):
	angle += speed * delta
	rotation += speed * delta
	
	var offset = Vector2(
		cos(angle),
		sin(angle)
		) * radius
	
	position = offset
	
	if cooldown < time:
		cooldown += delta
	
	if target and cooldown >= time:
		shoot(target)
	
	
	if cooldown < time - 0.25:
		$bow.frame = 1
	else:
		$bow.frame = 0
	


func shoot(target):
		direction = global_position.direction_to(target.global_position)
		var flecha = flecha_scene.instantiate()
		get_tree().current_scene.add_child(flecha)
		
		flecha.rotation = direction.angle()
		flecha.global_position = global_position
		flecha.velocity = direction * flecha.speed
		cooldown = 0.0


func _on_area_attack_body_entered(body) -> void:
	if body.is_in_group("inimigo"):
		target = body

func _on_area_attack_body_exited(body) -> void:
	if body == target:
		target = null
