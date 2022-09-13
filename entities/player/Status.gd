extends Node

onready var player: Player = get_parent()

export var acceleration: float = 0.1
export var acceleration_on_air: float = 0.1
export var max_speed: int = 120
export var jump_speed: int = 200
export var climb_speed: int = 80

