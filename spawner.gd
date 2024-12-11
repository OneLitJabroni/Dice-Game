extends Node

@export var dice_scene: PackedScene = preload("res://Dice.tscn")
@export var cup_scene: PackedScene = preload("res://cup.tscn")

func _ready():
	spawn_cup_and_dice()

func spawn_cup_and_dice():
	# Spawn the cup and add it to the world
	var cup = cup_scene.instantiate()
	add_child(cup)
	
	# Set cup's position (adjust as needed)
	cup.transform.origin = Vector3(0, 0, 0)
	
	# Spawn the dice inside the cup
	for i in range(5):  # For 5 dice
		var dice = dice_scene.instantiate()
		cup.add_child(dice)
		
		# Set a random position within the cup (optional)
		dice.transform.origin = Vector3(randf_range(-0.1, 0.1), 0.05, randf_range(-0.1, 0.1))
