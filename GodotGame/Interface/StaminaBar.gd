extends HBoxContainer



func _on_interface_staminaChanged(stamina):
	$TextureProgress.value = stamina
