extends Node3D

const PF = preload("res://scripts/prop_factory.gd")


func _ready() -> void:
	name = "OldBellRoad"
	PF.box(self, "dark_ground", Vector3(90, 0.18, 90), Vector3(0, -0.16, -5), PF.material("#111923"))
	PF.box(self, "abandoned_road", Vector3(7.6, 0.12, 42), Vector3(0, -0.06, 9), PF.material("#252B32", 0.92))
	PF.box(self, "road_edge_left", Vector3(0.08, 0.02, 42), Vector3(-3.4, 0.01, 9), PF.material("#8A877B"))
	PF.box(self, "road_edge_right", Vector3(0.08, 0.02, 42), Vector3(3.4, 0.01, 9), PF.material("#8A877B"))
	for index in range(8):
		var z := 25.0 - float(index) * 4.3
		PF.box(self, "road_marker_%02d" % index, Vector3(0.08, 0.02, 1.15), Vector3(0, 0.015, z), PF.material("#817D70"))
	# Treeline: layered, angular silhouettes leave the house as the only warm island.
	for index in range(22):
		var side := -1.0 if index % 2 == 0 else 1.0
		var z := 22.0 - float(index) * 2.3
		var x := side * (5.5 + float(index % 3) * 1.4)
		var height := 5.8 + float(index % 4) * 1.1
		PF.cylinder(self, "tree_trunk_%02d" % index, 0.34, height * 0.42, Vector3(x, height * 0.21, z), PF.material("#211F20"), 7)
		PF.sphere(self, "tree_crown_%02d" % index, 3.3 + float(index % 2), Vector3(x, height * 0.67, z), PF.material("#17252A"), 7, 5)

	# Power pole, ceramic insulators, and a drooping service line.
	PF.cylinder(self, "pole_13", 0.3, 9.5, Vector3(-6.0, 4.75, 1.0), PF.material("#49382F"), 8)
	PF.beam(self, "pole_13_crossarm", Vector3(-7.1, 8.1, 1), Vector3(-4.9, 8.1, 1), 0.16, PF.material("#594337"))
	for x in [-6.8, -5.2]:
		PF.sphere(self, "pole_insulator_%s" % str(x), 0.33, Vector3(x, 8.32, 1), PF.material("#BBC6C6", 0.45, 0.12))
	PF.beam(self, "line_13_cable", Vector3(-5.2, 8.2, 1), Vector3(-2.6, 6.3, 0), 0.045, PF.material("#15191E", 0.5, 0.7))
	PF.label3d(self, "pole_id", "13", Vector3(-6.0, 6.5, 1.2), 60, Color("#F0C553"))

	_build_house()
	_build_hidden_double()
	_build_truck()
	_add_eli_double()


