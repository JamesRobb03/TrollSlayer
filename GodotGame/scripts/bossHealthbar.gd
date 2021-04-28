extends TextureProgress

#updates healthbar value
func _on_Boss_healthChange(health):
	value = health

#setting up of healthbar
func _on_Boss_bossMaxHealth(maxhealth):
	max_value = maxhealth
	value = max_value
