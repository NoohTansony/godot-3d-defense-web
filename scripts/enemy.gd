extends CharacterBody3D

signal died(points: int)

@export var speed := 2.8
@export var hp := 20
@export var touch_damage := 8
@export var points := 10

var base_node: Node3D

@onready var body_mesh: MeshInstance3D = $Body

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

func setup_variant(kind: int, wave: int) -> void:
	# 0=normal, 1=fast, 2=tank
	var mat := StandardMaterial3D.new()
	match kind:
		1:
			speed = 4.2 + wave * 0.03
			hp = int(12 + wave * 1.5)
			touch_damage = 6
			points = 12
			scale = Vector3.ONE * 0.85
			mat.albedo_color = Color(0.95, 0.78, 0.25)
		2:
			speed = 1.9 + wave * 0.02
			hp = int(40 + wave * 6)
			touch_damage = 14
			points = 20
			scale = Vector3.ONE * 1.25
			mat.albedo_color = Color(0.8, 0.33, 0.35)
		_:
			speed = 2.8 + wave * 0.02
			hp = int(20 + wave * 3)
			touch_damage = 8
			points = 10
			scale = Vector3.ONE
			mat.albedo_color = Color(0.5, 0.7, 0.95)
	body_mesh.material_override = mat