func _build_house() -> void:
	var siding := PF.material("#30313A", 0.86)
	var roof := PF.material("#20272F", 0.78)
	var warm_window := PF.material("#F4B965", 0.4, 0.0, 3.0)
	var glass_dark := PF.material("#0B1721", 0.26, 0.08)
	var wood := PF.material("#514038", 0.85)
	PF.box(self, "old_house_body", Vector3(7.1, 4.2, 5.2), Vector3(0, 2.1, -2), siding)
	PF.box(self, "old_house_foundation", Vector3(7.4, 0.38, 5.5), Vector3(0, 0.2, -2), PF.material("#464448"))
	var roof_left := PF.box(self, "roof_left", Vector3(4.0, 0.24, 6.1), Vector3(-1.0, 4.35, -2), roof)
	roof_left.rotation.z = -0.56
	var roof_right := PF.box(self, "roof_right", Vector3(4.0, 0.24, 6.1), Vector3(1.0, 4.35, -2), roof)
	roof_right.rotation.z = 0.56
	PF.box(self, "front_door", Vector3(1.25, 2.45, 0.16), Vector3(1.72, 1.45, 0.67), wood)
	PF.sphere(self, "door_knob", 0.12, Vector3(1.25, 1.46, 0.56), PF.material("#B9A178", 0.32, 0.72))
	PF.box(self, "porch", Vector3(3.3, 0.24, 2.0), Vector3(0.9, 0.48, 1.55), wood)
	for x in [-0.55, 2.35]:
		PF.box(self, "porch_post_%s" % str(x), Vector3(0.14, 2.3, 0.14), Vector3(x, 1.62, 2.15), wood)
	PF.box(self, "porch_lamp_mount", Vector3(0.32, 0.44, 0.22), Vector3(2.75, 3.12, 0.67), PF.material("#574B3C", 0.4, 0.2))
	PF.sphere(self, "porch_lamp_glow", 0.22, Vector3(2.75, 3.0, 0.48), warm_window, 10, 6)
	var porch_light := OmniLight3D.new()
	porch_light.name = "porch_light"
	porch_light.position = Vector3(2.75, 3.0, 0.3)
	porch_light.light_color = Color("#F7B568")
	porch_light.light_energy = 3.7
	porch_light.omni_range = 8.0
	add_child(porch_light)

	# The lit upstairs window is the image that carries the episode's hook.
	PF.box(self, "upstairs_window_frame", Vector3(1.75, 1.35, 0.18), Vector3(-0.55, 3.15, 0.66), PF.material("#51483F", 0.7))
	var window := PF.box(self, "upstairs_window", Vector3(1.49, 1.09, 0.07), Vector3(-0.55, 3.15, 0.54), warm_window)
	PF.box(self, "window_mullion_vertical", Vector3(0.08, 1.08, 0.04), Vector3(-0.55, 3.15, 0.48), wood)
	PF.box(self, "window_mullion_horizontal", Vector3(1.48, 0.07, 0.04), Vector3(-0.55, 3.15, 0.48), wood)
	PF.box(self, "window_curtain_left", Vector3(0.18, 1.08, 0.08), Vector3(-1.16, 3.15, 0.43), PF.material("#604642", 0.9))
	PF.box(self, "window_curtain_right", Vector3(0.18, 1.08, 0.08), Vector3(0.06, 3.15, 0.43), PF.material("#604642", 0.9))
	var room_light := OmniLight3D.new()
	room_light.name = "upstairs_room_light"
	room_light.position = Vector3(-0.55, 3.3, -0.05)
	room_light.light_color = Color("#F6B66A")
	room_light.light_energy = 2.2
	room_light.omni_range = 3.0
	add_child(room_light)
	# House number and road sign become readable in the closing close-up.
	PF.label3d(self, "house_number", "14", Vector3(2.55, 2.45, 0.58), 48, Color("#F5D5A5"))
	PF.box(self, "old_bell_sign_post", Vector3(0.14, 2.8, 0.14), Vector3(4.8, 1.4, 7.3), wood)
	PF.box(self, "old_bell_sign", Vector3(2.2, 0.62, 0.12), Vector3(4.8, 2.52, 7.3), PF.material("#18222C"))
	PF.label3d(self, "old_bell_sign_text", "OLD BELL RD", Vector3(4.8, 2.52, 7.22), 38, Color("#DAE2DF"))

	# Exterior meter: little wheel reversed by the shot director.
	PF.box(self, "service_meter_case", Vector3(0.62, 0.91, 0.18), Vector3(-3.61, 1.53, 0.61), PF.material("#879195", 0.4, 0.48))
	PF.box(self, "meter_screen", Vector3(0.42, 0.26, 0.08), Vector3(-3.61, 1.7, 0.48), PF.material("#182B31", 0.3, 0.0, 0.35))
	var meter := PF.cylinder(self, "meter_wheel", 0.34, 0.08, Vector3(-3.61, 1.38, 0.46), PF.material("#E4C06D", 0.36, 0.1, 0.1), 20)
	meter.rotation.x = PI * 0.5
	PF.label3d(self, "meter_digits", "0017", Vector3(-3.61, 1.69, 0.43), 25, Color("#BCE6D9"))

	# A small dark child silhouette stays behind the first curtain until the radio voice.
	PF.box(self, "girl_silhouette_body", Vector3(0.52, 1.05, 0.28), Vector3(-0.93, 2.6, 0.04), PF.material("#151920"))
	PF.sphere(self, "girl_silhouette_head", 0.48, Vector3(-0.93, 3.45, 0.04), PF.material("#11161C"), 10, 7)
	PF.box(self, "girl_left_hand", Vector3(0.12, 0.25, 0.1), Vector3(-1.15, 3.12, 0.32), PF.material("#D4C4A2"))
	PF.box(self, "girl_middle_hand", Vector3(0.12, 0.3, 0.1), Vector3(-0.93, 3.12, 0.32), PF.material("#D4C4A2"))
	PF.box(self, "girl_right_hand", Vector3(0.12, 0.25, 0.1), Vector3(-0.71, 3.12, 0.32), PF.material("#D4C4A2"))


