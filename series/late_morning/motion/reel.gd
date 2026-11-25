extends Node3D

const LENGTH := 48.0
const PLAYBACK_SCALE := 1.4
const REAL_LENGTH := LENGTH * PLAYBACK_SCALE
const SHOTS := [
	# Time, camera start/end, look start/end, vertical field of view.
	[0.0, [.04,-2.16,.89], [.19,-1.87,1.02], [.03,2.53,1.48], [.15,2.48,1.42], 58.0],
	[1.35, [.18,-1.87,1.03], [-.24,-1.67,1.42], [.18,2.48,1.44], [-1.10,-2.05,.57], 63.0],
	[2.65, [-.78,-1.52,1.13], [-.80,-1.61,.98], [-1.02,-2.02,.57], [-1.02,-2.02,.58], 27.0],
	[4.50, [-.20,-1.83,1.29], [-.81,-1.53,1.11], [-1.04,-2.02,.56], [-1.19,-1.96,.57], 54.0],
	[5.75, [-1.58,-1.50,.80], [-1.53,-1.56,.51], [-1.24,-1.94,.60], [-1.28,-1.75,.44], 47.0],
	[6.66, [-1.58,-1.49,.36], [-1.52,-1.43,.20], [-1.27,-1.74,.39], [-1.21,-1.53,.05], 48.0],
	[7.36, [-1.53,-1.78,.15], [-1.52,-1.65,.18], [-1.21,-1.47,.05], [-1.14,-1.49,.04], 50.0],
	[9.30, [-1.56,-1.60,.22], [-1.71,-1.41,.68], [-1.16,-1.54,.03], [-.10,2.53,1.42], 55.0],
	[10.68, [-1.51,-1.17,1.54], [.34,1.70,1.61], [.26,2.45,1.48], [1.10,18.0,-.47], 62.0],
	[13.18, [.40,1.99,1.58], [.38,2.18,1.47], [3.12,14.20,-1.30], [3.73,13.68,-1.43], 48.0],
	[14.58, [1.13,9.45,.68], [1.72,11.22,.78], [2.15,15.74,.53], [2.15,15.74,.54], 31.0],
	[15.97, [-2.81,6.87,.69], [-1.19,7.28,.30], [4.40,10.26,-1.74], [4.29,10.01,-1.75], 53.0],
	[18.18, [2.42,7.27,-.77], [3.50,8.05,-1.21], [3.86,9.31,-1.80], [4.28,9.54,-1.53], 52.0],
	[21.25, [105.22,-2.46,1.58], [105.00,.75,1.58], [105.01,1.75,1.47], [104.89,2.60,1.55], 61.0],
	[23.58, [105.28,.84,1.54], [105.18,1.48,1.57], [105.10,2.46,1.40], [105.46,4.60,1.36], 54.0],
	[25.56, [105.23,2.06,1.50], [105.54,3.11,1.47], [105.60,4.52,1.01], [105.38,4.52,.96], 49.0],
	[27.76, [105.33,3.80,1.15], [105.29,4.02,1.00], [105.16,4.52,.89], [105.18,4.50,.90], 32.0],
	[30.00, [105.11,2.88,1.56], [105.42,2.12,1.55], [105.38,4.49,1.04], [104.97,1.40,1.38], 60.0],
	[31.95, [-.15,13.95,-.60], [.47,16.38,-1.23], [.74,17.52,-1.98], [.88,17.52,-1.93], 57.0],
	[34.05, [.39,16.18,-1.32], [.80,16.61,-1.74], [.86,17.34,-1.93], [.88,17.35,-1.89], 48.0],
	[36.18, [.07,17.23,-1.53], [.49,14.79,-1.58], [1.05,16.99,-2.16], [2.16,13.58,-2.13], 62.0],
	[38.30, [.64,14.93,-1.59], [1.95,11.34,-1.55], [2.30,13.58,-2.18], [3.34,10.60,-2.17], 59.0],
	[40.40, [1.18,10.98,-1.43], [.98,8.60,-1.48], [2.17,9.51,-2.04], [2.23,8.13,-2.11], 60.0],
	[42.58, [1.53,7.04,-1.35], [1.62,7.08,-1.31], [2.97,8.79,-1.99], [3.16,8.84,-1.94], 62.0],
	[44.10, [4.54,9.72,-1.40], [4.70,9.72,-1.41], [5.14,9.88,-1.61], [5.15,9.89,-1.61], 55.0],
	[46.14, [4.76,9.75,-1.44], [4.82,9.76,-1.45], [5.15,9.87,-1.61], [5.15,9.87,-1.61], 48.0],
]

