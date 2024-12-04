extends Node3D


@onready var texture_rect_1 = $CanvasLayer/TextureRect1

@onready var texture_rect_2 = $CanvasLayer/TextureRect2

@onready var texture_rect_3 = $CanvasLayer/TextureRect3

@onready var texture_rect_4 = $CanvasLayer/TextureRect4

@onready var texture_rect_5 = $CanvasLayer/TextureRect5


var dice_images = {
	1: preload("res://Assets/DiceIcons/JackIcon.png"),
	2: preload("res://Assets/DiceIcons/AceIcon.png"),
	3: preload("res://Assets/DiceIcons/KingIcon.png"),
	4: preload("res://Assets/DiceIcons/TenIcon.png"),
	5: preload("res://Assets/DiceIcons/NineIcon.png"),
	6: preload("res://Assets/DiceIcons/QueenIcon.png"),
}








func _on_dice_1_roll_finished(value):
	texture_rect_1.texture = dice_images.get(value)


func _on_dice_2_roll_finished(value):
	texture_rect_2.texture = dice_images.get(value)


func _on_dice_3_roll_finished(value):
	texture_rect_3.texture = dice_images.get(value)


func _on_dice_4_roll_finished(value):
	texture_rect_4.texture = dice_images.get(value)


func _on_dice_5_roll_finished(value):
	texture_rect_5.texture = dice_images.get(value)
