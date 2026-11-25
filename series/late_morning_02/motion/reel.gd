extends Node3D

const DURATION := 90.0
# Absolute times, world or pickup space, camera start/end, target start/end and field of view.
const SHOTS := [
	[0,0,[-1.79,-2.65,0.92],[-1.64,-2.46,1.01],[-0.71,2.6,1.68],[-0.62,3.52,1.63],61],
	[2.6,0,[-0.32,-1.85,0.97],[-0.37,-2.01,0.87],[-0.81,-2.53,0.6],[-0.81,-2.53,0.6],29],
	[5.1,0,[1.04,-1.85,0.74],[1.45,-2.01,0.61],[2.28,-2.97,0.34],[2.28,-2.97,0.36],48],
	[8.05,0,[-1.68,-2.08,1.57],[-1.63,-1.87,1.43],[-1.87,-1.15,0.65],[-1.87,-1.15,0.65],42],
	[11.95,0,[4.54,9.72,-1.4],[4.75,9.75,-1.44],[5.14,9.88,-1.61],[5.15,9.88,-1.61],49],
	[14.6,0,[1.43,0.30,1.25],[1.48,0.37,1.25],[1.76,0.79,0.91],[1.8,0.62,1.15],45],
	[17,0,[1.11,0.32,1.4],[1.35,0.39,1.26],[1.57,0.86,0.76],[1.57,0.86,0.76],44],
	[19.65,0,[1.6,2.02,1.38],[1.7,2.19,1.32],[1.82,2.72,1.01],[1.85,2.72,0.98],37],
	[22.4,0,[-1.31,111.2,2.55],[-1.22,112.8,2.85],[-1.4,116.8,4.9],[-1.4,116.8,4.94],37],
	[24.9,0,[0.58,2.35,1.63],[0.56,2.98,1.65],[-12,154,8.5],[-15,154,8.3],35],
	[28.25,0,[-7.30,89,6.6],[-11.2,91,7.02],[-15,154,6.8],[-15,154,6.8],34],
	[32.4,0,[1.73,0.3,1.4],[1.66,0.32,1.34],[1.57,0.86,0.77],[1.57,0.86,0.77],35],
	[36,0,[0.94,0.1,1.22],[1.03,0.3,1.04],[1.36,0.57,0.77],[1.36,0.57,0.77],33],
	[39.2,1,[1.44,2.55,1.92],[1.45,2.18,1.62],[-0.22,1.4,0.86],[-0.22,1.4,0.86],49],
	[42.5,0,[5.22,106.54,1.21],[5.40,106.71,1.20],[5.67,108.04,0.38],[6.36,108.04,0.42],58],
	[45.28,1,[1.76,0.43,1.69],[1.47,0.32,1.65],[0.44,-0.11,1.48],[0.44,-0.10,1.49],48],
	[46.02,1,[-0.10,-0.24,1.55],[-0.11,-0.17,1.48],[0.018,0.31,0.96],[0.018,0.31,0.96],41],
	[46.65,0,[-1.55,124.3,0.64],[-1.67,124.5,0.76],[1.62,127,0.94],[1.62,139,0.91],64],
	[48.8,2,[-0.35,-2.82,1.31],[-0.30,-2.85,1.35],[1.25,166.8,5.63],[1.25,166.8,5.68],61],
	[50.34,1,[-3.9,5.3,2.5],[-2.97,4.1,2.23],[0,0,1.1],[0,-1.08,1.3],62],
	[53.08,1,[-0.36,-0.2,1.54],[-0.33,-0.24,1.47],[0.36,-0.52,1.25],[0.36,-0.52,1.25],39],
	[55.15,0,[2.1,240.2,1.47],[3.5,241.1,1.83],[5.65,244.64,4.18],[5.65,244.6,4.05],55],
	[57.2,1,[-3.95,4.9,2.82],[-2.7,5.16,2.85],[0.24,-2.6,1.15],[0.56,-3.4,1.57],59],
	[59.1,0,[17.65,247.5,2.45],[16.1,249.22,1.88],[14.4,255.78,2.42],[14.3,254.3,2.09],64],
	[61.65,0,[13.63,252.11,1.63],[13.84,252.44,1.44],[14.2,253.276,1.24],[14.2,253.276,1.24],39],
	[64,0,[15.24,251.96,1.57],[15.08,252.13,1.44],[14.65,253.37,1.04],[14.74,252.89,1.06],42],
	[67.08,0,[15,254.21,1.59],[15.39,257.78,1.58],[15.43,259.82,1.41],[15.5,259.88,1.54],60],
	[70,0,[15.83,258.72,1.53],[15.83,259.58,1.51],[15.39,260.56,1.31],[15.83,262.85,1.36],56],
	[72.12,0,[15.79,260.33,1.51],[15.86,261.79,1.54],[14.96,264.9,1.39],[13.81,265.31,1.22],63],
	[75,0,[15.91,262.46,1.55],[14.81,262.83,1.43],[14.24,265.29,1.35],[13.45,265.27,1.26],57],
	[77.34,0,[15.63,262.11,1.54],[16.22,262.57,1.49],[18,262,1.15],[17.29,263.57,1.23],53],
	[80,0,[16.32,262.66,1.57],[16.73,262.98,1.55],[17.1,263.73,1.29],[17.15,263.64,1.22],53],
	[82.6,0,[16.99,263.13,1.77],[17.11,263.26,1.69],[17.29,263.61,1.18],[17.31,263.57,1.2],45],
	[85.25,0,[17.27,263.30,1.88],[17.28,263.33,1.79],[17.31,263.54,1.2],[17.31,263.54,1.2],47],
	[88,1,[1.52,0.24,1.55],[1.3,0.08,1.6],[0.44,0.06,1.37],[0.44,0.06,1.47],50],
]
var clock := 0.0
var shot := 0
var recording := false
var playing := true
var scenery: Node3D
var camera: Camera3D
var pickup: Node3D
var dog: Node3D
var head: Node3D
var tail: Node3D
var keys: Node3D
var water: Node3D
var noon: Node3D
var flashback_set: Node3D
var memory_alarm: Node3D
var lifted_radio: Node3D
var cab_radio: Node3D
var blackout_digits: Node3D
var reaching_sleeve: MeshInstance3D
var reaching_hand: MeshInstance3D
var door: Node3D
var store_door: Node3D
var nozzle: Node3D
var paper: Node3D
var indoor: OmniLight3D
var lights_out: Environment
var sound: AudioStreamPlayer
var overlay: ReelOverlay
var wheel_nodes: Array[Node3D] = []
var flood: Array[Node3D] = []
var birds: Array[Node3D] = []
var dog_legs: Array[Array] = []
var signal_green: MeshInstance3D
var signal_dark: Material
var signal_live: StandardMaterial3D

