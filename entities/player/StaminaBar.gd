extends TextureProgress

onready var player: Player = get_parent()
onready var status = player.get_node("Status")

func _ready() -> void:
	max_value = status.max_stamina
	value = status.stamina
	visible = false

func change_stamina(value_to_add: int):
	$TimeToRecover.stop()
	status.stamina = clamp(status.stamina + value_to_add, 0, status.max_stamina)
	value = status.stamina
	
	if(value_to_add < 0):
		visible = true
		$RecoverTimer.stop()
		$TimeToRecover.start()

func has_stamina():
	return status.stamina > 0

func _on_TimeToRecover_timeout() -> void:
	$RecoverTimer.stop()
	
	change_stamina(+1)
	$RecoverTimer.start()

func _on_RecoverTimer_timeout() -> void:
	if status.stamina == status.max_stamina:
		$RecoverTimer.stop()
		visible = false
		return
	
	change_stamina(+1)

