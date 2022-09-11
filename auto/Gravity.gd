extends Node

var gravity_speed = 10

func apply_gravity_to_body(body: KinematicBody2D, motion: Vector2) -> Vector2:
	if not body.is_on_floor(): motion.y += gravity_speed
	if body.is_on_floor(): motion.y = 1
	if body.is_on_ceiling() and not body.is_on_floor(): motion.y = 1
	return motion
