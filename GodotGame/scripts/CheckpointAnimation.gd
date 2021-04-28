extends Area2D

#handles animation of checkpoint
func _process(delta):
	if $CollisionShape2D.torchOn:
		$AnimationPlayer.play("torchOn")
	else:
		$AnimationPlayer.play("torchOff")
	
