extends Node3D

@onready var result_label1 = $CanvasLayer/Label1
@onready var result_label2 = $CanvasLayer/Label2

func _on_dice_roll_finished(value):
	result_label1.text = str(value)
	


func _on_dice_2_roll_finished(value):
	result_label2.text = str(value)
	
