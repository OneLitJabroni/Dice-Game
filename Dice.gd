extends RigidBody3D

@onready var raycasts = $Raycasts.get_children()

var roll_strength = 175

signal roll_finished(value)

func ready():
	sleeping = false





func _on_sleeping_state_changed():
	if sleeping:
		for raycast in raycasts:
			if raycast.is_colliding():
				roll_finished.emit(raycast.opposite_side)
			
			
# Update this method to accept the value
func _on_roll_finished(value):
	print("Roll finished for ", self.name, " with value:", value)
	# Here, you can process the value (e.g., update the UI, show the result, etc.)
