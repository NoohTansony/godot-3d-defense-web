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
var gold := 140
var game_over := false

var turret_cost := 70
var turret_upgrade_cost := 85
var skill_cd := 0.0
var skill_cd_max := 14.0

var build_slots: Array[Vector3] = [
	Vector3(0, 0.6, 0),
	Vector3(4.5, 0.6, 0),
	Vector3(-4.5, 0.6, 0),
	Vector3(0, 0.6, 4.5),
	Vector3(0, 0.6, -4.5),
	Vector3(3.2, 0.6, 3.2),
]
var placed_turrets: Array = []

func _ready() -> void:
	randomize()
	spawn_timer.wait_time = spawn_interval
	wave_timer.wait_time = wave_gap
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	wave_timer.timeout.connect(_on_wave_timer_timeout)
	base.tree_exiting.connect(_on_base_destroyed)

	placed_turrets.resize(build_slots.size())
	_build_turret_at_slot(0)

	_update_ui("Wave 1 시작")
	spawn_timer.start()

func _input(event: InputEvent) -> void:
	if game_over:
		if event.is_action_pressed("ui_accept"):
			get_tree().reload_current_scene()
		return

	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1: _build_turret_at_slot(0)
			KEY_2: _build_turret_at_slot(1)
			KEY_3: _build_turret_at_slot(2)
			KEY_4: _build_turret_at_slot(3)
			KEY_5: _build_turret_at_slot(4)
			KEY_6: _build_turret_at_slot(5)
			KEY_Q: _upgrade_turret_at_slot(0)
			KEY_W: _upgrade_turret_at_slot(1)
			KEY_E: _upgrade_turret_at_slot(2)
			KEY_R: _upgrade_turret_at_slot(3)
			KEY_T: _upgrade_turret_at_slot(4)
			KEY_Y: _upgrade_turret_at_slot(5)
			KEY_SPACE: _cast_nova_skill()

func _build_turret_at_slot(idx: int) -> void:
	if idx < 0 or idx >= build_slots.size():
		return
	if placed_turrets[idx] != null and is_instance_valid(placed_turrets[idx]):
		return
	if gold < turret_cost:
		return
	gold -= turret_cost
	var t = turret_scene.instantiate()
	t.global_position = build_slots[idx]
	t.base_node = base
	t.target_group = "enemy"
	turrets.add_child(t)
	placed_turrets[idx] = t

func _upgrade_turret_at_slot(idx: int) -> void:
	if idx < 0 or idx >= placed_turrets.size():
		return
	var t = placed_turrets[idx]
	if t == null or not is_instance_valid(t):
		return
	if gold < turret_upgrade_cost:
		return
	gold -= turret_upgrade_cost
	t.upgrade()

func _cast_nova_skill() -> void:
	if skill_cd > 0.0:
		return
	skill_cd = skill_cd_max
	for e in get_tree().get_nodes_in_group("enemy"):
		if e.has_method("take_damage"):
			e.take_damage(22)

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
	spawn_interval = max(0.45, spawn_interval * 0.95)
	spawn_timer.wait_time = spawn_interval
	gold += 30 + wave * 4
	score += 15
	_update_ui("Wave %d 시작" % wave)
	spawn_timer.start()

func _spawn_enemy() -> void:
	var e = enemy_scene.instantiate()
	var angle = randf() * TAU
	var radius = randf_range(16.0, 23.0)
	e.global_position = Vector3(cos(angle) * radius, 0.5, sin(angle) * radius)
	e.base_node = base
	e.died.connect(_on_enemy_died)
	if e.has_method("setup_variant"):
		var r = randf()
		var kind = 0
		if r < 0.18 + min(0.22, wave * 0.01):
			kind = 2
		elif r < 0.48:
			kind = 1
		e.setup_variant(kind, wave)
	enemies.add_child(e)

func _on_enemy_died(points: int) -> void:
	score += points
	gold += int(points * 0.8)

func _on_base_destroyed() -> void:
	game_over = true
	spawn_timer.stop()
	wave_timer.stop()
	ui_label.text = "GAME OVER\n점수: %d | Wave: %d\nEnter로 재시작" % [score, wave]

func _process(delta: float) -> void:
	if game_over:
		return
	skill_cd = max(0.0, skill_cd - delta)
	if not is_instance_valid(base):
		return
	var hp_text = "Base HP: %d" % int(base.hp)
	var cd_text = "Nova: READY" if skill_cd <= 0.0 else "Nova: %.1fs" % skill_cd
	ui_label.text = "Wave %d | Score %d | Gold %d\n%s | %s\nBuild 1-6 (%dG) / Upgrade QWERTY (%dG) / Space Nova" % [wave, score, gold, hp_text, cd_text, turret_cost, turret_upgrade_cost]

func _update_ui(prefix := "") -> void:
	if prefix != "":
		ui_label.text = prefix
