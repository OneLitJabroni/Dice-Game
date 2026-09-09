extends Camera3D

@export var orbit_target: Node3D
@export var zoom_speed: float = 2.0
@export var rotate_speed: float = 0.005
@export var min_zoom: float = 5.0
@export var max_zoom: float = 50.0

var distance: float = 20.0
var yaw: float = 0.0
var pitch: float = 0.3
var dragging: bool = false
var last_touch_position: Vector2

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			dragging = true
			last_touch_position = event.position
		else:
			dragging = false
	
	if event is InputEventScreenDrag and dragging:
		var delta = event.position - last_touch_position
		yaw -= delta.x * rotate_speed
		pitch -= delta.y * rotate_speed
		pitch = clamp(pitch, -1.2, 1.2)
		last_touch_position = event.position
	
	if event is InputEventMagnifyGesture:
		distance -= (event.factor - 1.0) * zoom_speed * 10.0
		distance = clamp(distance, min_zoom, max_zoom)


func _process(_delta):
	if orbit_target and current:
		var offset = Vector3(
			cos(pitch) * sin(yaw),
			sin(pitch),
			cos(pitch) * cos(yaw)
		) * distance
		global_position = orbit_target.global_position + offset
		look_at(orbit_target.global_position, Vector3.UP)
