extends RigidBody3D

@onready var raycasts = $Raycasts.get_children()

var roll_strength = 175

signal roll_finished(value)

func ready():
	sleeping = false

func roll():
	# Wake the dice if they are sleeping
	
	# Reset velocities

	
	# Apply a random rotation to the dice
	transform.basis = Basis(Vector3.RIGHT, randf_range(0, 2 * PI)) * transform.basis
	transform.basis = Basis(Vector3.UP, randf_range(0, 2 * PI)) * transform.basis
	transform.basis = Basis(Vector3.FORWARD, randf_range(0, 2 * PI)) * transform.basis	
	# Apply a random throw impulse




func _on_sleeping_state_changed():
	if sleeping:
		for raycast in raycasts:
			if raycast.is_colliding():
				roll_finished.emit(raycast.opposite_side)
			
			
# Update this method to accept the value
func _on_roll_finished(value):
	print("Roll finished for ", self.name, " with value:", value)
	# Here, you can process the value (e.g., update the UI, show the result, etc.)
