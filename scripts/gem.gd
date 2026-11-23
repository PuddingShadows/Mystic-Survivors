extends Area2D
class_name gem

var speed = 0.0
var velocity = Vector2.ZERO
var target = null
var repel_force = 200.0
var attract_speed = 150.0
var state = "idle"
var collected = false



func _process(delta):
	if state == "repel":
		velocity = velocity.lerp(Vector2.ZERO, 6 * delta)
		global_position += velocity * delta
		
	elif state == "attract" and target:
		var dir = (target.global_position - global_position).normalized()
		
		#speed += 300.0 * delta
		speed = lerp(speed, attract_speed, 6 * delta)
		
		velocity = dir * speed
		global_position += velocity * delta
		
		
		if global_position.distance_to(target.global_position) < 10:
			coletar()


func coletar():
	if collected:
		return
	
	Globals.score += 50
	Globals.score_damage += 1
	$"../Ysort/player".level_up()
	
	$collect_sfx.play()
	visible = false
	collected = true
	
	await get_tree().create_timer(0.2).timeout
	queue_free()


func iniciar_coleta(Player):
	if state != "idle":
		return
	target = Player
	
	#$collision.disabled = true
	
	var dir = (global_position - Player.global_position).normalized()
	speed = repel_force
	velocity = dir * speed
		
	state = "repel"
		
	await get_tree().create_timer(0.15).timeout
	state = "attract"
	speed = 0.0