var t := 0.0
var capture := false
var playing := true
var set_root: Node3D
var camera: Camera3D
var cup: Node3D
var spill: Node3D
var phone: Node3D
var door: Node3D
var dog_head: Node3D
var dog_tail: Node3D
var dog: Node3D
var alarm_clock: Node3D
var red: MeshInstance3D
var green: MeshInstance3D
var lit_red: StandardMaterial3D
var lit_green: StandardMaterial3D
var lens_off: StandardMaterial3D
var phone_surface: MeshInstance3D
var phone_glow: StandardMaterial3D
var phone_letters: Array[Node3D] = []
var hud: ReelHud
var audio_player: AudioStreamPlayer
var lead_segments: Array[MeshInstance3D] = []
var dog_legs: Array[Array] = []


func _ready() -> void:
	capture = OS.get_cmdline_user_args().has("--capture")
	var packed := load("res://set.glb") as PackedScene
	if packed == null:
		push_error("The Sand3D scene export is missing.")
		get_tree().quit(2)
		return
	set_root = packed.instantiate() as Node3D
	add_child(set_root)
	cup = prop("ReelCup")
	spill = prop("SpillRig")
	phone = prop("PhoneRig")
	door = prop("DoorRig")
	dog_head = prop("DogHeadRig")
	dog_tail = prop("DogTailRig")
	dog = prop("DogRig")
	if dog:
		build_dog_legs()
	alarm_clock = prop("AlarmClock")
	red = prop("SignalRed") as MeshInstance3D
	green = prop("SignalGreen") as MeshInstance3D
	phone_surface = prop("PhoneScreen") as MeshInstance3D
	for item in ["PhoneTime", "PhoneDay", "PhoneLock"]:
		phone_letters.append(prop(item))
	lit_red = light_material(Color("#fe4123"), 1.9)
	lit_green = light_material(Color("#43fa91"), 1.8)
	lens_off = light_material(Color("#343c37"), 0.0)
	phone_glow = light_material(Color("#315270"), 0.25)
	if phone_surface:
		phone_surface.material_override = phone_glow
	build_lights()
	camera = Camera3D.new()
	camera.near = 0.013
	camera.far = 130
	camera.keep_aspect = Camera3D.KEEP_HEIGHT
	add_child(camera)
	camera.current = true
	var lead_color := light_material(Color("#8c5541"), 0.0)
	for i in range(2):
		var lead := MeshInstance3D.new()
		var strand := CylinderMesh.new()
		strand.height = 1
		strand.top_radius = .009
		strand.bottom_radius = .009
		strand.radial_segments = 6
		lead.mesh = strand
		lead.material_override = lead_color
		add_child(lead)
		lead_segments.append(lead)
	var overlay := CanvasLayer.new()
	add_child(overlay)
	hud = ReelHud.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(hud)
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	if not capture and ResourceLoader.exists("res://mix.wav"):
		audio_player.stream = load("res://mix.wav") as AudioStream
		audio_player.play()
	apply_time()


func prop(label: String) -> Node3D:
	var result := set_root.find_child(label, true, false) as Node3D
	if result == null:
		push_warning("Scene prop missing: " + label)
	return result


