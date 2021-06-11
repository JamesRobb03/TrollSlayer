extends KinematicBody2D

#options for boss
export var comboMode = true
export var firstHealthLevel = 2 # read as health/firsthealthlevel
export var comboModeLevel = 5 # same as above

export var fakeAttacks = true
var isFakeAttacking = false #used for logic around fake attacking

export var enableSummoning = true
export var summonMinion: PackedScene
var canSummon = true #is used with a timer to spawn a summonMinion
var minionCount = 0
export var maxMinions = 3
#basic boss variables
export var attack1Damage = 33
export var attack2Damage = 10
export var stunTime = 2.5
export var criticalStrikeDamage = 2 #read as a multiplier so x2
export var criticalStrikeChance = 10 #read as a percent so 10%

var leftAttackRange = false
var canAttack = true
var attackFinished = true
var target = null 
var motion = Vector2.ZERO #used for movement
var flashTime = 0.2 #amount of time the boss flashed red for when it takes damage
var animationFinished = false

var insulting = false

export var coin: PackedScene

onready var animationPlayer = $AnimationPlayer
onready var healthComponent = $Health
onready var movementComponent = $Movement
onready var FSM = $FSM
onready var damagetimer = $damageTimer
onready var sound = $SoundEffects

signal healthChange(health) #signal that is emitted when the health is changed (when the boss takes damage)
signal bossMaxHealth(maxhealth) #used for the health bar of the boss
#random number generation for random attacks and critical strikes
var rng = RandomNumberGenerator.new()

func _ready():
	damagetimer.connect("timeout", self, "damageTimer")
	rng.randomize() #setting up random number generation used for attack logic
	FSM.setStateIdle()
	emit_signal("bossMaxHealth", healthComponent.health)

#game loop for boss
func _physics_process(delta):
	enemyMovementSystem(delta) #handles all movement
	animationSystem() #handles animations and attack 
	summon() # runs the summon minions logic

#function in which if summoning is enabled and the boss is half health then minions are spawned above the boss
func summon():
	if enableSummoning and canSummon and FSM.currentState != "dead" and minionCount <= maxMinions:
		if healthComponent.health <= healthComponent.maxHealth/2:
			var summonMinionTemp = summonMinion.instance()
			get_parent().add_child(summonMinionTemp)
			summonMinionTemp.global_position.x = global_position.x
			summonMinionTemp.global_position.y = global_position.y-100
			summonMinionTemp.setup(target, global_position)
			minionCount = minionCount + 1
			canSummon = false
			$summoningTimer.start()

#System which handles all the components that are to do with movement. 
#Depending on the current state of the state machine component
#the function then passes the right variables to the movement component which then returns
#a vector2 that is then passed to the move_and_slide function
func enemyMovementSystem(var delta):
	if FSM.currentState == "chase":
		motion = movementComponent.chase(target, delta, $runningSprite)
	elif FSM.currentState == "idle":
		motion = movementComponent.chase(null, delta, $runningSprite)
	elif FSM.currentState == "attack" or FSM.currentState == "dead":# if attacking or dead the motion is set to 0 so the boss does not move
		motion.x = 0
		motion.y = 0
	else:
		print("ERROR IN MOVEMENT SYSTEM. CHECK STATES ARE SET CORRECTLY")
	motion = move_and_slide(motion, Vector2.UP)


#This system handles all the components required for animation. Works very similiar to the movements system
#in that depending on the current state it plays a certain animation.
#the animation system also handles the logic for attacking as the attacks are contained within the animations.
#when in the attack state the animation system calls the attack System function to deal with the logic
#required for attackingd
func animationSystem():
	if FSM.currentState == "chase":
		insult()
		animationPlayer.play("running")
	elif FSM.currentState == "idle":
		animationPlayer.play("idle")
	elif FSM.currentState == "attack":	
		attackSystem()
	elif FSM.currentState == "dead": #when dead disable collision shapes so that they are not left on if the boss dies half way through the animation
		$attack1sprite/hitbox/CollisionShape2D.set_deferred("disabled", true)
		$attack2Sprite/hitbox2/CollisionShape2D.set_deferred("disabled", true)
		if !animationFinished: #this makes sure that this is only played once.
			animationPlayer.play("death") 
	else:
		print("ERROR IN ANIMATION SYSTEM. CHECK STATES ARE SET CORRECTLY")