func _ready() -> void:
	recording = OS.get_cmdline_user_args().has("--capture")
	scenery = (load("res://set.glb") as PackedScene).instantiate()
	add_child(scenery)
	pickup = node("WestboundPickup")
	dog = node("DanielDog")
	head = node("DogHeadRig")
	tail = node("DogTailRig")
	keys = node("TruckKeys")
	water = node("WaterStream")
	noon = node("NoonClock")
	noon.hide()
	flashback_set = (load("res://flashback.glb") as PackedScene).instantiate()
	add_child(flashback_set)
	memory_alarm = flashback_set.find_child("DayOneAlarmSet", true, false) as Node3D
	lifted_radio = flashback_set.find_child("MartinsRadio", true, false) as Node3D
	cab_radio = flashback_set.find_child("CabRadio", true, false) as Node3D
	blackout_digits = flashback_set.find_child("BlackoutDigits", true, false) as Node3D
	cab_radio.reparent(pickup, false)
	cab_radio.position = v([.018,.31,.829])
	door = node("PassengerDoor")
	store_door = node("ShopDoor")
	var glazing := store_door.find_child("Glazing", true, false) as MeshInstance3D
	if glazing:
		var pane := material(Color(.64, .81, .83, .16))
		pane.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		pane.roughness = .27
		glazing.material_override = pane
		glazing.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	nozzle = node("HandNozzle")
	paper = node("WindPaper")
	for i in range(15):
		flood.append(node("WindLeaf%02d" % i))
	for i in range(3):
		birds.append(node("RoadBird%02d" % i))
	for w in ["WheelFL", "WheelFR", "WheelRL", "WheelRR"]:
		var rig := node(w)
		if rig:
			wheel_nodes.append(rig)
	var traffic_fixture := node("GridSignal")
	for mesh in traffic_fixture.find_children("*", "MeshInstance3D", true, false):
		if str(mesh.name).replace(" ", "_").begins_with("Unlit_signal_lens"):
			signal_green = mesh
			break
	if signal_green:
		signal_dark = signal_green.get_active_material(0)
		signal_live = material(Color("#367b57"))
		signal_live.emission_enabled = true
		signal_live.emission = Color("#39a875")
		signal_live.emission_energy_multiplier = .9
	add_lights()
	build_window_foreground()
	build_legs()
	build_reaching_arm()
	camera = Camera3D.new()
	add_child(camera)
	camera.current = true
	camera.keep_aspect = Camera3D.KEEP_HEIGHT
	camera.near = .025
	camera.far = 360
	var ui := CanvasLayer.new()
	add_child(ui)
	overlay = ReelOverlay.new()
	ui.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.preview = not recording
	sound = AudioStreamPlayer.new()
	add_child(sound)
	if not recording and ResourceLoader.exists("res://mix.wav"):
		sound.stream = load("res://mix.wav")
		sound.play()
	update_scene()

