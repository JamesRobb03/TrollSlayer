extends Node2D

#Component for health of enemies and players

export var maxHealth = 100 #export var so can set the health of different enemies

var health = maxHealth

func _ready():
	health = maxHealth # sets health to max health
	#print("health on load = " + str(health))

#function for taking damage
func takeDamage(var damage):
	health -= damage
	health = clamp(health, 0, maxHealth)
	return health
