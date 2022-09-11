class_name Player extends KinematicBody2D

var Direction = preload("res://entities/player/Direction.gd")

onready var status = $Status

const MIN_VELOCITY_TO_STOP = 5

export var direction: int = Direction.RIGHT

var motion = Vector2.ZERO

var is_climbing: bool = false

# Overrides
func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	verify_actions()
	# Intended order = Gravity -> Movement -> Jump
	apply_gravity()
	await_movement()
	await_jump()
	
	move_and_slide_with_snap(motion, Vector2.ZERO, Vector2.UP)

# Movement
func verify_actions():
	is_climbing = (
		is_on_wall() 
		and Input.is_action_pressed("climb") 
		and $StaminaBar.has_stamina()
		and not is_on_floor()
	)

func get_horizontal_movement() -> float:
	var acceleration = status.acceleration if is_on_floor() else status.acceleration_on_air
	var max_speed = status.max_speed
	
	# When moving
	if(Input.is_action_pressed("move_right")):
		set_direction(Direction.RIGHT)
		# easing the move using acceleration values
		return min(lerp(motion.x, max_speed, acceleration), max_speed)
	
	if(Input.is_action_pressed("move_left")):
		set_direction(Direction.LEFT)
		# easing the move using acceleration values
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

func get_vertical_movement() -> float:
	if Input.is_action_pressed("look_up"):
		return -status.climb_speed
	
	if Input.is_action_pressed("look_down"):
		return status.climb_speed
	
	return 0.0

func await_jump():
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jump()
		
		if is_on_floor() and Input.is_action_pressed("look_down"):
			jump_down()
		
		if is_climbing:
			wall_jump()

func await_movement():
	motion.x = get_horizontal_movement()
	
	if is_on_wall() and Input.is_action_pressed("climb") and $StaminaBar.has_stamina():
		motion.y = get_vertical_movement()
		motion.x = direction

func apply_gravity():
	if not is_climbing or not $StaminaBar.has_stamina():
		motion = Gravity.apply_gravity_to_body(self, motion)
		if is_on_floor(): $ClimbStaminaUsage.stop()
	
	if is_climbing:
		motion.y = 0
		if $ClimbStaminaUsage.is_stopped(): $ClimbStaminaUsage.start() 

func jump():
	motion.y = -status.jump_speed

func jump_down():
	motion.y += 1

func wall_jump():
	switch_direction()
	motion.x = (status.jump_speed + status.max_speed) * direction
	motion.y -= status.jump_speed

# Utility Functions

func set_direction(new_direction: int):
	$Sprite.scale.x = new_direction
	direction = new_direction

func switch_direction():
	if direction == Direction.RIGHT: set_direction(Direction.LEFT)
	elif direction == Direction.LEFT: set_direction(Direction.RIGHT)


func _on_ClimbStaminaUsage_timeout() -> void:
	$StaminaBar.change_stamina(-1)
