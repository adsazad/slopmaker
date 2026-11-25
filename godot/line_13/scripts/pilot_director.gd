extends Node3D

const PF = preload("res://scripts/prop_factory.gd")
const NARRATION_PATH := "res://audio/eli_narration.wav"
const CUE_PATH := "res://audio/eli_narration.srt"
const STORY_LENGTH := 85.36

var elapsed := 0.0
var post_voice_clock := 0.0
var voice_length := STORY_LENGTH
var total_length := STORY_LENGTH + 2.0
var camera: Camera3D
var control_room: Node3D
var town: Node3D
var old_road: Node3D
var truck: Node3D
var main_eli: Node3D
var driver_eli: Node3D
var doppelganger: Node3D
var little_girl: Node3D
var meter_wheel: Node3D
var upstairs_light: OmniLight3D
var foundry_light: OmniLight3D
var foundry_window: MeshInstance3D
var line_alert: MeshInstance3D
var line_trace: MeshInstance3D
var left_door: Node3D
var right_door: Node3D
var street_lights: Array[OmniLight3D] = []
var cues: Array[Dictionary] = []
var people: Array[Dictionary] = []
var joint_cache: Dictionary = {}
var narration: AudioStreamPlayer
var radio_event_times: Array[float] = []
var radio_event_cursor := 0
var ambience: AudioStreamPlayer
var radio_static: AudioStreamPlayer
var electrical_snap: AudioStreamPlayer
var foundry_home: Node3D
var house_window_position := Vector3(-0.55, 3.15, -64.2)
var meter_position := Vector3(-3.61, 1.53, -64.39)
var truck_start := Vector3(0, 0, 13)
var truck_stop := Vector3(0, 0, -54)
var drive_start := 26.0
var drive_end := 38.0
var exit_time := 40.0
var window_time := 58.0
var doppel_time := 65.0
var blackout_time := 74.0
var second_call_time := 78.0
var last_snap_event := -1.0
var review_frame_dir := OS.get_environment("LINE13_REVIEW_FRAMES")
var review_frame_time := -1.0
var review_frame_files: Array[String] = []


func _ready() -> void:
	control_room = get_node("ControlRoom")
	town = get_node("MorrowCreek")
	old_road = get_node("OldBellRoad")
	old_road.position.z = -65.0
	control_room.visible = false
	town.visible = true
	old_road.visible = true
	_build_connection()
	_load_cues()
	_resolve_story_beats()
	_setup_existing_sets()
	_build_camera()
	_build_eli()
	_build_townspeople()
	_build_window_figures()
	_build_foundry_home()
	_start_audio()

func _load_cues() -> void:
	if not FileAccess.file_exists(CUE_PATH):
		return
	var raw := FileAccess.get_file_as_string(CUE_PATH).replace("\r", "")
	for block in raw.strip_edges().split("\n\n"):
		var lines := block.split("\n", false)
		if lines.size() < 3:
			continue
		var time_fields := lines[1].split(" --> ")
		if time_fields.size() != 2:
			continue
		cues.append({"start":_parse_time(time_fields[0]), "end":_parse_time(time_fields[1]), "text":" ".join(lines.slice(2)).strip_edges()})

func _parse_time(value: String) -> float:
	var parts := value.replace(",", ".").split(":")
	if parts.size() != 3:
		return 0.0
	return float(parts[0]) * 3600.0 + float(parts[1]) * 60.0 + float(parts[2])

func _time_for(prefix: String, fallback_ratio: float) -> float:
	for cue in cues:
		if str(cue.text).begins_with(prefix):
			return float(cue.start)
	return STORY_LENGTH * fallback_ratio

func _resolve_story_beats() -> void:
	drive_start = maxf(8.0, _time_for("At 1:13 a.m.", 0.20) + 0.7)
	drive_end = maxf(drive_start + 5.0, _time_for("At the end stood", 0.42) + 0.6)
	exit_time = _time_for("I stepped out", 0.49)
	window_time = _time_for("The upstairs curtain", 0.66)
	doppel_time = _time_for("Behind her stood", 0.72)
	blackout_time = _time_for("Every light in the house", 0.84)
	second_call_time = _time_for("The outage board refreshed", 0.87)

