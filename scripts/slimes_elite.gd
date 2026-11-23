extends CharacterBody2D
class_name slime_elite

var chest_scene = preload("res://scenes/chest.tscn")

var direction : Vector2 = Vector2.ZERO
var move = true
var is_dead = false
var can_spawn_func
var taking_damage = false
var damage_color = Color(20, 20, 20)
var normal_color = Color(1, 1, 1)

@export var player_ref : CharacterBody2D = null
@export var damage_number_scene : PackedScene

@export_category("attributes")
@export var speed : float = 150.0
@export var life : float = 100.0
@export var life_max : float = 300.0

@export_category("objects")
@export var texture : Sprite2D = null
@export var anim : AnimationPlayer = null

@export_category("attack")
@export var damage : float = 50.0
@export var time : float = 1.0
@export var cooldown : float = 0.0


func _ready() -> void:
	player_ref = $"../player"

func _process(delta: float) -> void:
	if cooldown < time:
		cooldown += delta
	
	var target_color = damage_color if taking_damage else normal_color
	$texture.modulate = $texture.modulate.lerp(target_color, 10 * delta)
	
	taking_damage = false
	
	check_distance()

func _physics_process(_delta: float) -> void:
	if move and player_ref != null:
		direction = global_position.direction_to(player_ref.global_position)
		var distance : float = global_position.distance_to(player_ref.global_position)
		if distance > 10:
			velocity = direction * speed
		elif distance < 10:
			player_ref.velocity = direction * speed
		else:
			velocity = Vector2.ZERO
		
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			if collider is CharacterBody2D:
				var push = global_position.direction_to(collider.global_position)
				velocity -= push * 25
		
	_animated()
	move_and_slide()


func _animated() -> void:
	if is_dead:
		return
	
	if direction.x > 0.2:
		texture.flip_h = false
	if direction.x < -0.2:
		texture.flip_h = true
	
	if life <= 0 and !is_dead:
		anim.play("death")
		velocity = Vector2.ZERO
		$death_sfx.play()
		move = false
		is_dead = true
		return
	
	if velocity != Vector2.ZERO:
		anim.play("walk")
		return
	
	anim.play("idle")


func levar_dano(damage, is_crit: bool):
	if life > 0:
		life -= damage
		
		var dmg = damage_number_scene.instantiate()
		get_tree().current_scene.add_child(dmg)
		
		dmg.global_position = global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
		dmg.setup(damage, is_crit)
		
		taking_damage = true
	


func check_distance():
	var max_distance = 200  # distância pra resetar
	var dist = global_position.distance_to(player_ref.global_position)
	
	if dist > max_distance:
		teleport_near_player()

func teleport_near_player():
	var distance = 200.0
	
	for i in range(10):
		var dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		var pos = player_ref.global_position + dir * distance
			
		if can_spawn_func != null and can_spawn_func.call(pos):
			global_position = pos
			return


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		pass

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		pass


func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		queue_free()
		
		var chest = chest_scene.instantiate()
		get_tree().current_scene.add_child(chest)
		chest.global_position = global_position
