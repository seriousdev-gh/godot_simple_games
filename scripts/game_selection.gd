extends Control

func _on_launch_tetris_pressed():
	get_tree().change_scene_to_file("scenes/game_tetris.tscn")

func _on_launch_snake_pressed():
	get_tree().change_scene_to_file("scenes/game_snake.tscn")
