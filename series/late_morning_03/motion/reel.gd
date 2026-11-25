extends Node3D

const SET = preload("res://station_assets.gd")
const DURATION := 75.0
# Start, camera position, focus, drift, field of view. Local camera shots use the pickup's frame.
const SHOTS := [
	[0.0, true, Vector3(-.34,1.51,.06), Vector3(-.2,1.23,7), Vector3(.03,0,.04), 64.0],
	[4.6, true, Vector3(.04,1.35,.03), Vector3(.34,1.12,.50), Vector3(.08,-.04,.04), 43.0],
	[9.0, false, Vector3(18.6,2.35,-247), Vector3(13.6,1.1,-253), Vector3(-.8,-.21,-.44), 60.0],
	[14.0, true, Vector3(-.33,1.47,.14), Vector3(.60,1.16,.32), Vector3(.09,-.04,0), 56.0],
	[18.0, false, Vector3(34.53,1.30,-248.87), Vector3(35.58,1.18,-248.80), Vector3(.13,-.055,.07), 61.0],
	[23.0, false, Vector3(13.73,1.55,-251.9), Vector3(14.2,1.32,-253.35), Vector3(.12,-.16,-.28), 48.0],
	[27.0, false, Vector3(21.4,1.61,-263.0), Vector3(24.4,1.44,-268), Vector3(.43,.08,-.40), 51.0],
	[32.0, false, Vector3(14.72,1.55,-262.10), Vector3(14.55,1.07,-263.39), Vector3(-.14,-.09,-.37), 50.0],
	[36.1, false, Vector3(14.68,1.22,-262.75), Vector3(14.64,.91,-263.29), Vector3(-.09,-.04,-.08), 44.0],
	[42.0, false, Vector3(20.46,1.27,-255.31), Vector3(20.65,.10,-256), Vector3(.12,-.31,-.11), 49.0],
	[45.0, false, Vector3(20.87,1.43,-249.61), Vector3(23.09,.58,-251.30), Vector3(.15,-.10,-.19), 52.0],
	[49.0, true, Vector3(.62,1.23,-2.23), Vector3(-.25,.88,-1.43), Vector3(-.17,.03,.06), 49.0],
	[52.8, false, Vector3(25.8,1.88,-256.6), Vector3(22.8,1.16,-260), Vector3(-1.03,-.22,-1.0), 56.0],
	[56.0, false, Vector3(24.18,1.34,-260.89), Vector3(23.55,1.24,-260.83), Vector3(-.15,-.04,.08), 43.0],
	[59.0, true, Vector3(.04,1.36,.01), Vector3(.15,1.02,.33), Vector3(.04,-.025,-.03), 47.0],
	[63.5, true, Vector3(-.36,1.52,.06), Vector3(-.27,1.31,8.9), Vector3(.045,-.02,.015), 58.0],
	[70.0, false, Vector3(-4.7,3.15,-151), Vector3(1.8,1.30,-179), Vector3(2.1,.5,-5.1), 53.0],
]

var stage: Node3D
var camera: Camera3D
var sun: DirectionalLight3D
var environment: Environment
var lights: Array[SpotLight3D] = []
var overlay: ColorRect
var card: Label
var sky_material: ProceduralSkyMaterial
var last_sky_step := -1
var preview_audio: AudioStreamPlayer
var recording := false
var playing := true
var time := 0.0

func _ready() -> void:
	recording = OS.get_cmdline_user_args().has("--capture")
	stage = SET.new()
	add_child(stage)
	camera = Camera3D.new()
	camera.near = .025
	camera.far = 200.0
	add_child(camera)
	camera.current = true
	var world_environment := WorldEnvironment.new()
	environment = Environment.new()
	environment.background_mode = Environment.BG_SKY
	sky_material = ProceduralSkyMaterial.new()
	sky_material.sun_angle_max = 0.0
	var sky := Sky.new()
	sky.sky_material = sky_material
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	world_environment.environment = environment
	add_child(world_environment)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-34,-42,0)
	sun.shadow_enabled = true
	add_child(sun)
	for x in [-.68,.68]:
		var positioner := Node3D.new()
		stage.pickup.add_child(positioner)
		positioner.position = Vector3(x,.87,2.59)
		var light := SpotLight3D.new()
		light.rotation_degrees = Vector3(-4,180,0)
		light.spot_range = 47.0
		light.spot_angle = 30.0
		light.light_color = Color("#ffe6c3")
		light.light_energy = 7.0
		positioner.add_child(light)
		lights.append(light)
	var ui := CanvasLayer.new()
	add_child(ui)
	overlay = ColorRect.new()
	ui.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card = Label.new()
	ui.add_child(card)
	card.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	card.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	card.add_theme_font_size_override("font_size", 37)
	card.add_theme_color_override("font_color", Color("#f2e6cb"))
	card.add_theme_color_override("font_shadow_color", Color("#172027"))
	card.add_theme_constant_override("shadow_offset_y", 2)
	if not recording:
		preview_audio = AudioStreamPlayer.new()
		preview_audio.stream = preload("res://assets/mix.wav")
		add_child(preview_audio)
		preview_audio.play()
	update_frame()

func _unhandled_key_input(event: InputEvent) -> void:
	if recording or not event is InputEventKey or not event.pressed or event.echo:
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
		preview_audio.play(minf(time,DURATION-.01))
		preview_audio.stream_paused = not playing
	update_frame()

