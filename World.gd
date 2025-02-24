extends Node3D

@export var spawn_cup: PackedScene = preload("res://cup.tscn") # Reference to the Cup scene
@export var spawn_dice: PackedScene = preload("res://Dice.tscn") # Reference to the Dice scene


# TextureRect references for dice
@onready var texture_rect_1 = $CanvasLayer/TextureRect1
@onready var texture_rect_2 = $CanvasLayer/TextureRect2
@onready var texture_rect_3 = $CanvasLayer/TextureRect3
@onready var texture_rect_4 = $CanvasLayer/TextureRect4
@onready var texture_rect_5 = $CanvasLayer/TextureRect5

# Label references for results
@onready var result_label1 = $CanvasLayer/Label1
@onready var result_label2 = $CanvasLayer/Label2
@onready var result_label3 = $CanvasLayer/Label3
@onready var result_label4 = $CanvasLayer/Label4
@onready var result_label5 = $CanvasLayer/Label5

# Dice / selecting dice array
var dice_array = []
var selected_dice = [] # Array to track selected dice

# Roll logic
var first_roll = true  # Flag to check if it's the first roll
var rolls_left = 3  # Player starts with 3 rolls

# Dice images dictionary
var dice_images = {
	1: preload("res://Assets/DiceIcons/JackIcon.png"),
	2: preload("res://Assets/DiceIcons/AceIcon.png"),
	3: preload("res://Assets/DiceIcons/KingIcon.png"),
	4: preload("res://Assets/DiceIcons/TenIcon.png"),
	5: preload("res://Assets/DiceIcons/NineIcon.png"),
	6: preload("res://Assets/DiceIcons/QueenIcon.png"),
}

# Add dice to the dice array
func add_dice(dice_instances: Array):
	dice_array += dice_instances  # Add new dice instances to the array

# Called when the scene is ready
func _ready():
	# Instantiate the cup
	var cup_instance = spawn_cup.instantiate()    
	# Add the cup to the current scene (World node or any parent node)
	add_child(cup_instance)
	# Defer the transform change to after the node is inside the tree
	#cup_instance.call_deferred("set_position", Vector3(0, 0, 0))  # Set position for cup
	cup_instance.position = Vector3(-69, 34, 0)
	#Instantiate 5 dice and add them as children of the cup
	for i in range(1):
		var dice_instance = spawn_dice.instantiate()
		## Set positions for dice (you can modify this for random placement)
		##dice_instance.call_deferred("set_position", Vector3(i * 0.2, 0, 0))  # Adjust the position as needed
		#
		## Add each dice as a child of the cup
		add_child(dice_instance)
		dice_instance.position = Vector3(-80, 49,0)
	# Add the dice to the dice_array for later usage


	# Connect GUI events for texture rect clicks to select dice
	#texture_rect_1.connect("gui_input", Callable(self, "_on_texture_rect_input").bind(dice1, texture_rect_1))
	#texture_rect_2.connect("gui_input", Callable(self, "_on_texture_rect_input").bind(dice2, texture_rect_2))
	#texture_rect_3.connect("gui_input", Callable(self, "_on_texture_rect_input").bind(dice3, texture_rect_3))
	#texture_rect_4.connect("gui_input", Callable(self, "_on_texture_rect_input").bind(dice4, texture_rect_4))
	# texture_rect_5.connect("gui_input", Callable(self, "_on_texture_rect_input").bind(dice5, texture_rect_5))

# Function to handle input for selecting/deselecting dice
func _on_texture_rect_input(event: InputEvent, dice_node: RigidBody3D, texture_rect: TextureRect):
	if event is InputEventMouseButton and event.pressed:
		if selected_dice.has(dice_node):
			texture_rect.modulate = Color(1, 1, 1)  # Deselect and reset color
			selected_dice.erase(dice_node)
			print(dice_node.name, "deselected")
		else:
			texture_rect.modulate = Color(1, 0.8, 0)  # Highlight the dice in yellow
			selected_dice.append(dice_node)  # Add to selected dice
			print(dice_node.name, "selected")

# Handle the roll logic
func _input(event):
	if event.is_action_pressed("ui_accept"):  # Trigger the roll action (e.g., Enter or Space)
		if rolls_left > 0:  # Check if the player still has rolls left
			if first_roll:
				roll_all_dice()  # Roll all dice on the first roll
				first_roll = false  # Set the flag to false after the first roll
			else:
				roll_selected_dice()  # Roll only selected dice
			rolls_left -= 1  # Decrement rolls left after each roll
			print("Rolls left: ", rolls_left)
		else:
			print("No more rolls left!")  # If no rolls are left, show a message

# Function to roll all dice (for the first roll)
func roll_all_dice():
	get_tree().call_group("dice_group", "roll")

# Function to roll only the selected dice
func roll_selected_dice():
	for dice in selected_dice:
		if dice.has_method("roll"):  # Call roll method on dice instances
			dice.roll()

# Update the visual feedback for selected dice (e.g., change color to yellow when selected)
func _on_dice_1_roll_finished(value):
	texture_rect_1.texture = dice_images.get(value)
	result_label1.text = str(1)

func _on_dice_2_roll_finished(value):
	texture_rect_2.texture = dice_images.get(value)
	result_label2.text = str(2)

func _on_dice_3_roll_finished(value):
	texture_rect_3.texture = dice_images.get(value)
	result_label3.text = str(3)

func _on_dice_4_roll_finished(value):
	texture_rect_4.texture = dice_images.get(value)
	result_label4.text = str(4)

func _on_dice_5_roll_finished(value):
	texture_rect_5.texture = dice_images.get(value)
	result_label5.text = str(5)