func _build_connection() -> void:
	# Extend the Morrow Creek road into the tree-lined road without a scene cut.
	PF.box(self, "continuous_night_road", Vector3(10, 0.13, 44), Vector3(0, -0.11, -54), PF.material("#202833", 0.92))
	PF.box(self, "foundry_lane", Vector3(7.6, 0.13, 32), Vector3(0, -0.11, -84), PF.material("#252b32", 0.94))
	# An energized service cabinet gives Eli a physical inspection point at the opening.
	PF.box(self, "street_service_cabinet", Vector3(1.25, 1.85, 0.7), Vector3(-4.4, 0.95, 13.5), PF.material("#465159", 0.44, 0.38))
	PF.box(self, "cabinet_door", Vector3(1.03, 1.58, 0.08), Vector3(-4.4, 0.98, 13.1), PF.material("#26343c", 0.34, 0.25))
	PF.box(self, "cabinet_meter_face", Vector3(0.55, 0.43, 0.04), Vector3(-4.4, 1.24, 13.045), PF.material("#12323b", 0.28, 0.0, 0.22))
	PF.sphere(self, "cabinet_alarm_lamp", 0.19, Vector3(-4.4, 1.68, 13.0), PF.material("#ed453e", 0.28, 0.0, 1.5), 10, 6)
	for z in range(-34, -75, -5):
		PF.box(self, "connector_lane_mark_%d" % abs(z), Vector3(0.08, 0.02, 1.15), Vector3(0, -0.03, float(z)), PF.material("#8d8d84", 0.9))
	# Reflective power-line poles lead the camera toward the dark road.
	for i in range(5):
		var z := -30.0 - float(i) * 9.0
		var side: float = -1.0 if i % 2 == 0 else 1.0
		var x: float = side * 6.8
		PF.cylinder(self, "connector_pole_%02d" % i, 0.22, 8.0, Vector3(x, 4.0, z), PF.material("#3b302b"), 8)
		PF.beam(self, "connector_crossarm_%02d" % i, Vector3(x - 0.9, 7.6, z), Vector3(x + 0.9, 7.6, z), 0.12, PF.material("#493a30"))
		PF.beam(self, "connector_wire_%02d" % i, Vector3(x, 7.6, z), Vector3(-side * 6.8, 7.6, z - 9.0), 0.035, PF.material("#141920", 0.5, 0.5))
		for tree_side in [-1.0, 1.0]:
			var tree_x: float = float(tree_side) * (11.0 + float((i * 3) % 5))
			var tree_height := 6.5 + float((i * 7) % 4)
			PF.cylinder(self, "connector_tree_trunk_%02d_%s" % [i, str(tree_side)], 0.35, tree_height * 0.45, Vector3(tree_x, tree_height * 0.23, z - 2.0), PF.material("#25231f"), 7)
			PF.sphere(self, "connector_tree_crown_%02d_%s" % [i, str(tree_side)], 4.3, Vector3(tree_x, tree_height * 0.68, z - 2.0), PF.material("#111f24"), 8, 5)

