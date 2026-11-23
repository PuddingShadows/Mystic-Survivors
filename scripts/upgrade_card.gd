extends Panel

signal selected

var upgrade_data

@onready var outline = $hover_outline


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered():
	outline.modulate.a = 1.0

func _on_mouse_exited():
	outline.modulate.a = 0.0


func setup(data, level):
	upgrade_data = data
	
	$level.text = "Level " + str(level)
	$nome.text = data.name
	
	var base_bonus = data.value
	var current_bonus = base_bonus * level
	var next_bonus = base_bonus * (level + 1)
	
	
	$VBoxContainer/porcent_up.text = str(int(next_bonus * 100)) + "%"
	
	$VBoxContainer/porcent.text = str(int(current_bonus * 100)) + "% --"
	
	$image.texture = data.icon

func _gui_input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			_on_mouse_entered()
		else:
			_on_mouse_exited()
			emit_signal("selected")