#function for taking damage. similiar to all other 
#take damage functions. Uses health component to update health
#also handles flashing red and playing the damage sound
func takeDamage(var attackDamage):
	healthComponent.takeDamage(attackDamage)
	emit_signal("healthChange", healthComponent.health)
	modulate = Color(0.86, 0.08, 0.24, 1)
	damagetimer.start(flashTime)
	#print("Boss Health: "+ str(healthComponent.health))
	sound.playSoundEffect("damage")
	if healthComponent.health <= 0:
		die() 

#function for normal attack 2
func attack2(randomAttackTimer):
	attackFinished = false
	animationPlayer.play("attack2")
	$slamTimer.start(0.5) # plays the slam noise after 0.5 seconds
	canAttack = false
	$attackTimer.start(randomAttackTimer) #sets can attack back to true after a random amount of seconds.
#function for normal attack 1
func attack1(randomAttackTimer):
	attackFinished = false
	animationPlayer.play("attack1")
	canAttack = false
	if target!= null:
		$attack1sprite.scale.x = 1 * sign(position.direction_to(target.position).x) #sets the direction that the enemy attacks in
	$attackTimer.start(randomAttackTimer) #sets can attack back to true after a random amount of seconds.

#System which handles all attacking logic. 
func attackSystem():
	if canAttack and attackFinished: #only attacks when a previous attack has finished being animated + the cooldown time between attacks
		var randomAttackNumber = rng.randi_range(0,30) #generates a random integer between 0 and 30
		var randomAttackTimer
		var doesBossFakeAttack
		var whenToFake
		
		#if combo mode is enabled health pools decide how fast the boss attacks allowing them to combo attack(e.g. slam straight into a punch)
		if comboMode:
			#If the boss has lower health change the attack timer to allow for bigger combo attacks.
			if healthComponent.health <=  healthComponent.maxHealth/firstHealthLevel and healthComponent.health > healthComponent.maxHealth/comboModeLevel: #if below half health
				randomAttackTimer = rng.randf_range(1,2)
			elif healthComponent.health <= healthComponent.maxHealth/comboModeLevel: # when on 20% health the boss enters combo mode
				randomAttackTimer = 0.5
				#print("COMBO MODE")
			else:
				randomAttackTimer = rng.randf_range(1.25,2.5) #when boss is above half health 
		else:
			randomAttackTimer = rng.randf_range(1,2.5)

		# ATTACK 2 LOGIC
		# if randomAttackNumber is a factor of 3 then use attack two
		if randomAttackNumber%3 == 0:
			if fakeAttacks: #if fake attack option is turned on then potentially turn this attack into a fake one
				doesBossFakeAttack = rng.randi_range(1,10) 
				if doesBossFakeAttack%3 == 0 and !isFakeAttacking: # 1/3 chance of fake attacking and makes sure that the boss can only fake one attack
					isFakeAttacking = true 
					#print("FAKE ATTACK")
					whenToFake = rng.randf_range(0.3, 0.35) # chooses a random time to fake. these numbers are times in the animation where it looks good to have a fake attack
					attackFinished = false
					animationPlayer.play("attack2fake") # plays the fake attack animation. this is the same as the normal attack 2 animation however the colliders are removed to prevent them being turned on if the animation plays too long
					$fakeAttackTimer.start(whenToFake)#after whenToFake amount of seconds it then plays the attack 1 animation
				else:
					attack2(randomAttackTimer) #if the boss doesnt fake attack then normal attack
			else:
				attack2(randomAttackTimer)#if fake attacking is turned off then just normal attack
		#ATTACK 1 LOGIC
		else:
			if fakeAttacks: #Same logic as above but for attack 1 instead of 2
				doesBossFakeAttack = rng.randi_range(1,10)
				if doesBossFakeAttack%3 == 0 and !isFakeAttacking: # 1/3 chance of fake attacking
					isFakeAttacking = true
					#print("FAKE ATTACK")
					whenToFake = 0.2
					attackFinished = false
					animationPlayer.play("attack1fake")
					$fakeAttackTimer2.start(whenToFake)
				else:
					attack1(randomAttackTimer)
			else:
				attack1(randomAttackTimer)
	#play the idle animation if attack is still on cooldown
	elif canAttack == false and attackFinished == true :
		animationPlayer.play("idle")

#the function which is called when the boss dies.
func die():
	#play sound/animations
	FSM.setStateDead() # set the state to dead
	sound.playSoundEffect("death") #play the death animation
	$coinTimer.start(1) #drop money for player to progress to next level
	
