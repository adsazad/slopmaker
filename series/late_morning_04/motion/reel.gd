extends Node3D

const SET = preload("res://neighborhood.gd")
const DURATION := 80.0
# Time, coordinate space (world/truck/garage), camera, target, drift, lens.
const SHOTS := [
	[0.0,1,Vector3(-.36,1.51,.01),Vector3(-.25,1.30,9),Vector3(.03,.015,.05),59.0],
	[5.4,0,Vector3(6.90,2.46,-20.8),Vector3(.0,1.10,-27.7),Vector3(-.54,.04,-.42),58.0],
	[8.6,0,Vector3(6.65,2.32,-41.98),Vector3(12.0,1.39,-39.3),Vector3(.32,-.07,.12),62.0],
	[11.1,0,Vector3(31.19,1.49,-34.11),Vector3(31.25,1.23,-36.18),Vector3(.12,-.13,-.39),51.0],
	[14.3,0,Vector3(31.63,.52,-35.08),Vector3(31.92,.07,-35.63),Vector3(.12,-.11,-.12),45.0],
	[16.4,0,Vector3(30.91,1.51,-39.26),Vector3(28.62,.92,-42.85),Vector3(-.16,.01,-.42),51.0],
	[18.9,0,Vector3(31.97,1.49,-40.10),Vector3(34.16,.75,-43.86),Vector3(.36,-.03,-.28),54.0],
	[21.2,0,Vector3(32.80,1.38,-41.71),Vector3(32.35,1.04,-42.14),Vector3(-.06,-.047,-.09),45.0],
	[23.7,2,Vector3(.12,1.59,2.69),Vector3(.18,1.14,-2.65),Vector3(.12,-.09,-.61),60.0],
	[27.1,2,Vector3(-.36,1.53,-1.87),Vector3(-.31,1.04,-2.59),Vector3(.11,-.08,-.11),48.0],
	[30.3,2,Vector3(.52,1.36,-2.15),Vector3(.25,1.03,-2.59),Vector3(.03,-.035,-.09),43.0],
	[32.8,1,Vector3(-1.53,.81,-1.15),Vector3(-.80,.27,-1.67),Vector3(.12,-.08,-.13),53.0],
	[35.8,1,Vector3(-.82,1.64,-2.47),Vector3(.02,.76,-1.44),Vector3(.16,-.07,.13),49.0],
	[37.0,0,Vector3(26.46,1.39,-54.97),Vector3(27.52,1.07,-54.79),Vector3(.14,-.13,.07),54.0],
	[40.1,0,Vector3(-5.58,5.77,-36.6),Vector3(-8.02,7.56,-49.0),Vector3(-.27,.15,-.38),54.0],
	[45.8,0,Vector3(2.50,2.59,-48.0),Vector3(-9.7,8.4,-64.0),Vector3(.44,.12,-.35),60.0],
	[53.2,0,Vector3(6.77,2.37,-46.6),Vector3(-22.0,12.4,-174.0),Vector3(-.37,.34,-.67),47.0],
	[57.8,0,Vector3(-4.20,3.82,-65.4),Vector3(-20.5,14.6,-173.0),Vector3(.58,.41,-.98),43.0],
	[65.05,0,Vector3(31.63,.52,-35.06),Vector3(31.92,.07,-35.63),Vector3(.12,-.11,-.12),43.0],
	[67.3,1,Vector3(.15,1.54,.34),Vector3(.28,1.03,.14),Vector3(.06,-.075,-.015),46.0],
	[73.1,1,Vector3(-.37,1.51,.01),Vector3(-.21,1.34,9),Vector3(.05,-.013,.05),60.0],
	[76.2,0,Vector3(-32.0,5.3,-12.0),Vector3(-28.0,6.1,-71.0),Vector3(-1.6,.2,0),56.0],
]

var stage: Node3D
var camera: Camera3D
var sun: DirectionalLight3D
var environment: Environment
var sky_material: ProceduralSkyMaterial
var screen: ColorRect
var title: Label
var preview_audio: AudioStreamPlayer
var time := 0.0
var playing := true
var capture := false
var sky_step := -1
var left_wheel: Node3D