func _setup_existing_sets() -> void:
	truck = town.find_child("UtilityTruck", true, false)
	if truck != null:
		truck.position = truck_start
		truck.rotation.y = PI
		truck.scale = Vector3.ONE
		_add_truck_details()
	var decoy_truck := old_road.find_child("EliTruck", true, false)
	if decoy_truck != null:
		decoy_truck.visible = false
	meter_wheel = old_road.find_child("meter_wheel", true, false)
	upstairs_light = old_road.find_child("upstairs_room_light", true, false)
	line_alert = control_room.find_child("line_13_alert", true, false)
	line_trace = control_room.find_child("line_13_trace", true, false)
	for i in range(4):
		var light := town.find_child("lamp_glow_%02d" % i, true, false) as OmniLight3D
		if light != null:
			street_lights.append(light)
	# Put glazing and human figures on the street-facing side of the facade.
	for item_name in ["upstairs_window_frame", "upstairs_window", "window_mullion_vertical", "window_mullion_horizontal"]:
		var item := old_road.find_child(item_name, true, false) as MeshInstance3D
		if item != null:
			item.position.z += 0.22
	var glazing := old_road.find_child("upstairs_window", true, false) as MeshInstance3D
	if glazing != null:
		var pane := PF.material("#f3b66a", 0.22, 0.0, 1.6)
		pane.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		pane.albedo_color.a = 0.34
		glazing.material_override = pane
	for item_name in ["window_curtain_left", "window_curtain_right"]:
		var curtain := old_road.find_child(item_name, true, false) as MeshInstance3D
		if curtain != null:
			curtain.position.z = 0.9
	for item_name in ["girl_silhouette_body", "girl_silhouette_head", "girl_left_hand", "girl_middle_hand", "girl_right_hand", "double_body_silhouette", "double_head_silhouette", "double_radio_silhouette", "double_eye_left", "double_eye_right"]:
		var figure := old_road.find_child(item_name, true, false)
		if figure != null:
			figure.visible = false
	var glow := town.find_child("truck_windshield", true, false) as MeshInstance3D
	if glow != null:
		var glass := PF.material("#46717b", 0.18, 0.1, 0.08)
		glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		glass.albedo_color.a = 0.26
		glow.material_override = glass

func _add_truck_details() -> void:
	var glass := PF.material("#47737d", 0.16, 0.1, 0.05)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.albedo_color.a = 0.22
	for side in [-1.0, 1.0]:
		var side_window := PF.box(truck, "truck_side_glass_%s" % str(side), Vector3(0.055, 0.78, 0.9), Vector3(side * 1.155, 2.08, 0.95), glass)
		var door := Node3D.new()
		door.name = "truck_door_%s" % str(side)
		door.position = Vector3(side * 1.16, 1.75, 0.35)
		truck.add_child(door)
		PF.box(door, "door_panel", Vector3(0.09, 1.2, 1.2), Vector3(side * 0.015, 0, 0.48), PF.material("#293a4b", 0.5, 0.25))
		PF.box(door, "door_window", Vector3(0.045, 0.73, 0.89), Vector3(side * 0.07, 0.26, 0.48), glass)
		if side < 0.0:
			left_door = door
		else:
			right_door = door
		var headlight := SpotLight3D.new()
		headlight.name = "truck_headlight_%s" % str(side)
		headlight.position = Vector3(side * 0.72, 1.3, 2.24)
		headlight.rotation.y = PI
		headlight.light_color = Color("#ffe4ae")
		headlight.light_energy = 0.0
		headlight.spot_range = 30.0
		headlight.spot_angle = 28.0
		truck.add_child(headlight)

func _build_camera() -> void:
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#070c13")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#53647b")
	env.ambient_light_energy = 0.62
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.adjustment_enabled = true
	env.adjustment_saturation = 0.8
	env.adjustment_contrast = 1.04
	env.fog_enabled = true
	env.fog_light_color = Color("#111c29")
	env.fog_density = 0.003
	environment.environment = env
	add_child(environment)
	var moon := DirectionalLight3D.new()
	moon.name = "CloudedMoonlight"
	moon.rotation_degrees = Vector3(-34, -32, 0)
	moon.light_color = Color("#89a4c4")
	moon.light_energy = 0.52
	moon.shadow_enabled = true
	add_child(moon)
	camera = Camera3D.new()
	camera.name = "FollowingCamera"
	camera.current = true
	camera.fov = 49.0
	camera.near = 0.05
	camera.far = 240.0
	add_child(camera)

func _build_eli() -> void:
	var packed := load("res://assets/characters/eli_mercer.glb") as PackedScene
	if packed == null:
		push_error("Eli Mercer GLB is missing from the film project.")
		return
	main_eli = packed.instantiate() as Node3D
	main_eli.name = "Eli_Walking_And_Working"
	main_eli.position = Vector3(-4.4, 0.0, 14.6)
	add_child(main_eli)
	_cache_joints(main_eli, "eli_")
	if truck != null:
		driver_eli = packed.instantiate() as Node3D
		driver_eli.name = "Eli_Driving_Truck"
		driver_eli.position = Vector3(-0.36, 1.03, 0.78)
		driver_eli.rotation.y = PI
		driver_eli.scale = Vector3.ONE * 0.88
		truck.add_child(driver_eli)
		_cache_joints(driver_eli, "eli_")
		driver_eli.visible = false

