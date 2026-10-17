extends Node3D

@export var spawn_cup: PackedScene = preload("res://cup.tscn") # Reference to the Cup scene
@export var spawn_dice: PackedScene = preload("res://dice.tscn") # Reference to the Dice scene

@onready var cup_spawn_point: Marker3D = $CupSpawnPoint
@onready var reroll_button: Button = $CanvasLayer/VBoxContainer/Reroll
@onready var table_cam_button: Button = $CanvasLayer/VBoxContainer/TableCam  # adjust path
@onready var table_cam: Camera3D = $TableCam  # adjust path
@onready var player_cam: Camera3D = $PlayerCam  # your existing gesture-follow camera, adjust name/path



# TextureRect references for dice
@onready var texture_rect_1 = $CanvasLayer/VBoxContainer2/TextureRect1
@onready var texture_rect_2 = $CanvasLayer/VBoxContainer2/TextureRect2
@onready var texture_rect_3 = $CanvasLayer/VBoxContainer2/TextureRect3
@onready var texture_rect_4 = $CanvasLayer/VBoxContainer2/TextureRect4
@onready var texture_rect_5 = $CanvasLayer/VBoxContainer2/TextureRect5

const DEFAULT_FACE := preload("res://Assets/DiceIcons/yeetpoker_poker_die_1024.png")

@onready var face_rects: Array = [texture_rect_1, texture_rect_2, texture_rect_3, texture_rect_4, texture_rect_5]

@onready var debug_label: Label = $CanvasLayer/DebugLabel
# Label references for results
@onready var result_label1 = $CanvasLayer/DebugLabel
@onready var result_label2 = $CanvasLayer/Label2
@onready var result_label3 = $CanvasLayer/Label3
@onready var result_label4 = $CanvasLayer/Label4
@onready var result_label5 = $CanvasLayer/Label5

# Dice / selecting dice array
var dice_array: Array = []
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



# Called when the scene is ready
func _ready():
	
		# ... existing connections
	table_cam_button.connect("pressed", Callable(self, "_on_table_cam_pressed"))


	# Instantiate the cup
	var cup_instance = spawn_cup.instantiate()
	cup_instance.spawn_position = cup_spawn_point.position
	add_child(cup_instance)



	print("Cup position set to spawn point: ", cup_instance.global_position)
	
	for i in range(5):
		var dice_instance = spawn_dice.instantiate()
		print("Instantiated dice - script attached: ", dice_instance.get_script())
		if dice_instance.has_method("_ready"):
			print("Die has _ready method")
		else:
			print("Die does NOT have _ready method")
		dice_instance.add_to_group("dice_group")
		dice_array.append(dice_instance)

		# Arrange dice in a small circle pattern
		var angle = (TAU / 5) * i
		var radius = 1.2  # tune based on your cup's interior size
		var circle_offset = Vector3(cos(angle) * radius, 0, sin(angle) * radius)
		var height_offset = Vector3(0, 5 + (i * 2.0), 0)  # staggered drop height

		add_child(dice_instance)
		dice_instance.position = cup_instance.position + circle_offset + height_offset
		
		
	reroll_button.connect("pressed", Callable(self, "_on_reroll_pressed"))

	# Allows dice gui to be selectable by touch
	texture_rect_1.connect("gui_input", Callable(self, "_on_texture_rect_input").bind(dice_array[0], texture_rect_1))
	texture_rect_2.connect("gui_input", Callable(self, "_on_texture_rect_input").bind(dice_array[1], texture_rect_2))
	texture_rect_3.connect("gui_input", Callable(self, "_on_texture_rect_input").bind(dice_array[2], texture_rect_3))
	texture_rect_4.connect("gui_input", Callable(self, "_on_texture_rect_input").bind(dice_array[3], texture_rect_4))
	texture_rect_5.connect("gui_input", Callable(self, "_on_texture_rect_input").bind(dice_array[4], texture_rect_5))
	
	dice_array[0].connect("roll_finished", Callable(self, "_on_dice_1_roll_finished"))
	dice_array[1].connect("roll_finished", Callable(self, "_on_dice_2_roll_finished"))
	dice_array[2].connect("roll_finished", Callable(self, "_on_dice_3_roll_finished"))
	dice_array[3].connect("roll_finished", Callable(self, "_on_dice_4_roll_finished"))
	dice_array[4].connect("roll_finished", Callable(self, "_on_dice_5_roll_finished"))
	
	reset_faces()
	
	
func reset_faces() -> void:
	for rect in face_rects:
		rect.texture = DEFAULT_FACE


func _on_table_cam_pressed():
	
	if debug_label:
		var g = Sensors.get_gravity()
		debug_label.text = "gravity: (%.2f, %.2f, %.2f)" % [g.x, g.y, g.z]
	
	
	if table_cam.current:
		player_cam.current = true
		table_cam_button.text = "Table Cam"
	else:
		table_cam.current = true
		table_cam_button.text = "Player Cam"

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
				first_roll = false  # Set the flag to false after the first roll
			else:
				roll_selected_dice()  # Roll only selected dice
			rolls_left -= 1  # Decrement rolls left after each roll
			print("Rolls left: ", rolls_left)
		else:
			print("No more rolls left!")  # If no rolls are left, show a message


# Function to roll only the selected dice
func roll_selected_dice():
	print("roll_selected_dice called, selected count: ", selected_dice.size())
	print("cup_spawn_point position: ", cup_spawn_point.position)

	var i = 0
	for die in selected_dice:
		var angle = (TAU / selected_dice.size()) * i
		var radius = 1.2
		var circle_offset = Vector3(cos(angle) * radius, 0, sin(angle) * radius)
		var height_offset = Vector3(0, 1 + (i * 0.5), 0)
		
		die.freeze = false
		die.sleeping = false
		die.linear_velocity = Vector3.ZERO
		die.angular_velocity = Vector3.ZERO
		die.global_position = cup_spawn_point.position + circle_offset + height_offset
		
		i += 1
	
	# Clear selection highlighting after reroll
	# Clear highlight and show the default icon for dice going back in the cup
	for die in selected_dice:
		var index = dice_array.find(die)
		if index != -1:
			face_rects[index].modulate = Color(1, 1, 1)
			face_rects[index].texture = DEFAULT_FACE
	selected_dice.clear()


func _on_reroll_pressed():
	if rolls_left > 0:
		roll_selected_dice()
		rolls_left -= 1
		print("Rolls left: ", rolls_left)
	else:
		print("No more rolls left!")


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
