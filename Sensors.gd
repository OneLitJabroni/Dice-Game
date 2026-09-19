extends Node
# Autoload named "Sensors". Drop-in replacement for Input.get_accelerometer(),
# Input.get_gravity() and Input.get_gyroscope() that also works in web exports.
# Assumes portrait orientation, locked at start — no dynamic angle remapping.

var _web := false
var _locked := false


func _ready() -> void:
	if OS.has_feature("web"):
		_web = true
		JavaScriptBridge.eval("""
			window._gdAccel = {x:0, y:0, z:0};
			window._gdGrav  = {x:0, y:0, z:0};
			window._gdGyro  = {x:0, y:0, z:0};

			// Portrait-only: no screen-orientation remapping.
			// Apply Godot's Android sign convention (-x, y, z).
			function toGodot(x, y, z) {
				return {x: -x, y: y, z: z};
			}

			window.addEventListener('devicemotion', function (e) {
				var ag = e.accelerationIncludingGravity;
				var a  = e.acceleration;
				if (ag) {
					window._gdAccel = toGodot(ag.x || 0, ag.y || 0, ag.z || 0);
					if (a) {
						window._gdGrav = toGodot(-((ag.x || 0) - (a.x || 0)),
												 -((ag.y || 0) - (a.y || 0)),
												 -((ag.z || 0) - (a.z || 0)));
					} else {
						window._gdGrav = toGodot(-(ag.x || 0), -(ag.y || 0), -(ag.z || 0));
					}
				}
				var r = e.rotationRate;
				if (r) window._gdGyro = toGodot(r.beta || 0, r.gamma || 0, r.alpha || 0);
			});
		""", true)


func _input(event: InputEvent) -> void:
	if _web and not _locked and event is InputEventScreenTouch and event.pressed:
		_locked = true
		JavaScriptBridge.eval("""
			var el = document.documentElement;
			var p = el.requestFullscreen ? el.requestFullscreen() : Promise.resolve();
			p.then(function () {
				if (screen.orientation && screen.orientation.lock)
					return screen.orientation.lock('portrait');
			}).catch(function () {});
		""", true)
		request_ios_permission()


func _read(prop: String) -> Vector3:
	return Vector3(
		JavaScriptBridge.eval("window.%s.x" % prop, true),
		JavaScriptBridge.eval("window.%s.y" % prop, true),
		JavaScriptBridge.eval("window.%s.z" % prop, true))


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
