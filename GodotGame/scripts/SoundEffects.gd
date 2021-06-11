extends Node2D

func playSoundEffect(sound):
	if get_node(sound):
		get_node(sound).play()

func stopSoundEffect(sound):
	if get_node(sound):
		get_node(sound).stop()