func _build_townspeople() -> void:
	_add_person("Fern", "res://assets/characters/fern_garden_ranger.glb", Vector3(-5.55, 0.0, 0.0), Vector3(-5.55, 0.0, -30.0), _time_for("The town had", 0.12), 17.0, PI * 0.5)
	_add_person("Milo", "res://assets/characters/milo_rookie.glb", Vector3(5.4, 0.0, -13.0), Vector3(-4.9, 0.0, -14.0), _time_for("At 1:13 a.m.", 0.23), 6.0, -PI * 0.5)

func _add_person(label: String, path: String, start: Vector3, finish: Vector3, start_at: float, duration: float, turn_y: float) -> void:
	var packed := load(path) as PackedScene
	if packed == null:
		push_warning("Could not load town character: " + path)
		return
	var actor := packed.instantiate() as Node3D
	actor.name = label + "_Walking_Townsperson"
	actor.position = start
	add_child(actor)
	_cache_joints(actor, "fern_garden_ranger_" if label == "Fern" else "")
	people.append({"actor":actor, "start":start, "finish":finish, "begins":start_at, "ends":start_at + duration, "turn":turn_y, "phase":float(people.size()) * 1.7})

func _cache_joints(actor: Node3D, prefix: String) -> void:
	var id := actor.get_instance_id()
	var parts := {}
	parts["arm_l"] = _find_named(actor, [prefix + "left_upper_arm", prefix + "left_upper_sleeve", prefix + "left_upper_sleeve"])
	parts["arm_r"] = _find_named(actor, [prefix + "right_upper_arm", prefix + "right_upper_sleeve"])
	parts["leg_l"] = _find_named(actor, [prefix + "left_trouser", prefix + "left_leg", prefix + "left_trouser_leg"])
	parts["leg_r"] = _find_named(actor, [prefix + "right_trouser", prefix + "right_leg", prefix + "right_trouser_leg"])
	parts["head"] = _find_named(actor, [prefix + "head", prefix + "eli_head"])
	joint_cache[id] = parts

func _find_named(root: Node, candidates: Array) -> Node3D:
	for candidate in candidates:
		var part := root.find_child(str(candidate), true, false)
		if part is Node3D:
			return part
	return null

func _animate_walker(actor: Node3D, phase: float, strength: float) -> void:
	if actor == null:
		return
	# The GLBs are made from separate rigid pieces, not a skeletal rig. Keep their
	# limbs rigid and animate the complete character as one silhouette to avoid
	# joints appearing to detach while the character translates through the set.
	actor.position.y = maxf(0.0, sin(phase * 2.0) * 0.018 * strength)
	var gait_sway := sin(phase) * 0.018 * strength
	actor.rotation.z = gait_sway

func _build_window_figures() -> void:
	var girl := Node3D.new()
	girl.name = "LittleGirl_AtWindow"
	girl.position = Vector3(-0.94, 1.98, 0.68)
	old_road.add_child(girl)
	var dark := PF.material("#161c23", 0.9)
	var skin := PF.material("#bda98c", 0.8)
	PF.box(girl, "girl_body", Vector3(0.43, 0.76, 0.25), Vector3(0, 0.45, 0), dark)
	PF.sphere(girl, "girl_head", 0.39, Vector3(0, 1.04, 0), skin, 10, 7)
	var left_arm := Node3D.new()
	left_arm.name = "girl_left_arm_pivot"
	left_arm.position = Vector3(-0.26, 0.71, 0)
	girl.add_child(left_arm)
	PF.box(left_arm, "girl_left_arm", Vector3(0.13, 0.62, 0.13), Vector3(0, -0.3, 0), skin)
	var right_arm := Node3D.new()
	right_arm.name = "girl_right_arm_pivot"
	right_arm.position = Vector3(0.26, 0.71, 0)
	girl.add_child(right_arm)
	PF.box(right_arm, "girl_right_arm", Vector3(0.13, 0.62, 0.13), Vector3(0, -0.3, 0), skin)
	girl.visible = false
	little_girl = girl
	var packed := load("res://assets/characters/eli_mercer.glb") as PackedScene
	if packed != null:
		doppelganger = packed.instantiate() as Node3D
		doppelganger.name = "Eli_Doppelganger_Behind_Glass"
		doppelganger.position = Vector3(-0.15, 2.45, 0.69)
		doppelganger.rotation.y = PI
		doppelganger.scale = Vector3.ONE * 1.08
		old_road.add_child(doppelganger)
		_cache_joints(doppelganger, "eli_")
		doppelganger.visible = false

