extends KinematicBody2D

#This script is the Player System. It is what allows for all the components
#to interact with each other

#character controller variables
export var gravity = 200
export var acceleration = 512
export var friction = 10
export var maxHorizontalSpeed = 64
export var maxFallSpeed = 100
export var jumpHeight = -128
export var airResistance = 1

#damage variable
export var attackDamage = 20

#export var for dashing
export(PackedScene) var dashObject
export var dashSpeed = 250
export var dashLength = 0.2
export var flashTime = 0.2

#dash and jump variables
var dashDirection : Vector2
var dashing = false
var canDash = true
var motion = Vector2.ZERO
var jumpCounter = 0
var maxJumps = 2

#variables for checking if actions are happening
var isDead = false
var isAttacking = false
var isBlocking = false
var onMovingPlatform = false
var isStunned = false
var knockUp = false

#on ready variables for components
onready var sprite = $Sprite
onready var animationPlayer = $AnimationPlayer
onready var dashTimer = $dashTimer
onready var attackTimer = $attackTimer
onready var damagetimer = $damageTimer
onready var soundEffects = $SoundEffects
onready var staminaComponent = $Stamina
onready var playerHealth = $Health.maxHealth
onready var healthComponent = $Health

#const for move and slide with snap
const FLOOR_NORMAL = Vector2.UP
const SNAP_DIRECTION = Vector2.DOWN
const SNAP_LENGTH = 32
#used for move and slide with snap
var snap_vector = SNAP_DIRECTION * SNAP_LENGTH

signal healthChange(healthAmount)

func _ready():
	isDead = false
	dashTimer.connect("timeout", self, "dashTimer")
	attackTimer.connect("timeout", self, "attackTimer")
	damagetimer.connect("timeout", self, "damageTimer")
	if Global.checkpointCounter == 0:
		Global.setSpawnpoint(self.position)
	self.position = Global.spawnpoint
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$stunAnimation.visible = false

func _on_attackHit_area_entered(area):
	if area.name == "hurtbox":
		area.get_parent().takeDamage(attackDamage)

func damageTimer():
	sprite.modulate = Color(1,1,1,1)
func dashTimer():
	dashing=false
func attackTimer():
	isAttacking = false

func _physics_process(delta):
	playerDashing(delta)
	playerMovement(delta)
	block()

func playerMovement(var delta):
	#left or right
	if isDead == false and !isStunned:
		var xInput = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		#Horizontal Control movement
		if xInput !=0:
			if(is_on_floor() and isAttacking == false and isBlocking == false):
				animationPlayer.play("run")
				
			motion.x += xInput * acceleration * delta
			motion.x = clamp(motion.x, -maxHorizontalSpeed, maxHorizontalSpeed)
			sprite.scale.x = xInput
		else:
			if(is_on_floor() and isAttacking == false and isBlocking == false):
				animationPlayer.play("idle")

		#vertical control movement
		var yInput = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		#apply gravity
		motion.y += gravity * delta
		
		if(is_on_floor()):
			if snap_vector == Vector2.ZERO:
				snap_vector = SNAP_DIRECTION * SNAP_LENGTH
			jumpCounter = 0
			if xInput == 0:
				motion.x = lerp(motion.x, 0, friction * delta)
		else:
			#if they are falling then clamp the y to fall speed
			motion.y = clamp(motion.y, -maxFallSpeed, maxFallSpeed)
			#play fall animation
			if isAttacking==false: #and !isOnGround()
				animationPlayer.play("falling")
			if Input.is_action_just_released("ui_jump") and motion.y < jumpHeight/2:
				motion.y = jumpHeight/2
			if xInput == 0:
				motion.x = lerp(motion.x, 0, airResistance * delta)

		#If user presses jump button then check if they are on floor and apply jump height
		if(Input.is_action_just_pressed("ui_jump") and isBlocking == false):
			if (is_on_floor()): #and isOnGround()
				snap_vector = Vector2.ZERO
				motion.y = jumpHeight
				if !isAttacking:
					animationPlayer.play("jump")
				jumpCounter += 1
			else:
				if jumpCounter < maxJumps:
					motion.y = jumpHeight
					if !isAttacking:
						animationPlayer.play("jump")
					jumpCounter += 1
					
		#think this can be moved
		if Input.is_action_just_pressed("ui_attack") and isAttacking ==false and isBlocking == false:
			isAttacking = true
			animationPlayer.play("attack")
			soundEffects.playSoundEffect("sword")
			attackTimer.start(0.5)
		if isBlocking == true:
			animationPlayer.play("block")
			motion.x = motion.x/1.2
			
	#apply move and slide
	if isDead == false:
		if dashing == true and !isStunned:
			motion = move_and_slide(dashDirection, Vector2.UP)
			motion.x = lerp(motion.x, 0, 0.2)
			motion.y = lerp(motion.y, 0, 0.5)
		else:
			if onMovingPlatform:
				motion = move_and_slide_with_snap(motion, snap_vector, FLOOR_NORMAL)
			else:
				if !isStunned:
					motion = move_and_slide(motion, Vector2.UP)
				else:
					if !knockUp:
						if !is_on_floor():
							motion.y += 5
							motion.x = 0
							motion = move_and_slide(motion, Vector2.UP)
						else:
							if !isAttacking:
								animationPlayer.play("idle") #play stun animation
					else:
						motion.y = jumpHeight
						motion.x = 0
						motion = move_and_slide(motion, Vector2.UP)
						if !isAttacking:
							animationPlayer.play("jump")
	else:
		
		motion.x = 0
		motion.y = 0
		motion = move_and_slide(motion, Vector2.UP)
