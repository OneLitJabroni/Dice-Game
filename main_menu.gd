extends Control

@onready var dev_button: Button = $VBoxContainer/DevButton
@onready var multiplayer_button: Button = $VBoxContainer/MultiplayerButton

func _ready():
	dev_button.connect("pressed", Callable(self, "_on_dev_button_pressed"))
	multiplayer_button.connect("pressed", Callable(self, "_on_multiplayer_button_pressed"))

func _on_dev_button_pressed():
	get_tree().change_scene_to_file("res://Poker.tscn")

func _on_multiplayer_button_pressed():
	get_tree().change_scene_to_file("res://MultiplayerLobby.tscn")
