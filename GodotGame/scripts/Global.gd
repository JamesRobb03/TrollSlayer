extends Node2D

#Global script which is instantiated alongside the game. Using godot's built in autoload the Global scene is ran alongside
#the other parts of the game so that it is constant through the whole game. This allows for the playing of constant background
#music, so that it is not interupted between scene switches or deaths. It also allows for updating checkpoints as the players position
#is then set depending on the spawn location held in the global script. which is updated when a player goes through a checkpoint. 
#In addition it allows for the user to edit the settings at anytime in the game.

var spawnpoint = Vector2(0,0) 
var checkpointCounter = 0
#variable which displays the amount of deaths the user has had on the UI 
var deathcount = 0

#level counter is a variable which is used when loading other levels. when a player collides with a coin
#the coin script then increases the level counter by 1 which then loads the next level
var levelCounter = 0

#variables for settings
var res_width = 1920
var res_height = 1080

var fullscreen = true

var startingVolumeBackground
var startingVolumeBoss

onready var backgroundMusic = $backgroundMusic
onready var bossMusic = $BossMusic

func _ready():
	startingVolumeBackground = backgroundMusic.volume_db 
	startingVolumeBoss = bossMusic.volume_db 
	backgroundMusic.play()
	resolution() #sets default resolution settings
	
func updateSpawn(checkpoint):
	spawnpoint = checkpoint
	checkpointCounter += 1

#set spawnpoint
func setSpawnpoint(var spawn):
	spawnpoint = spawn
	
func incDeathCount():
	deathcount += 1

#function which plays the boss music
func bossFight():
	if backgroundMusic.is_playing():
		backgroundMusic.stop()
		bossMusic.play()

#function which loads the next level depending on the level counter.
#resets checkpoint counter so that the Player is spawned at the starting location of the level.
func nextLevel():
	checkpointCounter = 0
	if levelCounter == 0:
		get_tree().change_scene("res://Level2.tscn")
	elif levelCounter == 1:
		get_tree().change_scene("res://scenes/level3.tscn")
	else:
		get_tree().change_scene("res://scenes/WinScreen.tscn")
	bossMusic.stop()
	backgroundMusic.play()
	levelCounter += 1

#function for updating the resolution 
func resolution():
	ProjectSettings.set_setting("display/window/size/test-width", res_width)
	ProjectSettings.set_setting("display/window/size/test-height", res_height)
	OS.set_window_size(Vector2(res_width, res_height))
	if fullscreen:
		OS.set_window_fullscreen(true)
	else:
		OS.set_window_fullscreen(false)
		OS.set_window_position(Vector2(0,0))