#Handles dash direction and speed and length of dash
func playerDashing(var delta):
	var moveDir = Vector2()
	moveDir.x = -Input.get_action_strength("ui_left") + Input.get_action_strength("ui_right")
	moveDir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	moveDir = moveDir.clamped(1)
	if moveDir == Vector2(0,0):
		if sprite.scale.x == -1:
			moveDir.x = -1
		else:
			moveDir.x = 1
			
	if Input.is_action_just_pressed("ui_dash") and staminaComponent.playerDash() == true and !isStunned:
		dashing = true
		soundEffects.playSoundEffect("dash")
		dashDirection = moveDir*dashSpeed
		dashTimer.start(dashLength)
	
	if dashing:
		var dashNode = dashObject.instance()
		dashNode.global_position = global_position
		dashNode.scale.x = sprite.scale.x
		get_parent().add_child(dashNode)
		if is_on_wall():
			dashing = false

#function for taking damage. uses health component
func takeDamage(var damage, var canBeBlocked):
	if isDead == false:
		if isBlocking and canBeBlocked:
			sprite.modulate = Color( 2, 2, 2, 1)
			damagetimer.start(flashTime)
			print("blocked attack")
		else:
			#take player health away
			playerHealth = $Health.takeDamage(damage)
			emit_signal("healthChange", playerHealth)
			#damage flash
			sprite.modulate = Color(0.86, 0.08, 0.24, 1)
			damagetimer.start(flashTime)
			#small screen shake?
			print("Player Health: "+ str(playerHealth))
			#logic for player death
			if playerHealth <=0:
				print("dead")
				isDead = true
				soundEffects.playSoundEffect("death")
				animationPlayer.play("death")
				#when complete run dead.
				$deathTime.start()
			else:
				soundEffects.playSoundEffect("damage")

#function for being stunned
func stun(var time):
	if !dashing:
		isStunned = true
		knockUp = true
		$stunAnimation.visible = true
		$stunTimer.start(time)
		$knockupTimer.start(0.2)
	pass

func block():
	if Input.is_action_pressed("ui_block") and isAttacking == false and staminaComponent.playerBlock() == true:
		isBlocking = true
	else:
		isBlocking = false

func dead():
	Global.incDeathCount()
	get_tree().reload_current_scene()

func _on_deathTime_timeout():
	dead()

func _on_movingPlatform_onPlatform(isOnPlatform):
	if isOnPlatform == true:
		onMovingPlatform = true
	else:
		onMovingPlatform = false


func _on_stunTimer_timeout():
	isStunned = false
	$stunAnimation.visible = false


func _on_knockupTimer_timeout():
	knockUp = false