func node(label: String) -> Node3D:
	return scenery.find_child(label, true, false) as Node3D

func v(p: Array) -> Vector3:
	return Vector3(p[0], p[2], -p[1])

func material(tint: Color) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = tint
	result.roughness = .88
	return result

func lamp(p: Array, tint: Color, energy: float, radius: float) -> OmniLight3D:
	var light := OmniLight3D.new()
	add_child(light)
	light.position = v(p)
	light.light_color = tint
	light.light_energy = energy
	light.omni_range = radius
	return light

func add_lights() -> void:
	var wrapper := WorldEnvironment.new()
	lights_out = Environment.new()
	lights_out.background_mode = Environment.BG_COLOR
	lights_out.background_color = Color("#91aabd")
	lights_out.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	lights_out.ambient_light_color = Color("#c8d8e6")
	lights_out.ambient_light_energy = .64
	wrapper.environment = lights_out
	add_child(wrapper)
	var sun := DirectionalLight3D.new()
	add_child(sun)
	sun.rotation_degrees = Vector3(-37, -23, 0)
	sun.light_color = Color("#fff0c8")
	sun.light_energy = 1.03
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 62
	lamp([.15,2.68,2.03], Color("#d8eafb"), .42, 6.2)
	indoor = lamp([.6,.68,2.42], Color("#ffdd9f"), .82, 5.2)
	lamp([15.7,259.67,2.01], Color("#d1e2e2"), .36, 6.4)

func build_window_foreground() -> void:
	# The exterior houses in the window insert need ground between the cutaway
	# interior and the separate westbound roadway.
	var foreground := MeshInstance3D.new()
	var ground := BoxMesh.new()
	ground.size = Vector3(104.0,.40,78.0)
	foreground.mesh = ground
	foreground.material_override = material(Color("#78846c"))
	add_child(foreground)
	foreground.position = v([0,44,-.35])

func build_reaching_arm() -> void:
	reaching_sleeve = reach_mesh(Color("#4a5b62"))
	reaching_hand = reach_mesh(Color("#ae815f"))

func reach_mesh(tint: Color) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	var shape := SphereMesh.new()
	shape.radius = .5
	shape.height = 1
	shape.radial_segments = 12
	shape.rings = 6
	part.mesh = shape
	part.material_override = material(tint)
	add_child(part)
	return part

func place_reaching_arm(wrist: Vector3, palm: Vector3) -> void:
	reaching_sleeve.show()
	reaching_hand.show()
	pose_segment(reaching_sleeve, wrist, palm.lerp(wrist,.16), .110)
	reaching_hand.position = palm
	reaching_hand.quaternion = Quaternion(Vector3.UP, (wrist-palm).normalized())
	reaching_hand.scale = Vector3(.090,.125,.065)

