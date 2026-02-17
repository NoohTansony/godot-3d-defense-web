extends Node3D

@export var hp := 100

@onready var hp_label: Label3D = $HPLabel3D

func _ready() -> void:
	_update_label()

func take_damage(amount: int) -> void:
	hp -= amount
	_update_label()
	if hp <= 0:
		queue_free()

func _update_label() -> void:
	if hp_label:
		hp_label.text = "BASE HP: %d" % hp