func _ready() -> void:
	capture = OS.get_cmdline_user_args().has("--capture")
	stage = SET.new()
	add_child(stage)
	camera = Camera3D.new()
	camera.near = .018
	camera.far = 250.0
	add_child(camera)
	camera.current = true
	left_wheel = stage.truck.find_child("WheelRL",true,false)
	var world := WorldEnvironment.new()
	environment = Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	var sky := Sky.new()
	sky_material = ProceduralSkyMaterial.new()
	sky_material.sun_angle_max = 0.0
	sky.sky_material = sky_material
	environment.sky = sky
	world.environment = environment
	add_child(world)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-23,-102,0)
	sun.shadow_enabled = true
	add_child(sun)
	var interior_light := OmniLight3D.new()
	stage.garage.add_child(interior_light)
	interior_light.position = Vector3(-1.24,2.14,.4)
	interior_light.light_color = Color("#cec6ad")
	interior_light.light_energy = 1.2
	interior_light.omni_range = 7.5
	var overlay := CanvasLayer.new()
	add_child(overlay)
	screen = ColorRect.new()
	overlay.add_child(screen)
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title = Label.new()
	overlay.add_child(title)
	title.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size",36)
	title.add_theme_color_override("font_color",Color("#f1e8d5"))
	title.add_theme_color_override("font_shadow_color",Color("#161e26"))
	title.add_theme_constant_override("shadow_offset_y",2)
	if not capture:
		preview_audio = AudioStreamPlayer.new()
		preview_audio.stream = load("res://assets/mix.wav")
		add_child(preview_audio)
		preview_audio.play()
	frame()

func _unhandled_key_input(event: InputEvent) -> void:
	if capture or not event is InputEventKey or event.echo or not event.pressed:
		return
	match event.keycode:
		KEY_SPACE: playing = not playing
		KEY_R:
			time = 0.0
			playing = true
		KEY_LEFT: time = maxf(time-5.0,0.0)
		KEY_RIGHT: time = minf(time+5.0,DURATION)
		KEY_ESCAPE: get_tree().quit()
	if preview_audio != null:
		preview_audio.play(minf(time,DURATION-.02))
		preview_audio.stream_paused = not playing
	frame()

func _process(delta: float) -> void:
	if not playing:
		return
	time = minf(time+delta,DURATION)
	frame()
	if time >= DURATION:
		playing = false
		if capture:
			get_tree().quit()

func pose_pickup() -> void:
	var truck: Node3D = stage.truck
	var arrive := smoothstep(7.5,10.8,time)
	var speed_z := lerpf(13.0,-37.5,clampf(time/8.5,0,1))
	var steer := .64*sin((speed_z-2.0)*.29)
	truck.position = Vector3(lerpf(steer,7.62,arrive),.04,lerpf(speed_z,-46.7,arrive))
	truck.rotation.y = PI + cos((speed_z-2.0)*.29)*.18*(1.0-arrive) - PI*.5*arrive
	# The atlas insert covers the turnaround. The pickup then follows the cross street west.
	if time >= 67.3:
		var departure := maxf(time-72.6,0.0)
		var ramp := minf(departure,3.6)
		var westward := 1.4*ramp+1.9*ramp*ramp+13.0*maxf(departure-ramp,0.0)
		truck.position = Vector3(7.62-westward,.04,lerpf(-46.7,-45.1,smoothstep(0,3.6,departure)))
		truck.rotation.y = -PI*.5
	for id in ["WheelFL","WheelFR","WheelRL","WheelRR"]:
		var wheel := truck.find_child(id,true,false) as Node3D
		if wheel != null:
			wheel.rotation.x = (truck.position.x if time >= 67.3 else truck.position.z)/.393
	if left_wheel != null:
		left_wheel.scale.y = lerpf(.88,1.0,smoothstep(32.8,35.6,time))
	stage.atlas.visible = time > 66.0

func pose_props() -> void:
	var garage: Node3D = stage.garage
	var using_pump := time >= 32.8 and time < 35.8
	var pump: Node3D = garage.pump
	pump.position = garage.to_local(stage.truck.to_global(Vector3(-1.19,.028,-1.41))) if using_pump else Vector3(-1.37,.008,-1.69)
	var packed := time >= 35.8
	for item in [[garage.case,Vector3(-.51,.978,-2.60),Vector3(-.29,.75,-1.40)],
			[garage.pliers,Vector3(.13,1.005,-2.60),Vector3(.06,.75,-1.62)],
			[garage.gauge,Vector3(.51,.985,-2.57),Vector3(.18,.75,-1.51)],
			[pump,Vector3(-1.37,.008,-1.69),Vector3(.41,.75,-1.39)]]:
		var prop: Node3D = item[0]
		if packed:
			prop.position = garage.to_local(stage.truck.to_global(item[2]))
			prop.rotation.y = stage.truck.rotation.y - garage.rotation.y
		elif prop != pump:
			prop.position = item[1]
			prop.rotation.y = 0.0
	if not packed:
		pump.rotation.y = 0.0
	garage.pedal.rotation.x = -.31 * sin((time-32.8)*PI*2.4) if using_pump else 0.0
	stage.boot.visible = using_pump
	stage.boot.global_position = pump.global_position + Vector3(.11,.24+garage.pedal.rotation.x*.10,.04)
	stage.boot.rotation.y = PI*.50
	var gather := smoothstep(21.82,23.4,time)
	stage.gamepad.position = Vector3(1.35+.14*gather,1.024+.17*gather,-2.14+.18*gather)
	stage.gamepad.rotation.z = .39*gather
	stage.gamepad.visible = time < 23.69
	var pocket := smoothstep(14.68,15.9,time)*(1.0-smoothstep(64.5,66.8,time))
	stage.key.position = Vector3(.92-.12*pocket,.025+.16*pocket,4.43+.17*pocket)

