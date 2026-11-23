extends CharacterBody2D
class_name player

var state_machine
var is_dead = false
var ver = false
var player_leaning = 0
var taking_damage = false
var damage_color = Color(1.3, 0.15, 0.15)
var normal_color = Color(1, 1, 1)

@export var reload : Timer = null
@export var inimigo_ref : CharacterBody2D = null

@export_category("attributes")
@export var life_max : float = 100.0
@export var life : float = 100.0
@export var life_bonus_percent : float = 0.0
@export var regen : float = 0.5
@export var speed : float = 300.0
@export var speed_max : float  = 300.0
@export var speed_bonus_percent : float = 0.0
@export var learning : float = 150.0
@export var friction : float = 0.8
@export var acceleration : float = 0.4
@export var damage : float = 35.0
@export var base_damage : float = 35.0
@export var bonus_damage_percent : float = 0.0

@export_category("Objects")
@export var animation_tree : AnimationTree = null


func _ready() -> void:
	state_machine = animation_tree["parameters/playback"]

func _process(delta: float) -> void:
	life = min(life + regen * delta, get_life_max())
	
	if player_leaning > 0:
		speed = learning
	else:
		speed = speed_max * (1 + speed_bonus_percent)
	
	var target_color = damage_color if taking_damage else normal_color
	$texture.modulate = $texture.modulate.lerp(target_color, 10 * delta)
	
	taking_damage = false
	
	if life <= 0:
		is_dead = true
		$arco.target = null
		_reload()
	levar_dano()

func _physics_process(_delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right",  "ui_up", "ui_down")
	
	if !is_dead:
		if direction != Vector2.ZERO:
			animation_tree["parameters/idle/blend_position"] = direction
			animation_tree["parameters/walk/blend_position"] = direction
			velocity.x = lerp(velocity.x, direction.x * speed, acceleration)
			velocity.y = lerp(velocity.y, direction.y * speed, acceleration)
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, friction)
			velocity.y = lerp(velocity.y, direction.y * speed, friction)
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
	_animate()


func _animate() -> void:
	if is_dead:
		state_machine.travel("death")
		return
	
	if velocity.length() > 1:
		state_machine.travel("walk")
		return
	
	state_machine.travel("idle")


func levar_dano():
	if inimigo_ref != null:
		if inimigo_ref.cooldown >= inimigo_ref.time and life > 0:
			life -= inimigo_ref.damage
			inimigo_ref.cooldown = 0.0
			
			taking_damage = true
			#print("tomou dano")

func _reload():
	if !ver:
		$"../..".game_over()
		$death_sfx.play()
		ver = true


func level_up():
	while Globals.score_damage >= 5:
		Globals.score_damage -= 5
		Globals.levels += 1
		
		var choices = $"../..".get_random_upgrades()
		var ui = $"../../hud/upgrade_ui"
		ui.show_choices(choices, self)
		
		$level_up_sfx.play()
		await ui.selected

func get_damage():
	return base_damage * (1 + 0.05 * Globals.levels) * (1 + bonus_damage_percent)

func get_life_max():
	return life_max * (1 + life_bonus_percent)


func _on_hitbox_body_entered(body) -> void:
	if body.is_in_group("inimigo"):
		inimigo_ref = body
		player_leaning += 1

func _on_hitbox_body_exited(body) -> void:
	if body.is_in_group("inimigo"):
		inimigo_ref = null
		player_leaning -= 1


func _on_area_collect_area_entered(area) -> void:
	if area.is_in_group("Gem"):
		area.iniciar_coleta(self)
