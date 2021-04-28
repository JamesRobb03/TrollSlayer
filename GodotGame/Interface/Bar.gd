extends HBoxContainer

#set value of bar to full
func _ready():
	$TextureProgress.value = 100

#when signal is sent update value amount to match health
func _on_interface_healthChanged(health):
	$TextureProgress.value = health