func _build_hidden_double() -> void:
	var silhouette := PF.material("#111722", 0.8, 0.0, 0.06)
	PF.box(self, "double_body_silhouette", Vector3(0.82, 1.68, 0.36), Vector3(0.0, 1.0, -0.02), silhouette)
	PF.box(self, "double_head_silhouette", Vector3(0.58, 0.66, 0.4), Vector3(0.0, 2.18, -0.02), silhouette)
	PF.box(self, "double_radio_silhouette", Vector3(0.2, 0.34, 0.14), Vector3(0.34, 1.56, 0.22), PF.material("#283644"))
	var eye_glint := PF.material("#E5B25E", 0.35, 0.0, 0.25)
	PF.box(self, "double_eye_left", Vector3(0.055, 0.055, 0.03), Vector3(-0.13, 2.26, 0.21), eye_glint)
	PF.box(self, "double_eye_right", Vector3(0.055, 0.055, 0.03), Vector3(0.13, 2.26, 0.21), eye_glint)


func _build_truck() -> void:
	var truck := Node3D.new()
	truck.name = "EliTruck"
	truck.position = Vector3(1.8, 0, 7.2)
	add_child(truck)
	var navy := PF.material("#24364A", 0.46, 0.3)
	var high_vis := PF.material("#E9A047", 0.5, 0.0, 0.2)
	var rubber := PF.material("#171B21", 0.9)
	PF.box(truck, "truck_body", Vector3(2.35, 0.6, 4.8), Vector3(0, 1.0, 0), navy)
	PF.box(truck, "truck_bed", Vector3(2.3, 0.75, 2.45), Vector3(0, 1.55, -1.25), navy)
	PF.box(truck, "truck_cab", Vector3(2.28, 1.42, 2.2), Vector3(0, 1.82, 0.95), navy)
	PF.box(truck, "truck_windshield", Vector3(2.08, 0.9, 0.07), Vector3(0, 2.03, 2.04), PF.material("#183640", 0.22, 0.1, 0.04))
	PF.box(truck, "truck_roof_bar", Vector3(1.28, 0.14, 0.2), Vector3(0, 2.55, 0.95), high_vis)
	for side in [-1.0, 1.0]:
		for z in [-1.55, 1.52]:
			var wheel := PF.cylinder(truck, "wheel_%s_%s" % [str(side), str(z)], 0.84, 0.32, Vector3(side * 1.15, 0.5, z), rubber, 12)
			wheel.rotation.z = PI * 0.5
		PF.box(truck, "headlamp_%s" % str(side), Vector3(0.3, 0.22, 0.08), Vector3(side * 0.82, 1.3, 2.08), PF.material("#FFF0C0", 0.4, 0.0, 2.2))



func _add_eli_double() -> void:
	var actor_scene := load("res://assets/characters/eli_mercer.glb") as PackedScene
	if actor_scene == null:
		push_warning("Eli Mercer GLB was not imported; using the silhouette fallback.")
		return
	var actor := actor_scene.instantiate()
	actor.name = "EliDoppelganger"
	actor.position = Vector3(0.0, 0.05, 0.79)
	actor.scale = Vector3.ONE * 0.00125
	add_child(actor)
