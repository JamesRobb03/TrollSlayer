extends KinematicBody2D

var startPos = Vector2.ZERO

#0 = up, 1 = down
var moveDir = 0 
var currentPos = Vector2.ZERO

signal onPlatform(isOnPlatform)

export var movespeed = 0.2
export var moveLength = 80

export var moveY = true

func _ready():
	startPos = get_position()

func _physics_process(delta):
	platformMovement()

func platformMovement():
	currentPos = get_position()
	#move on Y
	if moveY:
		if moveDir == 0:
			if currentPos.y <= (startPos.y-moveLength): #or is colliding with an object
				moveDir = 1
			else:
				#move platform
				position.y += -movespeed
		#going down
		else:
			if currentPos.y >= startPos.y+moveLength: #or is colliding with an object
				moveDir = 0
			else:
				#move platform
				position.y += movespeed
	#Move on X
	else:
		if moveDir == 0:
			if currentPos.x <= (startPos.x-moveLength): #or is colliding with an object
				moveDir = 1
			else:
				#move platform
				position.x += -movespeed
		#going down
		else:
			if currentPos.x >= startPos.x+moveLength: #or is colliding with an object
				moveDir = 0
			else:
				#move platform
				position.x += movespeed

func _on_playerOnPlatform_body_entered(body):
	if body.name == "Player":
		emit_signal("onPlatform", true)


func _on_playerOnPlatform_body_exited(body):
	if body.name == "Player":
		emit_signal("onPlatform", false)