func _unhandled_key_input(event: InputEvent) -> void:
	if recording or not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_R:
		clock = 0.0
		playing = true
		if sound.stream:
			sound.play()
	elif event.keycode == KEY_SPACE:
		if clock < DURATION:
			playing = not playing
			sound.stream_paused = not playing
	elif event.keycode == KEY_LEFT or event.keycode == KEY_RIGHT:
		clock = clampf(clock + (-5.0 if event.keycode == KEY_LEFT else 5.0), 0.0, DURATION - .001)
		if sound.stream:
			sound.play(clock)
			sound.stream_paused = not playing
	elif event.keycode == KEY_ESCAPE:
		get_tree().quit()

func _process(delta: float) -> void:
	if playing:
		clock += delta
	if clock >= DURATION:
		if recording:
			get_tree().quit()
			return
		clock = DURATION
		playing = false
		sound.stop()
	update_scene()

func pose_truck() -> void:
	var road := clampf((clock - 46.42) / 10.28, 0, 1)
	var park := smoothstep(56.64, 60.86, clock)
	var x := 1.49 + .20 * sin(road * TAU) + 11.26 * park
	var y := lerpf(112, 244.8, road) + 5.15 * park
	var z := lerpf(.155,.025,park)
	var departure := smoothstep(45.3,46.5,clock)
	pickup.position = v([lerpf(8.03,x,departure), lerpf(107.3,y,departure), z])
	pickup.rotation.y = PI - .93 * sin(PI * park) + .15 * park
	var travel := 132.8 * road + 12 * park + 7.2 * departure
	for wheel in wheel_nodes:
		wheel.rotation.x = -travel / .393
	var boarding := smoothstep(42.6,43.32,clock) * (1.0-smoothstep(45.12,45.72,clock))
	door.rotation.y = boarding * -.81
	for i in range(2):
		var jug := node("CargoWaterA" if i==0 else "CargoWaterB")
		var load_time := 39.55 + i * .91
		var u := smoothstep(load_time, load_time+.61,clock)
		jug.visible = clock >= load_time
		jug.position = v([lerpf(-.10,-.37 + i*.25,u), lerpf(2.76,1.35,u), lerpf(1.64,.735,u)])

func build_legs() -> void:
	for leg in range(4):
		var pieces: Array[MeshInstance3D] = []
		for i in range(3):
			var segment := MeshInstance3D.new()
			var shape := SphereMesh.new()
			shape.radius = .5
			shape.height = 1
			shape.radial_segments = 10
			shape.rings = 5
			segment.mesh = shape
			segment.material_override = material(Color("#ccb08b") if i == 2 else Color("#b3916a"))
			dog.add_child(segment)
			pieces.append(segment)
		dog_legs.append(pieces)

func pose_segment(piece: MeshInstance3D, a: Vector3, b: Vector3, width: float) -> void:
	var axis := b - a
	piece.position = (a+b)*.5
	piece.quaternion = Quaternion(Vector3.UP,axis.normalized())
	piece.scale = Vector3(width,axis.length()+.07,width)

func pose_legs(distance: float, walking: bool, sitting: bool) -> void:
	for i in range(dog_legs.size()):
		var front := i < 2
		var side := -1.0 if i%2==0 else 1.0
		var phase := fposmod(distance/.58 + [0.0,.50,.74,.24][i],1.0)
		var reach := 0.0
		var lift := 0.0
		if walking:
			var swing := clampf((phase-.62)/.38,0,1)
			reach = lerpf(.18,-.18,phase/.62) if phase < .62 else lerpf(-.18,.18,smoothstep(0,1,swing))
			lift = .088*sin(swing*PI)
		var hip := Vector3(side*.107,.343,.171 if front else -.149)
		var paw := Vector3(side*.113,.045+lift,(.192 if front else -.156)+reach)
		if sitting and not front:
			paw.y = .085
			paw.z += .082
		var line := paw-hip
		var bend := Vector3(0,line.z,-line.y).normalized()*(-1.0 if front else 1.0)
		var joint := (hip+paw)*.5 + bend * sqrt(maxf(.0004,.185*.185-line.length_squared()*.25))
		var part: Array = dog_legs[i]
		pose_segment(part[0],hip,joint,.11 if front else .145)
		pose_segment(part[1],joint,paw,.078)
		part[2].position = paw + Vector3(0,0,.024)
		part[2].scale = Vector3(.087,.069,.128)

