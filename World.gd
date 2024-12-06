extends Node3D


@onready var dice1 = $Dice1
@onready var dice2 = $Dice2
@onready var dice3 = $Dice3
@onready var dice4 = $Dice4
@onready var dice5 = $Dice5


@onready var texture_rect_1 = $CanvasLayer/TextureRect1
@onready var texture_rect_2 = $CanvasLayer/TextureRect2
@onready var texture_rect_3 = $CanvasLayer/TextureRect3
@onready var texture_rect_4 = $CanvasLayer/TextureRect4
@onready var texture_rect_5 = $CanvasLayer/TextureRect5


@onready var result_label1 = $CanvasLayer/Label1
@onready var result_label2 = $CanvasLayer/Label2
@onready var result_label3 = $CanvasLayer/Label3
@onready var result_label4 = $CanvasLayer/Label4
@onready var result_label5 = $CanvasLayer/Label5




var dice_array = [dice1,dice2,dice3,dice4,dice5]
var selected_dice =  []
var first_roll = true  # Flag to check if it's the first roll
var rolls_left = 3  # Player starts with 3 rolls








var dice_images = {
	1: preload("res://Assets/DiceIcons/JackIcon.png"),
	2: preload("res://Assets/DiceIcons/AceIcon.png"),
	3: preload("res://Assets/DiceIcons/KingIcon.png"),
	4: preload("res://Assets/DiceIcons/TenIcon.png"),
	5: preload("res://Assets/DiceIcons/NineIcon.png"),
	6: preload("res://Assets/DiceIcons/QueenIcon.png"),
}




func _ready():
	texture_rect_1.connect("gui_input", Callable(self, "_on_texture_rect_input").bind(dice1, texture_rect_1))
	texture_rect_2.connect("gui_input", Callable(self, "_on_texture_rect_input").bind(dice2, texture_rect_2))
	texture_rect_3.connect("gui_input", Callable(self, "_on_texture_rect_input").bind(dice3, texture_rect_3))
	texture_rect_4.connect("gui_input", Callable(self, "_on_texture_rect_input").bind(dice4, texture_rect_4))
	texture_rect_5.connect("gui_input", Callable(self, "_on_texture_rect_input").bind(dice5, texture_rect_5))

	
	
	# Handle click on TextureRect and select corresponding dice
func _on_texture_rect_input(event: InputEvent, dice_instance: RigidBody3D, texture_rect: TextureRect):
	if event is InputEventMouseButton and event.pressed:
  # Retrieve the ColorRect child
		if selected_dice.has(dice_instance):
			texture_rect.modulate = Color(1, 1, 1)
			selected_dice.erase(dice_instance)
			print(dice_instance.name, "deselected")
		else:
			texture_rect.modulate = Color(1, 0.8, 0)  # Highlight the dice
			selected_dice.append(dice_instance)       # Add to selected dice
			print(dice_instance.name, "selected")
		# Highlight the selected TextureRect (optional visual feedback)



# The function that handles the input event to trigger the roll
func _input(event):
	if event.is_action_pressed("ui_accept"):  # Trigger the roll action (e.g., Enter or Space)
		if rolls_left > 0:  # Check if the player still has rolls left
			if first_roll:
				roll_all_dice()  # If it's the first roll, roll all dice
				first_roll = false  # Set the flag to false after the first roll
			else:
				roll_selected_dice()  # Roll only selected dice
			rolls_left -= 1  # Decrement rolls left after each roll
			print("Rolls left: ", rolls_left)
		else:
			print("No more rolls left!")  # If no rolls are left, show a message

# Function to roll all dice (for the first roll)
func roll_all_dice():
	for dice in dice_array:
		get_tree().call_group("dice_group", "roll")



# Function to roll only the selected dice
func roll_selected_dice():
	for dice in selected_dice:
		if dice.has_method("roll"):
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