#function for voice clip of the boss telling the player they suck
#is said periodically between 10 and 20 seconds
func insult():
	if !insulting:
		var random = rng.randi_range(10, 20)
		insulting = true
		$insultTimer.start(random)

#function which is called when the boss is killed.
#is used to dtop a coin which when collided with increases
#a variable in the Global script(singleton pattern!) which then loads the next level.
func dropCoin():
	var tempCoin = coin.instance()
	get_parent().add_child(tempCoin)
	tempCoin.global_position = global_position
	queue_free() #Once a coin has been dropped, delete the boss from memory

#Signals and timers

#signal for when the player walks through the boss checkpoint.
#it then sets the target of the boss to the player
func _on_CollisionShape2D_sendBodyToBoss(body):
	target = body
	if FSM.currentState != "dead":
		FSM.setStateChase()

#signal for the attack range area. if the player enters this area then the 
#boss changes states to attack
func _on_attackRange_body_entered(body):
	if body.name == "Player":
		if FSM.currentState != "dead":
			FSM.setStateAttack()
			leftAttackRange = false

#if the player is no longer in attack range then set left attack range to true
#done like this so that the animation of the attack is finished before the 
#state is changed to chase.
func _on_attackRange_body_exited(body):
	if body.name == "Player":
		if FSM.currentState != "dead":
			leftAttackRange = true

#signal for attack timer timeout that allows the boss to attack again
func _on_attackTimer_timeout():
	canAttack = true

#signal from the animation player that allows the animations to complete before the boss attacks or chases the player.
func _on_AnimationPlayer_animation_finished(anim_name): # when animations finish set it so can attack again
	if anim_name == "attack1" or anim_name == "attack2" and FSM.currentState != "dead" and !isFakeAttacking:
		attackFinished = true
		if leftAttackRange:
			FSM.setStateChase()
			leftAttackRange = false
	elif anim_name == "death":
		animationFinished = true

#signal for attack ones hitbox. if a player is in this hitbox when it is activated then
#the player takes damage. it also has the chance to critically strike dealing more damage
#then a normal attack. Always crits when the player is stunned
func _on_hitbox_body_entered(body): #attack 1
	if body.name == "Player":
		var damage = attack1Damage
		var crit = rng.randi_range(0,100)
		if crit <= criticalStrikeChance or body.isStunned:
			modulate =  Color(1, 0.84, 0, 1)
			damagetimer.start(0.2)
			damage = damage*criticalStrikeDamage
			print("CRIT!")
		body.takeDamage(damage, true)

#signal for attack twos hitbox. if a player is in this hitbox when activated
#the player takes a small amount of damage and is knocked up and stunned.
#this attack can also critically strike
func _on_hitbox2_body_entered(body): # attack 2!
	if body.name == "Player":
		var damage = attack2Damage
		var crit = rng.randi_range(0,100)
		if crit <= criticalStrikeChance:
			modulate =  Color(1, 0.84, 0, 1)
			damagetimer.start(0.2)
			damage = damage*criticalStrikeDamage
			print("CRIT!")
		body.takeDamage(damage, true) #uses players takeDamage method 
		body.stun(stunTime) #uses players stun method

func _on_fakeAttackTimer_timeout(): # For Fake Attack slam -> punch
	isFakeAttacking = false
	attackFinished = false
	animationPlayer.play("attack1")
	canAttack = false
	$attack1sprite.scale.x = 1 * sign(position.direction_to(target.position).x)
	$attackTimer.start(1)
	
func _on_fakeAttackTimer2_timeout():# For fake attack punch -> slam
	isFakeAttacking = false
	attackFinished = false
	animationPlayer.play("attack2")
	$slamTimer.start(0.5)
	canAttack = false
	$attackTimer.start(1)

#function called by the damageTimer which turns the players color back to normal
func damageTimer():
	modulate = Color(1,1,1,1)

#timer for summoning function, setting canSummon to true spawning another minion
func _on_summoningTimer_timeout():
	if minionCount < maxMinions:
		canSummon = true

#after the boss has been dead for a certain amount of seconds then drop coin is called
func _on_coinTimer_timeout():
	dropCoin()

#timer function for playing you suck voiceline
func _on_insultTimer_timeout():
	sound.playSoundEffect("yousuck")
	insulting = false
	
#timer for playing slam when it hits the ground
func _on_slamTimer_timeout():
	sound.playSoundEffect("slam")
