extends KinematicBody2D

#setting up references to components
onready var FSM = $FSM
onready var healthComponent = $Health
onready var movementComponent = $Movement
onready var animPlayer = $AnimationPlayer
onready var onFloor = $onFloor
onready var onWall = $onWall
onready var damagetimer = $damageTimer
onready var soundeffects = $soundeffects

var inAttackRange = false
var attackFinished = true

var motion = Vector2.ZERO
var target = null
var direction = 1

#sets the direction the patroller starts running in based of the scale of the sprite
func _ready():
	direction = scale.x
	damagetimer.connect("timeout", self, "damageTimer")

#game loop for the patroller, running the movement system and the animation system
func _physics_process(delta):
	enemyMovementSystem(delta)
	soundSystem()
	animationSystem()
	
#Different to the other enemy movement systems as the patroller only has two states
#idle - where he patrols an area, and attack - where he attacks a player if they are in the attack range.
#uses the state machine component and the movement component to handle the movement
func enemyMovementSystem(var delta):
	if FSM.currentState == "idle":
		motion = movementComponent.patrol(delta) #uses patrol method of movement component
	elif FSM.currentState == "attack":# if attacking dont move
		motion.x = 0
		motion.y = 0
	else:
		print("ERROR IN MOVEMENT SYSTEM")
	motion = move_and_slide(motion, Vector2.UP)

#System which handles animations based on current states from state machine
func animationSystem():
	if FSM.currentState == "idle":
		animPlayer.play("running")
	elif FSM.currentState == "attack":
		if attackFinished:
			animPlayer.play("attack") #attack logic within the animation. the collision box is animated on and off.
			attackFinished = false
	else:
		print("ERROR IN ANIMATION SYSTEM")

#system handling sound based on current state
func soundSystem():
	if FSM.currentState == "idle":
		pass
	elif FSM.currentState == "attack":
		if attackFinished:
			soundeffects.playSoundEffect("attack")
	else:
		print("ERROR")

#function which uses health component to keep track of current health.
#also turns the color red for .2 seconds to show it has been hit
func takeDamage(var attackDamage):
	soundeffects.playSoundEffect("damage")
	modulate = Color(0.86, 0.08, 0.24, 1)
	damagetimer.start(0.2)
	healthComponent.takeDamage(attackDamage)
	if healthComponent.health <= 0:
		queue_free()
		
func damageTimer():
	modulate = Color(1,1,1,1)

#sets state to attack when player is in attack range
func _on_AttackRange_body_entered(body):
	if body.name == "Player": 
		FSM.setStateAttack()
		inAttackRange = true

#sets in attack range to false so that the animation can complete
func _on_AttackRange_body_exited(body):
	if body.name == "Player": 
		inAttackRange = false

#when animation completed set state tp idle if not in attack range
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "attack":
		attackFinished = true
		if !inAttackRange:
			FSM.setStateIdle()

#if player is hit by attack deal 100 damage, impossible to block
func _on_damageRange_body_entered(body):
	if body.name == "Player":
		body.takeDamage(100, false)
