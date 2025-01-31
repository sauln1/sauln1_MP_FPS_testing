extends Panel


func _on_resume_pressed():
	self.visible = false


func _on_main_menu_pressed():
	#disconnect from server game
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")


func _on_settings_pressed():
	pass # Replace with function body.


func _on_quit_pressed():
	get_tree().quit()
