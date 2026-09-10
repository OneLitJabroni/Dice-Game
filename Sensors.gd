extends Node
# Add as an Autoload named "Sensors" (Project > Project Settings > Autoload).
# Then replace Input.get_accelerometer() with Sensors.get_accelerometer()
# and Input.get_gyroscope() with Sensors.get_gyroscope() in your cup script.
 
var _web := false
 
func _ready() -> void:
	if OS.has_feature("web"):
		_web = true
		JavaScriptBridge.eval("""
			window._gdAccel = {x:0, y:0, z:0};
			window._gdGyro  = {x:0, y:0, z:0};
			window.addEventListener('devicemotion', function (e) {
				var a = e.accelerationIncludingGravity;
				if (a) window._gdAccel = {x: a.x || 0, y: a.y || 0, z: a.z || 0};
				var r = e.rotationRate;
				if (r) window._gdGyro = {x: r.beta || 0, y: r.gamma || 0, z: r.alpha || 0};
			});
		""", true)
 
func get_accelerometer() -> Vector3:
	if _web:
		return Vector3(
			JavaScriptBridge.eval("window._gdAccel.x", true),
			JavaScriptBridge.eval("window._gdAccel.y", true),
			JavaScriptBridge.eval("window._gdAccel.z", true))
	return Input.get_accelerometer()
 
func get_gyroscope() -> Vector3:
	if _web:
		# Browser gives degrees/sec; Godot uses radians/sec.
		return Vector3(
			deg_to_rad(JavaScriptBridge.eval("window._gdGyro.x", true)),
			deg_to_rad(JavaScriptBridge.eval("window._gdGyro.y", true)),
			deg_to_rad(JavaScriptBridge.eval("window._gdGyro.z", true)))
	return Input.get_gyroscope()
 
# iOS Safari only: must be called from a tap/click before sensors work.
func request_ios_permission() -> void:
	if _web:
		JavaScriptBridge.eval("""
			if (typeof DeviceMotionEvent !== 'undefined' &&
				typeof DeviceMotionEvent.requestPermission === 'function') {
				DeviceMotionEvent.requestPermission();
			}
		""", true)
 
