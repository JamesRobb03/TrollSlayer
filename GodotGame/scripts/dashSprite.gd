extends Sprite

#when the player dashes it creates instances of this sprite
#this sets the opacity lower every frame and eventually it 
#is destroyed. used to create the dash animation
func _physics_process(delta):
	modulate.a = lerp(modulate.a,0,0.1)
	if modulate.a<0.01:
		queue_free()