func pose_dog() -> void:
	var walking := clock > 42.9 and clock < 45.04
	var u := smoothstep(42.9,45.04,clock)
	var distance := u * .83
	if clock < 39.1:
		dog.position = v([2.28,-2.97,0])
		dog.rotation.y = .19
	elif clock < 45.24:
		dog.position = v([5.54+distance,108.04,.03])
		dog.rotation.y = 1.57
	else:
		# Jump cut from the approach to the dog already seated. No walk through bodywork.
		dog.position = pickup.to_global(v([.44,.07,.93]))
		dog.rotation.y = pickup.rotation.y
	head.rotation.x = -.09 + .16 * smoothstep(5.2,6.8,clock) - .16*smoothstep(8,9,clock)
	head.rotation.y = -.14 + smoothstep(88.3,89.55,clock)*.82
	tail.rotation.y = sin(clock*7.5)*(.31 if walking else .09)
	pose_legs(distance,walking,clock >= 45.24)

func set_actions() -> void:
	pose_truck()
	pose_dog()
	var gap := smoothstep(20.85,21.08,clock)
	indoor.light_energy = lerpf(.82,.04,gap)
	memory_alarm.visible = clock >= 11.95 and clock < 14.6
	var radio_lift := smoothstep(15.44,16.75,clock)
	lifted_radio.position = v([1.76+.04*radio_lift,.79-.22*radio_lift,.77+.28*radio_lift])
	lifted_radio.rotation.z = .14 * radio_lift
	lifted_radio.visible = clock >= 14.6 and clock < 17.0
	cab_radio.visible = clock >= 39.2
	blackout_digits.visible = clock < 20.98
	if signal_green:
		signal_green.material_override = signal_live if clock < 22.83 else signal_dark
	water.visible = clock >= 12.05 and clock < 14.56
	water.scale.x = .76+.20*sin(clock*29)
	var key_grab := smoothstep(36.57,37.12,clock)
	keys.position = v([1.355+.15*key_grab,.575-.11*key_grab,.761+.30*key_grab])
	keys.rotation.y = -.24+1.06*key_grab
	keys.visible = clock < 37.12
	store_door.rotation.y = -.26 - 1.13*smoothstep(69.72,71.27,clock) + .24*smoothstep(72.19,74.80,clock)
	var lift := smoothstep(64.08,64.76,clock)
	var lower := smoothstep(66.3,67.01,clock)
	var held := lift*(1-lower)
	nozzle.position = v([14.652+.13*held,253.378-.44*held,.973+.12*held])
	nozzle.rotation.x = held*.51
	reaching_sleeve.hide()
	reaching_hand.hide()
	if clock >= 14.84 and clock < 16.98:
		var contact := smoothstep(14.84,15.44,clock)
		var grab := lifted_radio.position + v([.164,-.052,.10])
		var palm := v([2.20,.33,.91]).lerp(grab,contact)
		place_reaching_arm(palm + v([.20,-.27,-.135]),palm)
	elif clock >= 64.0 and clock < 66.96:
		var contact := smoothstep(64.0,64.22,clock)
		var grab := nozzle.position + v([.055,-.032,.048])
		var palm := v([15.47,252.36,1.12]).lerp(grab,contact)
		place_reaching_arm(palm + v([.19,-.32,-.12]),palm)
	for i in range(flood.size()):
		var leaf := flood[i]
		var progress := fposmod(clock*(.32+i*.013)+i*.148,1)
		var road_leaf := clock >= 46.5 and clock < 60.5
		var road_pos := pickup.position
		leaf.visible = clock >= 22
		leaf.position = v([lerpf(7.5,-1.8,progress),242.6+float(i)*1.04,.11+.88*pow(sin(PI*progress),1.4)])
		if road_leaf:
			leaf.position = road_pos+v([lerpf(6,-4,progress),float(i)*2.5-10,.16+sin(progress*PI)*.65])
		leaf.rotation = Vector3(clock*3.3+i,clock*6+i,clock*-4.3)
	for i in range(birds.size()):
		var bird := birds[i]
		var flight := clampf((clock-29-i*.13)/4.3,0,1)
		bird.visible = clock > 29+i*.13 and clock < 33.75
		bird.position = v([lerpf(5,-21,flight)-i*1.3,85 + flight*18+i*2.9,5.8+flight*8+i*.52])
		bird.rotation = Vector3(.11*sin(clock*12+i),-1.9,.24*sin(clock*15+i))
	paper.visible = clock > 56.45 and clock < 71.0
	var sheet := fposmod((clock-56.4)*.16,1)
	paper.position = v([lerpf(20.4,10.3,sheet), 248.6 + sheet*8.9,.18+.61*sin(sheet*PI)])
	paper.rotation = Vector3(clock*3,clock*2.8,clock*3.3)

