extends Area2D

@export var regen_number_scene : PackedScene

var player_ref = null
var regen = 30.0


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		$anim.play("open")
		player_ref = body


func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "open":
		Globals.score += 1000
		Globals.score_damage += 10
		var regen_real = max(0, min(regen, player_ref.life_max - player_ref.life))
		player_ref.life += regen_real
		
		if regen_real != 0:
			var rgn = regen_number_scene.instantiate()
			get_tree().current_scene.add_child(rgn)
			
			rgn.global_position = global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
			rgn.setup(regen_real)
		
		player_ref.level_up()
		await get_tree().create_timer(0.3).timeout 
		queue_free()