func light_material(color: Color, power: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = .48
	material.emission_enabled = power > 0
	material.emission = color
	material.emission_energy_multiplier = power
	return material


func lamp(where: Vector3, color: Color, strength: float, radius: float) -> void:
	var node := OmniLight3D.new()
	add_child(node)
	node.global_position = where
	node.light_color = color
	node.light_energy = strength
	node.omni_range = radius


func build_lights() -> void:
	var world_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#8dabc0")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#d3deeb")
	env.ambient_light_energy = .59
	world_node.environment = env
	add_child(world_node)
	var sun := DirectionalLight3D.new()
	add_child(sun)
	sun.rotation_degrees = Vector3(-28, -18, 0)
	sun.light_color = Color("#ffe1ad")
	sun.light_energy = 1.05
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 30
	lamp(v([-.5,-1.2,2.3]), Color("#b3d3ff"), .42, 5.0)
	lamp(v([.2,2.16,1.88]), Color("#fff0b5"), .63, 4.7)
	lamp(v([105.10,-.66,2.42]), Color("#edbd77"), .75, 4.4)
	lamp(v([105.52,4.0,2.46]), Color("#ffe2ad"), .84, 5.4)


func v(xyz: Array) -> Vector3:
	return Vector3(xyz[0], xyz[2], -xyz[1])


func build_dog_legs() -> void:
	var fur := light_material(Color("#b18a60"), 0.0)
	var paw_color := light_material(Color("#ccb08b"), 0.0)
	for leg in range(4):
		var parts: Array[MeshInstance3D] = []
		for section in range(3):
			var segment := MeshInstance3D.new()
			var shape := SphereMesh.new()
			shape.radius = .5
			shape.height = 1
			shape.radial_segments = 10
			shape.rings = 5
			segment.mesh = shape
			segment.material_override = paw_color if section == 2 else fur
			dog.add_child(segment)
			parts.append(segment)
		dog_legs.append(parts)


func pose_dog_legs(distance: float, walking: bool) -> void:
	for index in range(dog_legs.size()):
		var front := index < 2
		var side := -1.0 if index % 2 == 0 else 1.0
		var period_offset: float = [0.0, .5, .74, .24][index]
		var phase := fposmod(distance / .62 + period_offset, 1.0)
		var stride := 0.0
		var lift := 0.0
		if walking:
			if phase < .60:
				stride = lerpf(.186, -.186, phase / .60)
			else:
				var swing := (phase - .60) / .40
				stride = lerpf(-.186, .186, smoothstep(0.0, 1.0, swing))
				lift = pow(sin(swing * PI), 1.1) * .095
		var hip := Vector3(side * .107, .343, .171 if front else -.149)
		var paw := Vector3(side * .113, .045 + lift, (.192 if front else -.156) + stride)
		var line := paw - hip
		var bend := Vector3(0, line.z, -line.y).normalized() * (-1 if front else 1)
		var joint := (hip + paw) * .5 + bend * sqrt(maxf(.0004, .185 ** 2 - line.length_squared() * .25))
		var parts: Array = dog_legs[index]
		pose_leg_segment(parts[0], hip, joint, .11 if front else .14)
		pose_leg_segment(parts[1], joint, paw, .076)
		parts[2].position = paw + Vector3(0, 0, .024)
		parts[2].scale = Vector3(.087, .069, .128)


func pose_leg_segment(segment: MeshInstance3D, start: Vector3, finish: Vector3, width: float) -> void:
	var movement := finish - start
	segment.position = (start + finish) * .5
	segment.quaternion = Quaternion(Vector3.UP, movement.normalized())
	segment.scale = Vector3(width, movement.length() + .073, width)


func position_lead() -> void:
	var visible_now := dog != null and t >= 31.95 and t < 41.92
	for strand in lead_segments:
		strand.visible = visible_now
	if not visible_now:
		return
	var collar := dog.to_global(Vector3(0, .49, .105))
	var grip := v([1.59,17.82,-1.81]) if t < 35.85 else camera.to_global(Vector3(.21,-.27,-.34))
	var middle := collar.lerp(grip,.52) + Vector3.DOWN * (.10 if t < 36.2 else .032)
	var points := [collar, middle, grip]
	for i in range(lead_segments.size()):
		var strand := lead_segments[i]
		var from: Vector3 = points[i]
		var to: Vector3 = points[i + 1]
		var shift := to - from
		strand.position = (from + to) * .5
		strand.quaternion = Quaternion(Vector3.UP, shift.normalized())
		strand.scale = Vector3(1, maxf(.001, shift.length()), 1)


func _unhandled_key_input(event: InputEvent) -> void:
	if capture or not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_SPACE:
		playing = not playing
		audio_player.stream_paused = not playing
	elif event.keycode == KEY_R:
		t = 0
		playing = true
		if audio_player.stream:
			audio_player.play()
	elif event.keycode == KEY_ESCAPE:
		get_tree().quit()


func _process(delta: float) -> void:
	if playing:
		t += delta / PLAYBACK_SCALE
	if t >= LENGTH:
		if capture:
			get_tree().quit()
			return
		t = LENGTH
		playing = false
		audio_player.stop()
	apply_time()


func apply_time() -> void:
	var index := 0
	while index + 1 < SHOTS.size() and t >= float(SHOTS[index + 1][0]):
		index += 1
	var shot: Array = SHOTS[index]
	var stop := LENGTH if index + 1 == SHOTS.size() else float(SHOTS[index + 1][0])
	var elapsed := t - float(shot[0])
	var fraction := clampf(elapsed / (stop - float(shot[0])), 0, 1)
	var phase := smoothstep(0.0, 1.0, fraction)
	var impact := maxf(0, t - 7.34)
	var jolt := sin(52 * impact) * exp(-13 * impact) * .037 if t >= 7.34 else 0.0
	var sprint := .018 if index == 8 or index == 13 or index == 18 else .003
	var sway := Vector3(sin(t * 12) * sprint, sin(t * 19) * sprint + jolt, 0)
	camera.global_position = v(shot[1]).lerp(v(shot[2]), phase) + sway
	var target := v(shot[3]).lerp(v(shot[4]), phase)
	camera.look_at(target, Vector3.UP)
	camera.rotation.z += .015 * sin(t * 4.1) + jolt
	camera.fov = float(shot[5]) + 2.2 * sin(PI * fraction)

	var light_up := smoothstep(2.62, 2.90, t)
	phone_glow.albedo_color = Color("#111c23").lerp(Color("#315873"), light_up)
	phone_glow.emission_energy_multiplier = light_up * .25
	for letter in phone_letters:
		if letter:
			letter.visible = t >= 2.76
	if phone:
		phone.position = v([-1.02,-2.02,.558]) + Vector3(.014 * sin(140 * (t - 2.88)) * exp(-5.0 * absf(t - 2.88)) if t >= 2.88 and t <= 3.5 else 0.0, 0, 0)

	if cup:
		if t < 5.69:
			cup.position = v([-1.245,-1.955,.547])
			cup.rotation = Vector3.ZERO
		elif t < 6.65:
			var tip := smoothstep(5.69, 6.65, t)
			cup.position = v([-1.245,-1.955,.547]).lerp(v([-1.26,-1.81,.547]), tip)
			var overhang := smoothstep(.45, 1.0, tip)
			cup.rotation = Vector3(-.98 * overhang, .23 * overhang, -.12 * overhang)
		elif t < 7.34:
			var fall := clampf((t - 6.65) / .69, 0, 1)
			cup.position = v([-1.26,lerpf(-1.81,-1.52,fall),lerpf(.547,.046,fall * fall)])
			cup.rotation = Vector3(-.98 - 2.7 * fall, .23 + fall, -.12 + .94 * fall)
		else:
			var roll := smoothstep(0.0, .72, impact)
			cup.position = v([lerpf(-1.26,-1.13,roll),lerpf(-1.52,-1.31,roll),.044 + absf(sin(impact * 20)) * exp(-6.2 * impact) * .053])
			cup.rotation = Vector3(-PI / 2, .6 + 1.26 * roll, 2.72 * roll)
	if spill:
		spill.visible = t >= 7.34
		var spread := maxf(.01, smoothstep(7.34, 8.55, t))
		spill.scale = Vector3(spread, 1, spread)

	if red:
		red.material_override = lit_red if t < 15.20 else lens_off
	if green:
		green.material_override = lit_green if t >= 15.20 else lens_off
	if door:
		door.rotation.y = sin((t - 18.16) * 4.4) * exp(-.51 * maxf(t - 18.16, 0)) * .18 if t >= 18.16 else -.11
	if dog_head:
		dog_head.rotation.x = lerpf(-.12, .24, smoothstep(33.45, 34.80, t))
		dog_head.rotation.z = .14 * smoothstep(34.25, 35.70, t)
	if dog_tail:
		dog_tail.rotation.y = sin(t * 13.5) * .34
	if dog:
		var crossing := clampf((t - 35.85) / 5.86, 0, 1)
		var moving := crossing > 0 and crossing < 1
		var progress := lerpf(crossing, smoothstep(0, 1, crossing), .36)
		# Stay on the crosswalk in front of the car's bumper. Stop outside the door's swing.
		var x := lerpf(.88, 2.14, 1.0 - pow(1.0 - progress, 1.55))
		var y := lerpf(17.54, 8.06, progress)
		var floor_height := -2.49 - .05 * smoothstep(.12, .21, progress)
		floor_height += .046 * (1.0 - smoothstep(8.05, 8.46, y))
		dog.position = v([x, y, floor_height])
		var heading := atan2(1.26 * 1.55 * pow(1.0 - progress, .55), 9.48)
		var turn := smoothstep(41.1, 42.42, t)
		var turning := turn > 0 and turn < 1
		var forward := lerpf(-.12, heading, smoothstep(35.60, 36.27, t))
		dog.rotation.y = lerpf(forward, 1.44, turn)
		pose_dog_legs(progress * 9.63 + turn * .37, moving or turning)
		if dog_head:
			dog_head.rotation.y = .62 * turn
	position_lead()
	if alarm_clock:
		var alarm_active := t >= 42.95 and fposmod(t - 42.95, 1.15) < .53
		alarm_clock.rotation.z = sin(t * 100) * .012 if alarm_active else 0.0
	hud.time = t
	hud.preview = not capture
	hud.playing = playing
	hud.queue_redraw()


class ReelHud extends Control:
	var time := 0.0
	var preview := false
	var playing := true

	func lines(value: String, y: float, size_px: int, alpha: float = 1) -> void:
		var font := ThemeDB.fallback_font
		for line in value.split("\n"):
			var width := font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x
			var p := Vector2((size.x - width) * .5, y)
			draw_string_outline(font, p, line, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, 7, Color(0.025,0.03,0.04,alpha))
			draw_string(font, p, line, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, Color(1.0,.96,.85,alpha))
			y += size_px * 1.18

	func _draw() -> void:
		var opening := 1.0 - smoothstep(.05, .47, time)
		if time > .52 and time < .79:
			opening = maxf(opening, sin(PI * (time - .52) / .27) * .63)
		if opening > 0:
			var lid := size.y * opening * .5
			draw_rect(Rect2(0,0,size.x,lid), Color("#0d1117"))
			draw_rect(Rect2(0,size.y-lid,size.x,lid), Color("#0d1117"))
		if time >= .62 and time < 2.48:
			lines("WHEN I WOKE UP,\nTHE WORLD WAS GONE.", size.y * .66, 34, 1.0 - smoothstep(2.20,2.48,time))
		if time >= 23.85 and time < 25.13:
			lines("MARTIN?", size.y * .76, 32)
		if time >= 26.27 and time < 28.35:
			lines("THE RADIO WAS STILL ON.", size.y * .76, 27)
		if time >= 29.23 and time < 30.88:
			lines("THEN ANOTHER SONG STARTED.", size.y * .76, 25)
		if time >= 33.40 and time < 35.51:
			lines("I UNTIED HIM.", size.y * .76, 30)
		if time >= 37.73 and time < 40.18:
			lines("HE PULLED ME TOWARD THE CAR.", size.y * .76, 24)
		if time >= 45.42 and time < 47.62:
			lines("AN ALARM IN THE BACK SEAT.", size.y * .76, 27)
		var fade := smoothstep(47.39,47.97,time)
		if fade > 0:
			draw_rect(Rect2(Vector2.ZERO,size), Color(.027,.039,.050,fade))
		if preview:
			draw_rect(Rect2(0,0,size.x,45), Color(.018,.025,.037,.82))
			draw_rect(Rect2(0,42,size.x * clampf(time / LENGTH,0,1),3), Color("#e7a45c"))
			var state := "PLAYING" if playing else "PAUSED"
			var label := "LIVE REEL PREVIEW  •  %s  •  %04.1f / 67.2s" % [state, time * PLAYBACK_SCALE]
			draw_string(ThemeDB.fallback_font, Vector2(14,27), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#f5f0df"))
			draw_rect(Rect2(0,size.y-38,size.x,38),Color(.018,.025,.037,.76))
			draw_string(ThemeDB.fallback_font, Vector2(14,size.y-13), "SPACE  pause/play     R  replay     ESC  close", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#f5f0df"))
