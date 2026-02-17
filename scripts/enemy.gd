extends CharacterBody3D

signal died(points: int)

@export var speed := 2.8
@export var hp := 20
@export var touch_damage := 8
@export var points := 10

var base_node: Node3D

func _ready() -> void:
	add_to_group("enemy")

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(base_node):
		return
	var dir = (base_node.global_position - global_position)
	dir.y = 0
	if dir.length() < 1.2:
		if base_node.has_method("take_damage"):
			base_node.take_damage(touch_damage)
		queue_free()
		return
	velocity = dir.normalized() * speed
	move_and_slide()
	look_at(base_node.global_position, Vector3.UP)

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		died.emit(points)
		queue_free()
