extends Node2D

@export var player_ref : CharacterBody2D = null
@export var hud : CanvasLayer = null
@export var distance : float = 300.0
@export var time := 3.0
@export var time_elite := 60.0

@export var tilemap_path : NodePath
@export var mask_path : NodePath
@export var fences_path : NodePath

@export var source_id : int = 0
@export var grid_size : int = 16
@export var spawn_chance : float = 0.5


@onready var tilemap = get_node(tilemap_path)
@onready var mask = get_node(mask_path)
@onready var fences = get_node(fences_path)


var slime_scene = preload("res://scenes/slimes.tscn")
var slime_elite_scene = preload("res://scenes/slime_elite.tscn")
var noise = FastNoiseLite.new()

var upgrades = [
	{
	"id": "damage",
	"name": "Damage",
	"value": 0.1,
	"icon": preload("res://assets/icons_upgrade/icon_attack.png"),
	"apply": func(p): p.bonus_damage_percent += 0.1
	},
	
	
	{
	"id": "speed",
	"name": "Speed",
	"value": 0.02,
	"icon": preload("res://assets/icons_upgrade/icon_speed.png"),
	"apply": func(p): p.speed_bonus_percent += 0.02
	},
	
	
	{
	"id": "life",
	"name": "Max Life",
	"value": 0.15,
	"icon": preload("res://assets/icons_upgrade/icon_life.png"),
	"apply": func(p): p.life_bonus_percent += 0.15
	}
]

var upgrade_levels = {
	"damage": 0,
	"speed": 0,
	"life": 0,
}



func _ready():
	noise.frequency = 0.01
	spawn_world()

func _process(_delta: float) -> void:
	spawn_slime()
	spawn_slime_elite()


func can_spawn_at_position(world_pos: Vector2) -> bool:
	var cell = tilemap.local_to_map(tilemap.to_local(world_pos))
	
	if tilemap.get_cell_source_id(cell) != -1:
		return false
		
	var fences_cell = fences.local_to_map(fences.to_local(world_pos))
	
	if fences.get_cell_source_id(fences_cell) != -1:
		return false
		
	return true

func spawn_slime():
	var spawn_time = max(0.5, time - hud.difficult * 0.3)
	
	if hud.time_spawn_slime >= spawn_time:
		for i in range(10):
			var direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
			var spawn_pos = player_ref.global_position + direction * distance
			if can_spawn_at_position(spawn_pos):
				var _slime = slime_scene.instantiate()
				_slime.position = spawn_pos
				_slime.player_ref = player_ref
				_slime.can_spawn_func = can_spawn_at_position
				
				$Ysort.add_child(_slime)
				hud.time_spawn_slime = 0
				return

func spawn_slime_elite():
	var spawn_time = max(0.5, time_elite - hud.difficult * 0.3)
	
	if hud.time_spawn_slime_elite >= spawn_time:
		for i in range(10):
			var direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
			var spawn_pos = player_ref.global_position + direction * distance
			if can_spawn_at_position(spawn_pos):
				var _slime = slime_elite_scene.instantiate()
				_slime.position = spawn_pos
				_slime.player_ref = player_ref
				_slime.can_spawn_func = can_spawn_at_position
				
				$Ysort.add_child(_slime)
				hud.time_spawn_slime_elite = 0
				return



var tiles = [
	Vector2i(0, 3), #arvore 1
	Vector2i(4, 2), #arvore 2
	Vector2i(8, 6), #toco de arvore
	Vector2i(0, 8), #arbusto 1
	Vector2i(4, 9), #arbusto 2
	Vector2i(10, 0), #caveira de animal
	Vector2i(12, 0), #caveira
	Vector2i(14, 0), #ossos
	]


func spawn_world():
	for x in range(-100, 96):
		for y in range(-55, 71):
			var cell = Vector2i(x, y)
			
			if can_spawn_cell(cell) and should_spawn(x, y):
				place_tile_cell(cell)

func can_spawn_cell(cell: Vector2i) -> bool:
	var radius = 2
		
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			if Vector2(x, y).length() > radius:
				continue
			
			var check_cell = cell + Vector2i(x, y)
			
			if mask.get_cell_source_id(check_cell) != -1:
				return false
				
	return true

func has_nearby_object(cell: Vector2i) -> bool:
	var radius = 4
	
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			if Vector2(x, y).length() > radius:
				continue
			
			var check_cell = cell + Vector2i(x, y)
			
			if tilemap.get_cell_source_id(check_cell) != -1:
				return true
			
	return false


func should_spawn(x, y) -> bool:
	return randf() < spawn_chance

func place_tile_cell(cell: Vector2i):
	if tilemap.get_cell_source_id(cell) != -1:
		return
	
	if has_nearby_object(cell):
		return
	
	var atlas = get_random_tile()
	tilemap.set_cell(cell, source_id, atlas)

func get_random_tile() -> Vector2i:
	return tiles.pick_random()


func get_random_upgrades():
	var pool = upgrades.duplicate()
	pool.shuffle()
	return pool.slice(0, 3)


func game_over():
	var game_over_scene = preload("res://scenes/game_over.tscn")
	var game_over = game_over_scene.instantiate()
	$hud.add_child(game_over)
