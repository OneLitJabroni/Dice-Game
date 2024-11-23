extends Node3D


@onready var result_label = $StaticBody3D/CanvasLayer/ResultLabel



func _on_die_roll_finished(value):
	result_label.text = str(value)
	