func update_scene() -> void:
	set_actions()
	shot = 0
	while shot+1 < SHOTS.size() and clock >= SHOTS[shot+1][0]:
		shot += 1
	var setup: Array = SHOTS[shot]
	var next := DURATION if shot == SHOTS.size()-1 else float(SHOTS[shot+1][0])
	var alpha := clampf((clock-float(setup[0])) / (next-float(setup[0])),0,1)
	var camera_space := int(setup[1])
	var p := v(setup[2]).lerp(v(setup[3]),alpha)
	var look := v(setup[4]).lerp(v(setup[5]),alpha)
	if camera_space > 0:
		p = pickup.to_global(p)
	if camera_space == 1:
		look = pickup.to_global(look)
	var step := .024 if shot in [13,24,25,26,27] else .006
	camera.position = p + Vector3(sin(clock*10.5)*step,sin(clock*17)*step*.6,0)
	camera.look_at(look)
	camera.rotation.z += sin(clock*6.4)*.005
	camera.fov = float(setup[6])
	overlay.time = clock
	overlay.playing = playing
	overlay.queue_redraw()

class ReelOverlay extends Control:
	var time := 0.0
	var preview := false
	var playing := true

	func title(caption: String, y: float, pixels: int, alpha := 1.0) -> void:
		var font := ThemeDB.fallback_font
		var width := font.get_string_size(caption,HORIZONTAL_ALIGNMENT_LEFT,-1,pixels).x
		var p := Vector2((size.x-width)*.5,y)
		draw_string_outline(font,p,caption,HORIZONTAL_ALIGNMENT_LEFT,-1,pixels,7,Color(.06,.07,.07,alpha))
		draw_string(font,p,caption,HORIZONTAL_ALIGNMENT_LEFT,-1,pixels,Color(.96,.91,.80,alpha))

	func _draw() -> void:
		var blink := 1.0-smoothstep(.22,.67,time)
		if blink > 0:
			var lid := size.y*.5*blink
			draw_rect(Rect2(0,0,size.x,lid),Color("#111820"))
			draw_rect(Rect2(0,size.y-lid,size.x,lid),Color("#111820"))
		if time >= .85 and time < 4.85:
			title("DAY 18",size.y*.71,35,1.0-smoothstep(4.3,4.85,time))
		if time >= 12.17 and time < 15.32:
			title("DAY 1",size.y*.71,35,1.0-smoothstep(14.79,15.32,time))
		if time >= 19.9 and time < 22.57:
			title("FIVE HOURS LATER",size.y*.72,26)
		if time >= 85.65 and time < 87.99:
			title("I LEFT THIS AT NOON.",size.y*.74,28)
		var fade := smoothstep(89.38,89.95,time)
		if fade > 0:
			draw_rect(Rect2(Vector2.ZERO,size),Color(.06,.08,.10,fade))
		if preview:
			draw_rect(Rect2(0,0,size.x,38),Color(.05,.07,.10,.90))
			draw_rect(Rect2(0,35,size.x*clampf(time/90.0,0,1),3),Color("#d18b54"))
			var state := "PLAYING" if playing else "PAUSED"
			draw_string(ThemeDB.fallback_font,Vector2(12,23),"EPISODE 2  •  %s  •  %04.1f / 90s" % [state,time],HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("#f5eee0"))
			draw_rect(Rect2(0,size.y-33,size.x,33),Color(.05,.07,.10,.87))
			draw_string(ThemeDB.fallback_font,Vector2(12,size.y-11),"SPACE  pause     ← →  seek     R  replay",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("#f5eee0"))
