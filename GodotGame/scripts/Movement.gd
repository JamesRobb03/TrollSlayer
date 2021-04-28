extends Node2D

#export variables for physics
export var gravity = 200
export var acceleration = 512
export var friction = 10
export var maxHorizontalSpeed = 50

var motion = Vector2.ZERO
var xaxis = 0
var yaxis = 0
var startPos = Vector2.ZERO
var startRotation 

#gets start position and start rotation
func _ready():
	startPos = get_parent().get_position()
	startRotation = xRound(get_parent().scale.x)
	#print(str(startRotation)+ " : " + str(get_parent().name))

#movement for melee enemies (Boss and Mushroom(enemy))
#when a target is set it gets the direction to the player and applies a force
#in that direction. if the target is not set then the enemy moves back to its starting
#location
func chase(var target, var delta, var sprite):
	if target != null:
		motion.y += gravity * delta
		xaxis = xRound(get_parent().position.direction_to(target.position).x)
		if xaxis != 0:
			sprite.scale.x = xaxis* startRotation
		motion.x =  xaxis * acceleration
		motion.x = clamp(motion.x, -maxHorizontalSpeed, maxHorizontalSpeed)
		motion.y = clamp(motion.y, -maxHorizontalSpeed*2, maxHorizontalSpeed*2)
	else:
		#has a slight margin of error as when trying to be exact caused some strange behaviour if the collider
		#of the enemy ran into the collider of the player
		if get_parent().position.x >= startPos.x - 1 and get_parent().position.x <= startPos.x + 1 :
			motion.x = 0
			sprite.scale.x = 1
		else:
			motion.y += gravity * delta
			xaxis = xRound(get_parent().position.direction_to(startPos).x)
			if xaxis != 0:
				sprite.scale.x = xaxis* startRotation
			motion.x =  xaxis * acceleration
			#Speed lower as he is no longer chasing but just walking back instead
			motion.x = clamp(motion.x, -maxHorizontalSpeed/2, maxHorizontalSpeed/2)
			motion.y = clamp(motion.y, -maxHorizontalSpeed*2, maxHorizontalSpeed*2)
			if get_parent().is_on_wall():
				motion.y = -50
	return motion

#movement used for ranged enemies
#similiar to chase however instead of setting the player as the target it sets the target
#50 units infront of the player 
func rangedChase(var target, var delta):
	if target != null:
		var targetTest = target.position
		#set goal infront of target
		targetTest.x += 50 * target.sprite.scale.x
		xaxis = xRound(get_parent().position.direction_to(targetTest).x) #gets direction of where the enemy needs to path too
		var xaxisSprite = xRound(get_parent().position.direction_to(target.position).x) #gets the direction of the enemy to the player
		if xaxisSprite != 0:
			get_parent().sprite.scale.x = xaxisSprite * startRotation
		motion.x =  xaxis * acceleration
		motion.x = clamp(motion.x, -maxHorizontalSpeed, maxHorizontalSpeed)
		#if at the location stop moving
		if get_parent().position.x >= targetTest.x - 1 and get_parent().position.x <= targetTest.x + 1 :
			motion.x = 0
		yaxis = get_parent().position.direction_to(target.position).y
		motion.y =  yaxis * acceleration
		motion.y = clamp(motion.y, -maxHorizontalSpeed, maxHorizontalSpeed)
	else:
		#has a slight margin of error as when trying to be exact caused some strange behaviour if the collider
		#of the enemy ran into the collider of the player
		if get_parent().position.x >= startPos.x - 1 and get_parent().position.x <= startPos.x + 1 :
			motion.x = 0
		else:
			xaxis = xRound(get_parent().position.direction_to(startPos).x) #gets the direction of the enemy to the start position
			if xaxis != 0:
				get_parent().sprite.scale.x = xaxis* startRotation
			motion.x =  xaxis * acceleration
			motion.x = clamp(motion.x, -maxHorizontalSpeed/2, maxHorizontalSpeed/2)
		if get_parent().position.y >= startPos.y - 1 and get_parent().position.y <= startPos.y + 1 :
			motion.y = 0
		else:
			yaxis = xRound(get_parent().position.direction_to(startPos).y)
			motion.y =  yaxis * acceleration
			motion.y = clamp(motion.y, -maxHorizontalSpeed/2, maxHorizontalSpeed/2)

	return motion

#Movement used for patroller
#move in a straight line, if collides with a wall or an edge then turn around
#and move in the other direction
func patrol(var delta):
	motion.y += gravity * delta
	motion.x =  get_parent().direction * acceleration
	motion.x = clamp(motion.x, -maxHorizontalSpeed +20, maxHorizontalSpeed -20 )
	if !get_parent().onFloor.is_colliding() or get_parent().onWall.is_colliding():
		get_parent().direction *= -1
		get_parent().scale.x *= -1
	return motion

#used for rounding numbers to 1 or -1
func xRound(var number):
	if number > 0:
		return 1
	if number < 0:
		return -1
	if number == 0:
		return 0
