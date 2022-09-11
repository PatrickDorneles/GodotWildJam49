extends KinematicBody2D

onready var status = get_node("Status")

const MIN_VELOCITY_TO_STOP = 5

var motion = Vector2.ZERO

# Overrides
func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	print(is_on_floor())
	await_jump()
	apply_gravity()
	motion.x = get_movement()

	move_and_slide_with_snap(motion, Vector2.ZERO, Vector2.UP)

# Movement
func get_movement() -> float:
	var acceleration = status.acceleration if is_on_floor() else status.acceleration_on_air
	var max_speed = status.max_speed
	
	# When moving
	if(Input.is_action_pressed("move_right")):
		$Sprite.flip_h = false
		return min(lerp(motion.x, max_speed, acceleration), max_speed)
	
	if(Input.is_action_pressed("move_left")):
		$Sprite.flip_h = true
		return max(lerp(motion.x, -max_speed, acceleration), -max_speed)
	
	# When stopping
	var is_motion_x_positive = motion.x > 0
	var is_motion_x_negative = motion.x < 0
	
	var value = clamp(lerp(motion.x, 0, acceleration), -max_speed, max_speed)
	
	if is_motion_x_negative and motion.x > -MIN_VELOCITY_TO_STOP:
		return 0.0
	
	if is_motion_x_positive and motion.x < MIN_VELOCITY_TO_STOP:
		return 0.0
	
	return value 

func await_jump():
	var can_jump = is_on_floor() or is_on_wall()
	
	if Input.is_action_just_pressed("jump"):
		if can_jump:
			jump()
		
		if is_on_floor() and Input.is_action_pressed("look_down"):
			jump_down()

func apply_gravity():
	if not is_on_wall():
		motion = Gravity.apply_gravity_to_body(self, motion)

func jump():
	motion.y = -status.jump_speed

func jump_down():
	motion.y += 1

# Utility Functions
