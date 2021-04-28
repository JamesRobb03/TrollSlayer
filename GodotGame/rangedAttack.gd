extends Area2D

export var shootSpeed = 100
var direction = Vector2.ZERO
var facing = 1

func _physics_process(delta):
	position.x += direction.normalized().x * shootSpeed * delta * facing 
	position.y += direction.normalized().y * shootSpeed * delta
	collisionDetection()
		#if $ray1.get_collider().name != "Player" or $ray2.get_collider().name != "Player" or $ray3.get_collider().name != "Player" or $ray4.get_collider().name != "Player":
			#queue_free()

func collisionDetection():
	if $ray1.is_colliding() or $ray2.is_colliding() or $ray3.is_colliding() or $ray4.is_colliding():
		if $ray1.get_collider() != null:
			if $ray1.get_collider().name != "Player":
				queue_free()
		elif $ray2.get_collider() != null:
			if $ray2.get_collider().name != "Player":
				queue_free()
		elif $ray3.get_collider() != null:
			if $ray3.get_collider().name != "Player":
				queue_free()
		elif $ray4.get_collider() != null:
			if $ray4.get_collider().name != "Player":
				queue_free()
				
func setup(pointDirection: Vector2, spritescale):
	direction = pointDirection
	facing = spritescale * -1

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_rangedAttack_body_entered(body):
	if body.name == "Player":
		var player = body
		player.takeDamage(10, true)
		queue_free()
