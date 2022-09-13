extends TextureProgress


export var max_stamina: int = 5
var stamina: int = max_stamina

func _ready() -> void:
	max_value = max_stamina
	value = stamina
	visible = false

func change_stamina(value_to_add: int):
	$TimeToRecover.stop()
	stamina = clamp(stamina + value_to_add, 0, max_stamina)
	value = stamina
	
	if(value_to_add < 0):
		visible = true
		$RecoverTimer.stop()
		$TimeToRecover.start()

func has_stamina():
	return stamina > 0

func _on_TimeToRecover_timeout() -> void:
	$RecoverTimer.stop()
	
	change_stamina(+1)
	$RecoverTimer.start()

func _on_RecoverTimer_timeout() -> void:
	if stamina == max_stamina:
		$RecoverTimer.stop()
		visible = false
		return
	
	change_stamina(+1)

