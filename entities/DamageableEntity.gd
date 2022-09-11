class_name DamageableEntity
extends KinematicBody2D

export var unstability: int = 1
export var can_move: bool = true
export var unstable: bool = true

var motion = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	apply_gravity()
	
	move_and_slide(motion, Vector2.UP)

func apply_gravity():
	motion = Gravity.apply_gravity_to_body(self, motion)

func hit(damage: int):
	unstability -= damage


