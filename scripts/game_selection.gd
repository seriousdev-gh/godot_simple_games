extends Control

func _on_launch_tetris_pressed():
	get_tree().change_scene_to_file("games/tetris/game.tscn")

func _on_launch_snake_pressed():
	get_tree().change_scene_to_file("games/snake/game.tscn")

func _on_launch_space_shooter_pressed():
	get_tree().change_scene_to_file("games/space_shooter/game.tscn")
