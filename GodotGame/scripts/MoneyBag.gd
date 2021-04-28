extends RigidBody2D

#loads next level when player enters coin body
func _on_coinArea_body_entered(body):
	if body.name == "Player":
		Global.nextLevel()
