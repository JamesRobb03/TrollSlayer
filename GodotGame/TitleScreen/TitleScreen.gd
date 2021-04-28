extends Control

func _ready():
	$Menu.visible = true
	$Options.visible = false
	$backButton.visible = false
	$animator.play("idle")
	Input.set_mouse_mode(0)
	if !Global.backgroundMusic.is_playing():
		if Global.bossMusic.is_playing():
			Global.bossMusic.stop()
		Global.backgroundMusic.play()


func _on_optionsButton_pressed():
	$Menu.visible = false
	$Options.visible = true
	$backButton.visible = true
	$Sprite.visible = false
	$PlayerSprite.visible = false



func _on_backButton_pressed():
	$Menu.visible = true
	$Options.visible = false
	$backButton.visible = false
	$Sprite.visible = true
	$PlayerSprite.visible = true

