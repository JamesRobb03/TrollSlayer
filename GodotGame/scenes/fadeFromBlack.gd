extends ColorRect

#OLD CODE NOT USED. was used to fade menu to black but ended up not liking how it looked
func _process(delta):
	color = lerp(color, Color(0,0,0,1), 0.1)
