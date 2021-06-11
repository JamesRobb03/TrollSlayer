extends CollisionShape2D

export var bossCheckpoint = false #if true it then can send a signal to the boss telling it to chase the player

var torchOn = false
signal sendBodyToBoss(body)

#when the player enters the area2d of the checkpoint it turns on the torch animation and 
#updates the global scene with the spawn location of the player (singleton!)
func _on_Checkpoint_body_entered(body):
	if body.name == "Player":
		torchOn = true
		Global.updateSpawn(self.global_position) 
		if bossCheckpoint == true:
			emit_signal("sendBodyToBoss", body)
			Global.bossFight()
