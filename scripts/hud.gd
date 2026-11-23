extends CanvasLayer

@export var timer : Timer = null
@export var time_label : Label = null

@export var score_label : Label = null

@export var level_label : Label = null

var time_survived = 0
var time_spawn_slime = 0
var time_spawn_slime_elite = 0
var time_difficult = 0
var difficult = 0
var difficult_eleapese = 25

func _process(_delta: float) -> void:
	var minutes = time_survived / 60
	var seconds = time_survived % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]
	
	score_label.text = str(Globals.score)
	level_label.text = str(Globals.levels)


func _on_timer_timeout() -> void:
	time_survived += 1
	time_spawn_slime += 1
	time_spawn_slime_elite += 1
	time_difficult += 1
	timer.start()
	
	if time_difficult >= difficult_eleapese:
		difficult += 1
		time_difficult = 0
	
	if time_survived >= 60:
		difficult_eleapese = 15
