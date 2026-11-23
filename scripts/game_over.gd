extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$score.text = "score: " + str(int(Globals.score))


func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
	Globals.score = 0
	Globals.score_damage = 0
	Globals.levels = 0
