extends Control



	


# Called every frame. 'delta' is the elapsed time since the previous frame.



func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/table.tscn")
	


func _on_settings_pressed() -> void:
	print("Settings Pressed")


func _on_exit_pressed() -> void:
	get_tree().quit()
