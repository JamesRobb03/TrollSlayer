extends VBoxContainer

var volumeValue
var stopped = false
var bossStartVol
var backgroundStartVol

#setting up options menu
func _ready():
	backgroundStartVol = Global.startingVolumeBackground
	bossStartVol = Global.startingVolumeBoss
	$Resolution/OptionButton.connect("item_selected", self, "setRes")
	$Resolution/OptionButton.add_item("640 x 360", 0)
	$Resolution/OptionButton.add_item("1280 x 720", 1)
	$Resolution/OptionButton.add_item("1920 x 1080", 2)
	
	$Fullscreen/OptionButton.connect("item_selected", self, "setFullscreen")
	$Fullscreen/OptionButton.add_item("Fullscreen", 0)
	$Fullscreen/OptionButton.add_item("Windowed", 1)
	
	if Global.res_width == 640 and Global.res_height == 360:
		$Resolution/OptionButton.select(0)
	elif Global.res_width == 1280 and Global.res_height == 720:
		$Resolution/OptionButton.select(1)
	elif Global.res_width == 1920 and Global.res_height == 1080:
		$Resolution/OptionButton.select(2)
		
	if Global.fullscreen:
		$Fullscreen/OptionButton.select(0)
	else:
		$Fullscreen/OptionButton.select(1)

func setRes(item):
	#uses match statement to set the resolution in Global based off the selected
	#item
	match item:
		0:
			Global.res_width = 640
			Global.res_height = 360
			Global.resolution()
		1:
			Global.res_width = 1280
			Global.res_height = 720
			Global.resolution()
		2:
			Global.res_width = 1920
			Global.res_height = 1080
			Global.resolution()

func setFullscreen(item):
	#uses match statement to set if application is fullscreen in Global based off the selected
	#item
	match item:
		0:
			Global.fullscreen = true
			Global.resolution()
		1:
			Global.fullscreen = false
			Global.resolution()

#used to set the volume of the music
func _on_HSlider_value_changed(value):
	volumeValue = 100 - value
	if volumeValue == 100:
		Global.backgroundMusic.stop()
		Global.bossMusic.volume_db = 0 - volumeValue
		stopped = true
	else:
		if stopped:
			Global.backgroundMusic.play()
			stopped = false
		Global.backgroundMusic.volume_db = backgroundStartVol - volumeValue/2
		Global.bossMusic.volume_db = bossStartVol - volumeValue/2