func _build_foundry_home() -> void:
	foundry_home = Node3D.new()
	foundry_home.name = "The_House_At_His_New_Address"
	foundry_home.position = Vector3(3.8, 0.0, -91.0)
	add_child(foundry_home)
	var siding := PF.material("#343b40", 0.88)
	var roof := PF.material("#1b2027", 0.92)
	PF.box(foundry_home, "rental_house_body", Vector3(8.0, 4.6, 6.0), Vector3(0, 2.3, 0), siding)
	PF.box(foundry_home, "rental_roof", Vector3(8.8, 0.36, 6.7), Vector3(0, 4.72, 0), roof)
	PF.box(foundry_home, "front_porch", Vector3(3.2, 0.22, 1.8), Vector3(2.2, 0.5, 3.35), PF.material("#403c39"))
	var glow := PF.material("#f2bb76", 0.28, 0.0, 0.0)
	glow.emission_enabled = true
	glow.emission = Color("#f2bb76")
	glow.emission_energy_multiplier = 0.0
	foundry_window = PF.box(foundry_home, "one_window_lights_up", Vector3(1.5, 1.25, 0.09), Vector3(-0.8, 3.1, 3.05), glow)
	foundry_light = OmniLight3D.new()
	foundry_light.name = "Foundry_Window_Light"
	foundry_light.position = Vector3(-0.8, 3.0, 2.55)
	foundry_light.light_color = Color("#f2ba78")
	foundry_light.light_energy = 0.0
	foundry_light.omni_range = 7.0
	foundry_home.add_child(foundry_light)
	foundry_home.visible = false

func _start_audio() -> void:
	if ResourceLoader.exists(NARRATION_PATH):
		var stream := load(NARRATION_PATH) as AudioStream
		if stream != null:
			narration = AudioStreamPlayer.new()
			narration.name = "Narration_Ryan_Qwen"
			narration.stream = stream
			narration.volume_db = -1.0
			add_child(narration)
			voice_length = stream.get_length()
			total_length = voice_length + 2.0
			narration.play()
	if ResourceLoader.exists("res://audio/night_air.wav"):
		ambience = AudioStreamPlayer.new()
		ambience.name = "Night_Air_And_Grid_Hum"
		ambience.stream = load("res://audio/night_air.wav")
		ambience.volume_db = -18.0
		add_child(ambience)
		ambience.play()
	if ResourceLoader.exists("res://audio/radio_static.wav"):
		radio_static = AudioStreamPlayer.new()
		radio_static.name = "Radio_Static_Cues"
		radio_static.stream = load("res://audio/radio_static.wav")
		radio_static.volume_db = -13.0
		add_child(radio_static)
	if ResourceLoader.exists("res://audio/electrical_snap.wav"):
		electrical_snap = AudioStreamPlayer.new()
		electrical_snap.name = "Grid_Blackout_Snap"
		electrical_snap.stream = load("res://audio/electrical_snap.wav")
		electrical_snap.volume_db = -9.0
		add_child(electrical_snap)
	radio_event_times = [
		_time_for("Mae came over the radio", 0.60),
		_time_for("Then my own voice came through", 0.68),
		_time_for("The outage board refreshed", 0.88)
	]

