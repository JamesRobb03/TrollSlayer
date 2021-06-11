extends KinematicBody2D

#component references
onready var healthComponent = $Health
onready var FSM = $FSM
onready var enemyMovementComponent = $Movement
onready var animPlayer = $AnimPlay
onready var sprite = $Sprite
onready var damagetimer = $damageTimer
onready var sound = $SoundEffects

#packed scene for attack
export var attack: PackedScene

var canShoot = true

#variables for movement
var target = null
var motion = Vector2.ZERO

func _ready():
	animPlayer.play("idle")

#game loop for ranged enemy
func _physics_process(delta):
	rangedAttackSystem()
	movementSystem(delta)

#function for taking damage
func takeDamage(var attackDamage):
	healthComponent.takeDamage(attackDamage)
	modulate = Color(0.86, 0.08, 0.24, 1)
	damagetimer.start(0.2)
	if healthComponent.health <= 0:
		queue_free()

#system for enemy movement. uses a function from the movement component to work out
#where the enemy should move to depending on the current state of the enemy
func movementSystem(delta):
	if FSM.currentState == "chase":
		motion = enemyMovementComponent.rangedChase(target, delta)
	elif FSM.currentState == "idle":
		motion = enemyMovementComponent.rangedChase(null, delta)
	else:
		print("ERROR")
	motion = move_and_slide(motion, Vector2.UP)

#when in chase state periodically fire ranged attacks towards the player
func rangedAttackSystem():
	if FSM.currentState == "chase" and canShoot == true:
		canShoot = false
		$ShotTimer.start()
		sound.playSoundEffect("spit")
		var tempAttack = attack.instance()
		get_parent().add_child(tempAttack)
		tempAttack.global_position = global_position
		tempAttack.setup((target.global_position - position), -scale.x)
		
#function for boss spawning
func setup(target, startPos):
	enemyMovementComponent.startPos = startPos

func _on_ShotTimer_timeout():
	canShoot = true

#set state to chase if enters enemy range
func _on_enemyVision_body_entered(body):
	if body.name=="Player":
		target = body
		FSM.setStateChase()
		sound.playSoundEffect("aggro")

#set state to idle if leaves enemy range
func _on_enemyVision_body_exited(body):
	if body.name=="Player":
		target = null
		FSM.setStateIdle()
		sound.stopSoundEffect("aggro")

func _on_damageTimer_timeout():
	modulate = Color(1,1,1,1)
