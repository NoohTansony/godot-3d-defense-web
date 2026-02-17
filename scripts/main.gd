extends Node3D

@export var enemy_scene: PackedScene
@export var turret_scene: PackedScene
@export var spawn_interval := 1.6
@export var enemies_per_wave := 8
@export var wave_gap := 4.0

@onready var base: Node3D = $Base
@onready var enemies: Node3D = $Enemies
@onready var turrets: Node3D = $Turrets
@onready var ui_label: Label = $CanvasLayer/InfoLabel
@onready var spawn_timer: Timer = $SpawnTimer
@onready var wave_timer: Timer = $WaveTimer

var wave := 1
var spawned_in_wave := 0
var score := 0
var game_over := false

func _ready() -> void:
	spawn_timer.wait_time = spawn_interval
	wave_timer.wait_time = wave_gap
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	wave_timer.timeout.connect(_on_wave_timer_timeout)
	base.tree_exiting.connect(_on_base_destroyed)
	_spawn_turret(Vector3(0, 0.6, 0))
	_update_ui("Wave 1 시작")
	spawn_timer.start()

func _spawn_turret(pos: Vector3) -> void:
	var t = turret_scene.instantiate()
	t.global_position = pos
	t.base_node = base
	t.target_group = "enemy"
	turrets.add_child(t)

func _on_spawn_timer_timeout() -> void:
	if game_over:
		return
	if spawned_in_wave >= enemies_per_wave:
		spawn_timer.stop()
		wave_timer.start()
		return
	spawned_in_wave += 1
	_spawn_enemy()

func _on_wave_timer_timeout() -> void:
	if game_over:
		return
	wave += 1
	spawned_in_wave = 0
	enemies_per_wave += 2
	spawn_interval = max(0.55, spawn_interval * 0.94)
	spawn_timer.wait_time = spawn_interval
	_update_ui("Wave %d 시작" % wave)
	spawn_timer.start()

func _spawn_enemy() -> void:
	var e = enemy_scene.instantiate()
	var angle = randf() * TAU
	var radius = randf_range(16.0, 23.0)
	e.global_position = Vector3(cos(angle) * radius, 0.5, sin(angle) * radius)
	e.base_node = base
	e.died.connect(_on_enemy_died)
	enemies.add_child(e)

func _on_enemy_died(points: int) -> void:
	score += points
	_update_ui()

func _on_base_destroyed() -> void:
	game_over = true
	spawn_timer.stop()
	wave_timer.stop()
	ui_label.text = "GAME OVER\n점수: %d\nWave: %d\n(실행 재시작해서 다시 플레이)" % [score, wave]

func _process(_delta: float) -> void:
	if game_over:
		return
	if not is_instance_valid(base):
		return
	var hp_text = "Base HP: %d" % int(base.hp)
	ui_label.text = "Wave %d | Score %d\n%s" % [wave, score, hp_text]

func _update_ui(prefix := "") -> void:
	if prefix != "":
		ui_label.text = prefix