func _process(delta: float) -> void:
	if narration != null and narration.playing:
		elapsed = narration.get_playback_position()
	else:
		post_voice_clock += delta
		elapsed = voice_length + post_voice_clock if narration != null else post_voice_clock
	_update_people()
	_update_eli_and_truck(delta)
	_update_story_actions(delta)
	_update_camera(delta)
	_capture_review_frame()
	if elapsed >= total_length:
		get_tree().quit()

func _update_people() -> void:
	for person in people:
		var actor: Node3D = person.actor
		var start: Vector3 = person.start
		var finish: Vector3 = person.finish
		var begins: float = person.begins
		var ends: float = person.ends
		var ratio := clampf((elapsed - begins) / maxf(ends - begins, 0.01), 0.0, 1.0)
		var eased := ratio * ratio * (3.0 - 2.0 * ratio)
		actor.position = start.lerp(finish, eased)
		var facing: float = lerp_angle(0.0, float(person.turn), clampf(ratio * 3.0, 0.0, 1.0))
		actor.rotation.y = facing
		var moving := 1.0 if elapsed >= begins and elapsed < ends else 0.0
		_animate_walker(actor, elapsed * 5.8 + float(person.phase), moving)

func _update_eli_and_truck(delta: float) -> void:
	if truck != null:
		var gps_time := _time_for("My truck GPS", 0.34)
		var drive_ratio := clampf((elapsed - drive_start) / maxf(drive_end - drive_start, 0.01), 0.0, 1.0)
		var town_ratio := clampf((elapsed - drive_start) / maxf(gps_time - drive_start, 0.01), 0.0, 1.0)
		var town_ease := town_ratio * town_ratio * (3.0 - 2.0 * town_ratio)
		var feeder_ratio := clampf((elapsed - gps_time) / maxf(drive_end - gps_time, 0.01), 0.0, 1.0)
		var feeder_ease := feeder_ratio * feeder_ratio * (3.0 - 2.0 * feeder_ratio)
		truck.position = truck_start.lerp(Vector3(0, 0, -42), town_ease) if elapsed < gps_time else Vector3(0, 0, -42).lerp(truck_stop, feeder_ease)
		truck.rotation.y = PI + sin(elapsed * 0.11) * 0.018 * drive_ratio
		for wheel in truck.find_children("truck_wheel_*", "MeshInstance3D", true, false):
			wheel.rotation.x = elapsed * 3.6 * drive_ratio
		var driving := elapsed >= drive_start and elapsed < drive_end
		if driver_eli != null:
			driver_eli.visible = driving
			_animate_walker(driver_eli, elapsed * 1.8, 0.08 if driving else 0.0)
		var door_open := clampf((elapsed - exit_time) / 0.7, 0.0, 1.0) * (1.0 - clampf((elapsed - exit_time - 4.5) / 1.0, 0.0, 1.0))
		if left_door != null:
			left_door.rotation.y = -0.82 * door_open
		if right_door != null:
			right_door.rotation.y = 0.82 * door_open
		for child in truck.get_children():
			if child is SpotLight3D and child.name.begins_with("truck_headlight"):
				child.light_energy = 2.2 if elapsed >= drive_start - 0.8 and elapsed < blackout_time else 0.0
	if main_eli != null:
		var walk_start := _time_for("Dispatch said", 0.3)
		var walk_end := drive_start - 0.8
		if elapsed < walk_start:
			main_eli.position = Vector3(-4.4, 0.0, 14.6)
			main_eli.rotation.y = 0.0
			main_eli.visible = true
			_animate_walker(main_eli, elapsed * 1.4, 0.05)
		elif elapsed < walk_end:
			var p := clampf((elapsed - walk_start) / maxf(walk_end - walk_start, 0.01), 0.0, 1.0)
			main_eli.visible = true
			main_eli.position = Vector3(-4.4, 0.0, 14.6).lerp(Vector3(-1.5, 0.0, 10.0), p)
			main_eli.rotation.y = lerp_angle(0.0, PI, clampf(p * 3.0, 0.0, 1.0))
			_animate_walker(main_eli, elapsed * 5.5, 0.85)
		elif elapsed < exit_time:
			main_eli.visible = false
		else:
			main_eli.visible = true
			var approach_end := _time_for("Mae came over the radio", 0.61)
			var p2 := clampf((elapsed - exit_time) / maxf(approach_end - exit_time, 1.0), 0.0, 1.0)
			main_eli.position = truck.position.lerp(meter_position + Vector3(1.6, -0.9, 0.0), p2)
			main_eli.rotation.y = lerp_angle(PI, PI * 0.5, p2)
			_animate_walker(main_eli, elapsed * 5.8, 0.72 if p2 < 0.94 else 0.0)

