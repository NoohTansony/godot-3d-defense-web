extends Area3D

@export var speed := 18.0
@export var damage := 10

var target: Node3D

func _process(delta: float) -> void:
	if not is_instance_valid(target):
		queue_free()
		return
	var to_target = target.global_position - global_position
	if to_target.length() < 0.7:
		if target.has_method("take_damage"):
			target.take_damage(damage)
		queue_free()
		return
	global_position += to_target.normalized() * speed * delta
