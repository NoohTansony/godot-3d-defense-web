extends Node3D

@export var fire_rate := 0.35
@export var range := 14.0
@export var bullet_scene: PackedScene

var base_node: Node3D
var target_group := "enemy"
var cooldown := 0.0

var level := 1
var bullet_damage := 10

func _process(delta: float) -> void:
	cooldown -= delta
	var target = _find_target()
	if target:
		look_at(target.global_position, Vector3.UP)
		if cooldown <= 0.0:
			_fire(target)
			cooldown = fire_rate

func _find_target() -> Node3D:
	var best: Node3D = null
	var best_d = range
	for n in get_tree().get_nodes_in_group(target_group):
		if not n is Node3D:
			continue
		var d = global_position.distance_to(n.global_position)
		if d < best_d:
			best_d = d
			best = n
	return best

func _fire(target: Node3D) -> void:
	if bullet_scene == null:
		return
	var b = bullet_scene.instantiate()
	b.global_position = global_position + Vector3(0, 0.5, 0)
	b.target = target
	b.set("damage", bullet_damage)
	get_tree().current_scene.add_child(b)

func upgrade() -> void:
	level += 1
	bullet_damage += 7
	range += 0.9
	fire_rate = max(0.14, fire_rate * 0.92)
	scale = Vector3.ONE * (1.0 + level * 0.08)