func _update_story_actions(delta: float) -> void:
	if line_alert != null:
		var alarm_ratio := clampf((elapsed - _time_for("At 1:13 a.m.", 0.18)) / 2.0, 0.0, 1.0)
		line_alert.scale = Vector3.ONE * (0.82 + 0.22 * (0.5 + 0.5 * sin(elapsed * 7.2))) if alarm_ratio > 0.0 else Vector3.ONE * 0.4
	if line_trace != null:
		line_trace.visible = elapsed >= _time_for("One customer was", 0.22)
	if meter_wheel != null and elapsed >= _time_for("The meter outside", 0.44):
		meter_wheel.rotation.y = -elapsed * 7.8
	if little_girl != null:
		little_girl.visible = elapsed >= window_time
		if little_girl.visible:
			var hand_raise := clampf((elapsed - _time_for("A little girl pressed", 0.70)) / 0.85, 0.0, 1.0)
			var left_arm: Node3D = little_girl.get_node("girl_left_arm_pivot")
			var right_arm: Node3D = little_girl.get_node("girl_right_arm_pivot")
			left_arm.rotation.x = -0.75 * hand_raise + sin(elapsed * 2.2) * 0.06
			right_arm.rotation.x = -0.75 * hand_raise + sin(elapsed * 2.2 + 1.1) * 0.06
			little_girl.position.y = 1.98 + sin(elapsed * 1.3) * 0.025
	if doppelganger != null:
		doppelganger.visible = elapsed >= doppel_time and elapsed < blackout_time + 0.15
		if doppelganger.visible:
			var lean := clampf((elapsed - _time_for("He leaned close", 0.76)) / 2.0, 0.0, 1.0)
			doppelganger.rotation.y = PI + sin(elapsed * 1.1) * 0.035
			doppelganger.position.z = 0.69 + 0.14 * lean
			_animate_walker(doppelganger, elapsed * 1.5, 0.04)
			var parts: Dictionary = joint_cache.get(doppelganger.get_instance_id(), {})
			if parts.get("head") != null:
				parts.head.rotation.x = -0.11 * lean
	if upstairs_light != null:
		if elapsed >= blackout_time:
			upstairs_light.light_energy = maxf(0.0, 2.2 * (1.0 - (elapsed - blackout_time) / 0.35))
		else:
			upstairs_light.light_energy = 2.2 + sin(elapsed * 9.0) * (0.08 if elapsed > window_time else 0.0)
	if foundry_home != null:
		foundry_home.visible = elapsed >= second_call_time
		var light_rise := clampf((elapsed - second_call_time) / 0.9, 0.0, 1.0)
		if foundry_light != null:
			foundry_light.light_energy = 1.9 * light_rise
		if foundry_window != null and foundry_window.material_override is StandardMaterial3D:
			(foundry_window.material_override as StandardMaterial3D).emission_energy_multiplier = 1.1 * light_rise
	for i in street_lights.size():
		var flicker_at := blackout_time + float(i) * 0.13
		if elapsed < flicker_at:
			street_lights[i].light_energy = 1.8
		else:
			street_lights[i].light_energy = 1.8 * maxf(0.0, 1.0 - (elapsed - flicker_at) / 0.2)
	if elapsed >= blackout_time and elapsed < blackout_time + 0.15 and electrical_snap != null and last_snap_event < 0.0:
		electrical_snap.play()
		last_snap_event = elapsed
	if radio_event_cursor < radio_event_times.size() and elapsed >= radio_event_times[radio_event_cursor] and radio_static != null:
		radio_static.stop()
		radio_static.play()
		radio_event_cursor += 1

