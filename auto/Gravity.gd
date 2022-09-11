extends Node

var gravity_speed = 10

func apply_gravity_to_body(body: KinematicBody2D, motion: Vector2) -> Vector2:
	if not body.is_on_floor(): motion.y += gravity_speed
	
	return motion
