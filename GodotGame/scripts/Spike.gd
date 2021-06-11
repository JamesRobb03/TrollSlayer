extends Area2D


func _on_Spike_body_entered(body):
	if body.name == "Player":
		body.takeDamage(body.playerHealth, false)