func pose_morning() -> void:
	var dawn := smoothstep(38.2,40.7,time)
	var dark := smoothstep(34.9,37.2,time)*(1.0-dawn)
	sun.light_energy = lerpf(.88,1.10,dawn)*(1.0-dark*.92)
	sun.light_color = Color("#ffd1a0").lerp(Color("#ffeeda"),dawn)
	environment.ambient_light_color = Color("#9199b0").lerp(Color("#c3d2cf"),dawn)
	environment.ambient_light_energy = lerpf(.75,.18,dark)
	var horizon_step := roundi(dark*10) + roundi(dawn*10)*16
	if horizon_step != sky_step:
		sky_step = horizon_step
		sky_material.sky_top_color = Color("#65788c").lerp(Color("#151e36"),dark).lerp(Color("#7a9eae"),dawn)
		sky_material.sky_horizon_color = Color("#e1b79b").lerp(Color("#38445d"),dark).lerp(Color("#d8ddd6"),dawn)
		sky_material.ground_horizon_color = sky_material.sky_horizon_color
		sky_material.ground_bottom_color = Color("#65675e")
	for i in range(stage.birds.size()):
		var bird: Node3D = stage.birds[i]
		bird.visible = time >= 39.5
		if not bird.visible:
			continue
		var lift := 44.3+float(i%17)*.072+float(i/19)*.46
		var fly := maxf(time-lift,0.0)
		bird.position = Vector3(-8.88+float(i%3)*.98-fly*(3.7+float(i%6)*.14),
			7.64+fly*.60+sin(fly*3.1+i)*minf(fly*.17,.32),
			-41-float(i/3)*.78+fly*(.94+float(i%5)*.16))
		bird.rotation.y = -PI*.52 if fly > 0 else .2+float(i%8)*.45
		var flap := sin(fly*TAU*(3.9+float(i%5)*.12)+i*.37)*.80
		bird.get_node("Left").rotation.z = flap if fly > 0 else .38
		bird.get_node("Right").rotation.z = -flap if fly > 0 else -.38
	for i in range(stage.smoke.size()):
		var puff: MeshInstance3D = stage.smoke[i]
		puff.visible = time > 49.7
		if not puff.visible:
			continue
		var age := fposmod(float(i)*.92+(time-49.7)*.83,27.0)
		var width := 1.1+age*.135
		puff.position = Vector3(-26.0+age*age*.035+sin(age*.65+i)*width*.35,
			4.8+age*.70+sin(i*3.8)*.81,
			-173.0+sin(age*.52+i)*width*.66)
		puff.scale = Vector3(width*1.26,width*.86,width)
		var opacity := smoothstep(0.0,1.3,age)*(1.0-smoothstep(20.5,27.0,age))
		puff.material_override.albedo_color = Color(.19,.22,.23,.32*opacity)

func frame() -> void:
	pose_pickup()
	pose_props()
	pose_morning()
	var index := 0
	while index+1 < SHOTS.size() and time >= float(SHOTS[index+1][0]):
		index += 1
	var shot: Array = SHOTS[index]
	var next := float(SHOTS[index+1][0]) if index+1 < SHOTS.size() else DURATION
	var blend := clampf((time-float(shot[0]))/(next-float(shot[0])),0,1)
	var position: Vector3 = shot[2]+shot[4]*blend
	var target: Vector3 = shot[3]
	var space := int(shot[1])
	if space > 0:
		var origin: Node3D = stage.truck if space == 1 else stage.garage
		position = origin.to_global(position)
		target = origin.to_global(target)
	camera.position = position + Vector3(sin(time*8.3)*.006,cos(time*10.1)*.006,0)
	camera.look_at(target)
	camera.fov = shot[5]
	var blink := smoothstep(38.9,39.26,time)*(1.0-smoothstep(39.79,40.06,time))
	var fade := maxf(blink,maxf(1.0-smoothstep(0,.45,time),smoothstep(78.5,79.9,time)))
	screen.color = Color(.027,.035,.056,fade)
	title.text = "DAY 3" if time > .55 and time < 3.5 else ("DAY 4" if time > 40.35 and time < 43.2 else "")
