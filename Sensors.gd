extends Node
# Autoload named "Sensors". Drop-in replacement for Input.get_accelerometer(),
# Input.get_gravity() and Input.get_gyroscope() that also works in web exports.
# On web, values are remapped to match what Godot reports on Android.
 
var _web := false
 
func _ready() -> void:
	if OS.has_feature("web"):
		_web = true
		JavaScriptBridge.eval("""
			window._gdAccel = {x:0, y:0, z:0};
			window._gdGrav  = {x:0, y:0, z:0};
			window._gdGyro  = {x:0, y:0, z:0};
 
			// Rotate for screen orientation (like Godot does on Android),
			// then apply Godot's Android sign convention (-x, y, -z).
			function toGodot(x, y, z) {
				var ang = (screen.orientation && screen.orientation.angle) || 0;
				var rx = x, ry = y;
				if (ang === 90)       { rx = -y; ry =  x; }
				else if (ang === 180) { rx = -x; ry = -y; }
				else if (ang === 270) { rx =  y; ry = -x; }
				return {x: -rx, y: ry, z: z};
			}
 
			window.addEventListener('devicemotion', function (e) {
				var ag = e.accelerationIncludingGravity;
				var a  = e.acceleration;
				if (ag) {
					window._gdAccel = toGodot(ag.x || 0, ag.y || 0, ag.z || 0);
					if (a) {
						window._gdGrav = toGodot((ag.x || 0) - (a.x || 0),
												 (ag.y || 0) - (a.y || 0),
												 (ag.z || 0) - (a.z || 0));
					} else {
						window._gdGrav = window._gdAccel;
					}
				}
				var r = e.rotationRate;
				if (r) window._gdGyro = toGodot(r.beta || 0, r.gamma || 0, r.alpha || 0);
			});
		""", true)
 
func _read(name: String) -> Vector3:
	return Vector3(
		JavaScriptBridge.eval("window.%s.x" % name, true),
		JavaScriptBridge.eval("window.%s.y" % name, true),
		JavaScriptBridge.eval("window.%s.z" % name, true))
 
func get_accelerometer() -> Vector3:
	return _read("_gdAccel") if _web else Input.get_accelerometer()
 
func get_gravity() -> Vector3:
	return _read("_gdGrav") if _web else Input.get_gravity()
 
func get_gyroscope() -> Vector3:
	if _web:
		var g := _read("_gdGyro")
		return Vector3(deg_to_rad(g.x), deg_to_rad(g.y), deg_to_rad(g.z))
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
		
func lock_portrait() -> void:
	if _web:
		JavaScriptBridge.eval("""
			var el = document.documentElement;
			var p = el.requestFullscreen ? el.requestFullscreen() : Promise.resolve();
			p.then(function () {
				if (screen.orientation && screen.orientation.lock)
					return screen.orientation.lock('portrait');
			}).catch(function () {});
		""", true)
