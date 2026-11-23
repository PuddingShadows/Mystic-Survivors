extends Control

signal selected

@export var card_scene : PackedScene
@onready var container = $CenterContainer/HBoxContainer

var current_choices = []
var player_ref


func show_choices(choices, Player):
	visible = false
	await get_tree().process_frame
	visible = true
	get_tree().paused = true
	current_choices = choices
	player_ref = Player
	
	for child in container.get_children():
		child.queue_free()
	
	for i in range(3):
		var card = card_scene.instantiate()
		container.add_child(card)
		
		var level = $"../..".upgrade_levels[choices[i].id]
		card.setup(choices[i], level)
		card.selected.connect(_on_choice_selected.bind(i), CONNECT_ONE_SHOT)
		
		
func _on_choice_selected(index):
	var upgrade = current_choices[index]
	upgrade.apply.call(player_ref)
	
	$"../..".upgrade_levels[upgrade.id] += 1
	
	visible = false
	get_tree().paused = false
	
	emit_signal("selected")
