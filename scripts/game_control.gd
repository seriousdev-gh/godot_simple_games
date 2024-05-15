extends Control


func _on_menu_button_pressed():
	get_tree().change_scene_to_file("scenes/game_selection.tscn")


func _on_restart_button_pressed():
	get_tree().reload_current_scene()
