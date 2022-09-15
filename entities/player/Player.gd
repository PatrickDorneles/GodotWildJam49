class_name Player extends KinematicBody2D

const Direction := preload("res://entities/player/Direction.gd")

onready var status := $Status
onready var stamina := $Stamina
onready var anim_tree := $AnimationTree
onready var state_machine: AnimationNodeStateMachinePlayback = anim_tree["parameters/playback"]

const MIN_VELOCITY_TO_STOP = 5
const MAGIC_POSITION_X = 24
const MAX_INT = 9999

export var facing := Direction.RIGHT

var motion := Vector2.ZERO

var climbing := false
var dashing := false



# Overrides
func _ready() -> void:
	anim_tree.active = true

func _physics_process(_delta: float) -> void:
	verify_actions()
	# Intended order = Gravity -> Movement -> Jump
	apply_gravity()
	await_movement()
	await_jump()

	move_and_slide_with_snap(motion, Vector2.ZERO, Vector2.UP)

# Movement
func verify_actions():
	climbing = (
		is_on_wall() 
		and Input.is_action_pressed("climb") 
		and stamina.has_stamina()
		and not is_on_floor()
	)

func get_horizontal_movement() -> float:
	var acceleration: float = status.acceleration if (is_on_floor() or climbing) else 0
	var max_speed: float = status.max_speed 
	
	# When moving
	if(Input.is_action_pressed("move_right") 
		and (is_on_floor())):
		set_facing_direction(Direction.RIGHT)
		if not state_machine.get_current_node() == "Jumping": 
			state_machine.travel("Walking")
		# easing the move using acceleration values
		return clamp(lerp(motion.x, max_speed, acceleration), -max_speed, max_speed)
	
	if(Input.is_action_pressed("move_left") 
			and (is_on_floor())):
		set_facing_direction(Direction.LEFT)
		if not state_machine.get_current_node() == "Jumping": 
				state_machine.travel("Walking")
		# easing the move using acceleration values
		return clamp(lerp(motion.x, -max_speed, acceleration), -max_speed, max_speed)
	
	# When stopping
	if is_on_floor(): 
		state_machine.travel("Idle")
	
	var is_motion_x_positive = motion.x > 0
	var is_motion_x_negative = motion.x < 0

	if is_motion_x_negative and motion.x > -MIN_VELOCITY_TO_STOP:
		return 0.0
	
	if is_motion_x_positive and motion.x < MIN_VELOCITY_TO_STOP:
		return 0.0
	
	var value = clamp(lerp(motion.x, 0, acceleration), -max_speed, max_speed)
	
	return value 

func get_vertical_movement() -> float:
	if Input.is_action_pressed("look_up"):
		return -status.climb_speed
	
	if Input.is_action_pressed("look_down"):
		return status.climb_speed
	
	return 0.0

func await_jump():
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() and Input.is_action_pressed("look_down"):
			return jump_down()

		if is_on_floor():
			jump()
			state_machine.travel("Jumping")
		
		if climbing:
			wall_jump()
			state_machine.travel("Jumping")

func await_movement():
	motion.x = get_horizontal_movement()
	
	if is_on_wall() and Input.is_action_pressed("climb") and stamina.has_stamina():
		motion.y = get_vertical_movement()
		motion.x = facing

func apply_gravity():
	if not climbing:
		motion = Gravity.apply_gravity_to_body(self, motion)
		if motion.y > 1 and state_machine.get_current_node() != "Falling":
			state_machine.travel("Falling")
		if is_on_floor(): $ClimbStaminaUsage.stop()
			
	
	if climbing:
		motion.y = 0
		if $ClimbStaminaUsage.is_stopped(): $ClimbStaminaUsage.start() 

func jump():
	motion.y = -status.jump_speed

func jump_down():
	position.y += 1

func wall_jump():
	switch_facing_direction()
	motion.x = status.max_speed * facing
	motion.y = -(status.jump_speed/1.25)

# Utility Functions

func set_facing_direction(new_direction: int):
	$Sprite.scale.x = new_direction
	facing = new_direction
	$MagicHitBox/Shape.position.x = MAGIC_POSITION_X * new_direction

func switch_facing_direction():
	if facing == Direction.RIGHT: set_facing_direction(Direction.LEFT)
	elif facing == Direction.LEFT: set_facing_direction(Direction.RIGHT)

func _on_ClimbStaminaUsage_timeout() -> void:
	stamina.change_stamina(-1)
