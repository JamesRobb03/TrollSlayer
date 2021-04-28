extends Node2D

export var playerStamina = 250
export var dashStamina = 250
export var blockStamina = 10
export var staminaRegenRate = 0.5

var currentStamina = playerStamina
var canBlock = true

onready var timer = $blockTimer

signal staminaAmount(currentStamina)

#runs every frame
func _physics_process(delta):
	stamina()
	
func stamina():
	if currentStamina < playerStamina:
		currentStamina+=staminaRegenRate
	emit_signal("staminaAmount", currentStamina)

#playerDashed
func playerDash():
	if currentStamina - dashStamina < 0:
		return false
	else:
		currentStamina = currentStamina - dashStamina
		return true


#playerBlocked
func playerBlock():
	
	if canBlock == true:
		if currentStamina - blockStamina >= 0:
			currentStamina = currentStamina - blockStamina
			return true
		else:
			canBlock = false
			timer.start()
			return false
	else:
		return false
	

		
func _on_blockTimer_timeout():
	canBlock = true
