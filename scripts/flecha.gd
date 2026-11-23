extends Area2D

@export var player_ref : CharacterBody2D = null

@export_category("attributes")
@export var speed := 140.0


var velocity : Vector2 = Vector2.ZERO


func _ready() -> void:
	player_ref = $"../Ysort/player/"

func _process(delta: float) -> void:
	position += velocity * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("inimigo"):
		var chance = randf_range(0, 100)
		var is_crit = chance < 10
		
		var normal_damage = player_ref.get_damage()
		var critic_damage = normal_damage * 2
		
		var final_damage = critic_damage if is_crit else normal_damage
		
		body.levar_dano(final_damage, is_crit)
		
		if body.life > 0:
			$damage_sfx.play()
		await get_tree().create_timer(0.1).timeout
		queue_free()
