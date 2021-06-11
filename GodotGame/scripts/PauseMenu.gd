extends Control

func _input(event):
	if event.is_action_pressed("ui_pause"):
		get_tree().paused = true
		visible = true
		if visible == true:
			Input.set_mouse_mode(0)

func _on_options_pressed():
	$Options.visible = true
	$Buttons.visible = false
	$backButton.visible = true


func _on_backButton_pressed():
	$Options.visible = false
	$Buttons.visible = true
	$backButton.visible = false
