extends KinematicBody2D

export var damage = 10
export var flashTime = 0.1

var motion = Vector2.ZERO
var player = null

#components of enemy entity
onready var sprite = $Sprite
onready var animPlay = $AnimationPlayer
onready var damagetimer = $damageTimer
onready var audio = $Scream
onready var damageAudio = $damage
onready var healthComponent = $Health
onready var movementComponent = $Movement
onready var FSM = $FSM

var leftAttackRange = false

func _ready():
	damagetimer.connect("timeout", self, "damageTimer")
	set_physics_process(false)

#Game loop for the enemy, running the systems that control its behaviours 
func _physics_process(delta):
	enemyMovementSystem(delta)
	animationSystem()
	soundSystem()

func damageTimer():
	modulate = Color(1,1,1,1)

#System which handles all the components that are to do with movement. 
#Depending on the current state of the state machine component
#the function then passes the right variables to the movement component which then returns
#a vector2 that is then passed to the move_and_slide function
func enemyMovementSystem(var delta):
	if FSM.currentState == "chase":
		motion = movementComponent.chase(player, delta, $RunSprite)
	elif FSM.currentState == "idle":
		motion = movementComponent.chase(null, delta, $IdleSprite)
	elif FSM.currentState == "attack":	
		motion.x = 0
		motion.y = 0
	else:
		print("ERROR IN MOVEMENT SYSTEM. CHECK STATES ARE SET CORRECTLY")
	motion = move_and_slide(motion, Vector2.UP)


#This system handles all the components required for animation. Works very similiar to the movements system
#in that depending on the current state it plays a certain animation.
func animationSystem():
	if FSM.currentState == "chase":
		animPlay.play("running")
	elif FSM.currentState == "idle":
		animPlay.play("idle")
	elif FSM.currentState == "attack":	
		animPlay.play("explode")
	else:
		print("ERROR IN ANIMATION SYSTEM. CHECK STATES ARE SET CORRECTLY")

#This system handles playing the correct sounds depending on the state
func soundSystem():
	if FSM.currentState == "chase":
		if !audio.is_playing():
			audio.play()
	elif FSM.currentState == "idle":
		audio.stop()
	elif FSM.currentState == "attack":	
		pass
	else:
		print("ERROR IN SOUND SYSTEM")

#function for taking damage. similiar to all other 
#take damage functions. Uses health component to update health
#also handles flashing red and playing the damage sound
func takeDamage(var attackDamage):
	modulate = Color(0.86, 0.08, 0.24, 1)
	damagetimer.start(flashTime)
	healthComponent.takeDamage(attackDamage)
	damageAudio.play()
	print("Enemy Health: "+ str(healthComponent.health))
	if healthComponent.health <= 0:
		queue_free()

#function for boss spawning
func setup(target, startPos):
	player = target
	FSM.setStateChase()
	movementComponent.startPos = startPos
	
#if player comes into aggro range set player as target
#and enter chase state
func _on_enemyVision_body_entered(body):
	if body.name == "Player":
		player = body
		FSM.setStateChase()

#if the player leaves the enemies vision then the state is set to idle
#and player is set to null.
func _on_enemyVision_body_exited(body):
	if body.name == "Player":
		player = null
		FSM.setStateIdle()

#if player gets hit by attack then damage player
func _on_attackRange_body_entered(body):
	if body.name == "Player":
		body.takeDamage(damage, true)
		
#If player is in attack range stop running at player. if not chase player
func _on_inRange_body_entered(body):
	if body.name == "Player":
		FSM.setStateAttack()
		sprite.scale.x = 1 * sign(position.direction_to(body.position).x)

#sets left attack range to true so that attack animation can complete before changing to chase state
func _on_inRange_body_exited(body):
	if body.name == "Player":
		if FSM.currentState != "dead":
			leftAttackRange = true

#handles changing state to chase state from attack state. allows the animation to finish first before allowing the enemy to chase the player
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "explode":
		if leftAttackRange:
			FSM.setStateChase()
			leftAttackRange = false