func _process(delta: float) -> void:
	if not playing:
		return
	time = minf(time+delta,DURATION)
	update_frame()
	if time >= DURATION:
		playing = false
		if recording:
			get_tree().quit()

func update_frame() -> void:
	var truck: Node3D = stage.pickup
	var park := smoothstep(8.5,13.8,time)
	var travel := clampf(time/9.0,0,1)
	truck.position = Vector3(lerpf(1.4,12.7,park),.07,lerpf(-170,-247,travel)-3.0*park)
	truck.rotation.y = PI - .97*sin(park*PI)
	if time >= 62.0:
		var departure := smoothstep(62.0,65.6,time)
		truck.position = Vector3(lerpf(12.7,1.5,departure),.07,-250.0-13.0*departure)
		truck.rotation.y = PI + .98*sin(departure*PI)
	if time >= 66.0:
		truck.position = Vector3(1.55,.13,-130.0-(time-66.0)*9.5)
	for axle in ["Front","Rear"]:
		for side in ["L","R"]:
			var wheel := truck.find_child("Wheel"+axle.left(1)+side,true,false) as Node3D
			if wheel != null:
				wheel.rotation.x = (truck.position.z+truck.position.x)/.393
	stage.cans[0].visible = time < 44.9 or time >= 48.5
	stage.cans[1].visible = time >= 48.5
	stage.forecourt_can.visible = time >= 44.9 and time < 48.5
	stage.rigged_hose.visible = stage.forecourt_can.visible
	truck.find_child("CabSnacks",true,false).visible = time >= 40.0
	stage.dog.position = truck.to_global(Vector3(.44,.93,-.07))
	stage.dog.rotation.y = truck.rotation.y
	var head := stage.dog.find_child("DogHeadRig",true,false) as Node3D
	if head != null:
		head.rotation.y = .13+sin(time*1.8)*.17
	var radio: Node3D = stage.police_radio
	var radio_location := truck.to_global(Vector3(.08,1.025,.33))
	if time >= 58.6:
		radio.global_position = radio_location
		radio.global_rotation = Vector3(-.56,truck.rotation.y,0)
	else:
		radio.position = Vector3(.83,1.18+smoothstep(56.5,58.2,time)*.12,.75)
		radio.rotation = Vector3(0,.22,0)
	var day := smoothstep(19.1,23.0,time)
	sun.light_color = Color("#8da2c6").lerp(Color("#ffe8c7"),day)
	sun.light_energy = lerpf(.16,1.13,day)
	var sky_step := roundi(day*12.0)
	if sky_step != last_sky_step:
		last_sky_step = sky_step
		var brightness := sky_step / 12.0
		sky_material.sky_top_color = Color("#131c30").lerp(Color("#778d9b"),brightness)
		sky_material.sky_horizon_color = Color("#343d53").lerp(Color("#d5dcd6"),brightness)
		sky_material.ground_bottom_color = Color("#28343b").lerp(Color("#95948a"),brightness)
		sky_material.ground_horizon_color = sky_material.sky_horizon_color
	environment.ambient_light_color = Color("#7490b2").lerp(Color("#dcdfcb"),day)
	environment.ambient_light_energy = lerpf(.27,.73,day)
	for light in lights:
		light.visible = time < 13.5
	var index := 0
	while index + 1 < SHOTS.size() and time >= float(SHOTS[index+1][0]):
		index += 1
	var shot: Array = SHOTS[index]
	var end := float(SHOTS[index+1][0]) if index+1 < SHOTS.size() else DURATION
	var fraction := clampf((time-float(shot[0]))/(end-float(shot[0])),0,1)
	var point: Vector3 = shot[2] + shot[4] * fraction
	var target: Vector3 = shot[3]
	if shot[1]:
		point = truck.to_global(point)
		target = truck.to_global(target)
	camera.position = point + Vector3(sin(time*8.0)*.008,cos(time*9.1)*.007,0)
	camera.look_at(target)
	camera.fov = shot[5]
	stage.hand.hide()
	stage.sleeve.hide()
	if time > 23.7 and time < 26.1:
		var handle := Vector3(14.62,1.24,-253.38)
		var progress := smoothstep(23.7,24.5,time)*(1.0-smoothstep(25.5,26.1,time))
		stage.reach(camera.to_global(Vector3(.13,-.19,-.47)), camera.to_global(Vector3(.13,-.19,-.52)).lerp(handle,progress))
	elif time > 36.3 and time < 40.1:
		var packet := Vector3(14.70,1.29,-263.36)
		var progress := smoothstep(36.3,37.3,time)*(1.0-smoothstep(38.5,40.1,time))
		stage.reach(camera.to_global(Vector3(.10,-.17,-.42)),camera.to_global(Vector3(.10,-.17,-.46)).lerp(packet,progress))
	elif time > 56.3 and time < 58.6:
		stage.reach(camera.to_global(Vector3(.15,-.14,-.38)),radio.global_position+Vector3(.04,-.03,.02))
	var fade := maxf(1.0-smoothstep(0.0,.65,time),smoothstep(72.8,74.7,time))
	overlay.color = Color(.03,.04,.055,fade)
	card.text = "DAY 2" if time > .7 and time < 3.5 else ""