func _update_camera(delta: float) -> void:
	if camera == null:
		return
	var desired_position: Vector3
	var focus: Vector3
	var gps_time := _time_for("My truck GPS", 0.34)
	var window_focus := old_road.to_global(Vector3(-0.55, 3.18, 0.85))
	var meter_focus := old_road.to_global(Vector3(-3.61, 1.55, 0.68))
	if elapsed < drive_start:
		var walker: Vector3 = main_eli.global_position if main_eli != null else Vector3(-4.4, 0, 14.6)
		desired_position = walker + Vector3(1.9, 2.35, 4.5)
		focus = walker + Vector3(0, 1.0, 0)
	elif elapsed < exit_time:
		var road_bend := clampf((elapsed - gps_time) / 2.7, 0.0, 1.0)
		desired_position = truck.global_position + Vector3(3.2 + 1.1 * road_bend, 4.0, 14.0)
		focus = truck.global_position + Vector3(0.0, 1.0, -8.0)
	elif elapsed < blackout_time:
		var meter_view := meter_focus + Vector3(-1.1, 1.1, 5.4)
		var window_view := window_focus + Vector3(3.0, 1.0, 10.5)
		var eli_view := main_eli.global_position + Vector3(1.4, 2.15, 4.1)
		var meter_approach := clampf((elapsed - (exit_time + 0.8)) / 3.8, 0.0, 1.0)
		var window_approach_start := maxf(exit_time + 5.2, window_time - 4.5)
		var window_approach := clampf((elapsed - window_approach_start) / maxf(window_time - window_approach_start, 0.5), 0.0, 1.0)
		desired_position = eli_view.lerp(meter_view, meter_approach).lerp(window_view, window_approach)
		focus = main_eli.global_position + Vector3(0, 1.0, 0.0)
		focus = focus.lerp(meter_focus, meter_approach).lerp(window_focus, window_approach)
	elif elapsed < second_call_time:
		var window_view := window_focus + Vector3(3.0, 1.0, 10.5)
		desired_position = window_view
		focus = window_focus
	else:
		var reveal := clampf((elapsed - second_call_time) / 5.5, 0.0, 1.0)
		var home_position := foundry_home.global_position + Vector3(-1.5, 3.0, 14.0)
		var pulled_back := window_focus + Vector3(3.0, 1.0, 10.5)
		desired_position = pulled_back.lerp(home_position, reveal)
		focus = window_focus.lerp(foundry_home.global_position + Vector3(-0.8, 2.8, 2.9), reveal)
	var bob := Vector3(0, sin(elapsed * 1.3) * 0.022, 0)
	var smoothing := 1.0 - exp(-maxf(delta, 0.001) * 2.8)
	camera.global_position = camera.global_position.lerp(desired_position + bob, smoothing)
	camera.look_at(focus + Vector3(0, sin(elapsed * 0.7) * 0.018, 0), Vector3.UP)
	var zoom := clampf((elapsed - (window_time - 5.0)) / 5.0, 0.0, 1.0)
	camera.fov = lerpf(55.0, 51.0, zoom)


func _capture_review_frame() -> void:
	if review_frame_dir.is_empty() or elapsed - review_frame_time < 0.5:
		return
	review_frame_time = elapsed
	var timestamp := int(elapsed * 1000.0)
	await RenderingServer.frame_post_draw
	var frame := get_viewport().get_texture().get_image()
	if frame == null:
		return
	frame.resize(360, 640, Image.INTERPOLATE_BILINEAR)
	var path := review_frame_dir.path_join("frame-%08d.png" % timestamp)
	if frame.save_png(path + ".tmp") != OK:
		return
	if DirAccess.rename_absolute(path + ".tmp", path) != OK:
		return
	review_frame_files.append(path)
	if review_frame_files.size() > 3:
		DirAccess.remove_absolute(review_frame_files.pop_front())
