extends Label

#updates death count
func _process(delta):
	text = "x"+str(Global.deathcount)
