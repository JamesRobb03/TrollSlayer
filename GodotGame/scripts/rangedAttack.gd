extends Area2D

export var shootSpeed = 100
var direction = Vector2.ZERO
var facing = 1

#game loop for ranged attack
func _physics_process(delta):
	position.x += direction.normalized().x * shootSpeed * delta * facing 
	position.y += direction.normalized().y * shootSpeed * delta
	collisionDetection()
		#if $ray1.get_collider().name != "Player" or $ray2.get_collider().name != "Player" or $ray3.get_collider().name != "Player" or $ray4.get_collider().name != "Player":
			#queue_free()

#if raycasts are colliding then delete the ranged attack
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

#setup for ranged attack. sets the direction and the way the ranged enemy is facing
func setup(pointDirection: Vector2, spritescale):
	direction = pointDirection
	facing = spritescale * -1

#destroy when not on screen
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

#if collides with play then deal damage
func _on_rangedAttack_body_entered(body):
	if body.name == "Player":
		var player = body
		player.takeDamage(10, true)
		queue_free()
