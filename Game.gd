extends Node2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var initial_dialog = Dialogic.start("InitialDialog")
	add_child(initial_dialog)
	initial_dialog.pause_mode = PAUSE_MODE_PROCESS
	get_tree().paused = true
	yield(initial_dialog, "timeline_end")
	get_tree().paused = false



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
