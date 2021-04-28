extends Node2D

var inArea = false
var target = null
var canHeal = true
var healCounter = 0
var maxHeal = 1
signal health(health)

#game loop for healing zone. 
#when the player is in the area2d and can heal then increase the players health up until the max health
func _process(delta):
	if inArea and target!=null and canHeal:
		if target.healthComponent.health < target.healthComponent.maxHealth:
			target.healthComponent.health += 1
			emit_signal("health",target.healthComponent.health)
	
	if healCounter >= maxHeal:
		canHeal = false
		$Particles2D.emitting = false
			

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		target = body
		inArea = true

func _on_Area2D_body_exited(body):
	if body.name == "Player":
		healCounter = healCounter+1
		target = null
		inArea = false
