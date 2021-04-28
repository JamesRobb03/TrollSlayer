extends Control

#signals for sending health and stamina values to children of interface

signal healthChanged(health)
signal staminaChanged(stamina)

func _on_Player_healthChange(healthAmount):
	emit_signal("healthChanged", healthAmount)

func _on_Stamina_staminaAmount(currentStamina):
	emit_signal("staminaChanged", currentStamina)


func _on_HealingZone_health(health):
	emit_signal("healthChanged", health)
