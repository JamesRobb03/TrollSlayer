extends Button

func _on_resume_pressed():
	get_node("../../").visible = false
	Input.set_mouse_mode(1)
	get_tree().paused = false
