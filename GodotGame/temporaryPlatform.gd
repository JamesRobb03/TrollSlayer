extends RigidBody2D

onready var disableTime = $disableTime
onready var enableTime = $enableTime
onready var collider = $Collider
onready var sprite = $Sprite
	
func _on_detectPlayer_body_entered(body):
	if body.name == "Player":
		disableTime.start()

func _on_detectPlayer_body_exited(body):
	
	if body.name == "Player":
		enableTime.start()

func _on_tempTime_timeout():
	collider.set_deferred("disabled", false)
	sprite.visible = true

func _on_testTime_timeout():
	collider.set_deferred("disabled", true)
	sprite.visible = false
