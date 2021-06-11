extends RigidBody2D

onready var disableTime = $disableTime
onready var enableTime = $enableTime
onready var collider = $Collider
onready var sprite = $Sprite

# disable platform if player is on it
func _on_detectPlayer_body_entered(body):
	if body.name == "Player":
		disableTime.start()
#enable platform after a small amount of time
func _on_detectPlayer_body_exited(body):
	if body.name == "Player":
		enableTime.start()

#timer for turning platform back on
func _on_tempTime_timeout():
	collider.set_deferred("disabled", false)
	sprite.visible = true

#tier for turning platform off
func _on_testTime_timeout():
	collider.set_deferred("disabled", true)
	sprite.visible = false
