extends Node3D

@export var fire_rate := 0.35
@export var range := 14.0
@export var bullet_scene: PackedScene

var base_node: Node3D
var target_group := "enemy"
var cooldown := 0.0

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
	get_tree().current_scene.add_child(b)
