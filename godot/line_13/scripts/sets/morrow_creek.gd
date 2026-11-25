extends Node3D

const PF = preload("res://scripts/prop_factory.gd")


func _ready() -> void:
	name = "MorrowCreek"
	var asphalt := PF.material("#202833", 0.88)
	var curb := PF.material("#59616A", 0.9)
	var siding_a := PF.material("#303B49")
	var siding_b := PF.material("#4A3E3A")
	var window_dark := PF.material("#09141D", 0.3)
	var sodium := PF.material("#F1B35B", 0.45, 0.0, 1.4)
	var moon := PF.material("#B7D4E8", 0.7, 0.0, 0.3)

	PF.box(self, "night_road", Vector3(10, 0.16, 76), Vector3(0, -0.11, -12), asphalt)
	PF.box(self, "left_sidewalk", Vector3(2.8, 0.23, 76), Vector3(-6.35, -0.06, -12), curb)
	PF.box(self, "right_sidewalk", Vector3(2.8, 0.23, 76), Vector3(6.35, -0.06, -12), curb)
	for index in range(16):
		var z := 18.0 - float(index) * 4.0
		PF.box(self, "road_dash_%02d" % index, Vector3(0.09, 0.018, 1.4), Vector3(0, -0.015, z), PF.material("#B9B4A3"))

	for index in range(5):
		var z := 11.0 - float(index) * 11.0
		var left_height := 3.2 + float(index % 3) * 0.45
		var right_height := 3.4 + float((index + 1) % 3) * 0.35
		_build_shop("shop_left_%02d" % index, Vector3(-9.3, left_height * 0.5, z), Vector3(5.3, left_height, 6.2), siding_a if index % 2 == 0 else siding_b, window_dark, sodium)
		_build_shop("shop_right_%02d" % index, Vector3(9.3, right_height * 0.5, z - 4.0), Vector3(5.3, right_height, 6.2), siding_b if index % 2 == 0 else siding_a, window_dark, sodium)

	# Sparse lamps leave big pools of black between them.
	for index in range(4):
		var z: float = 13.0 - float(index) * 18.0
		var x := -5.1 if index % 2 == 0 else 5.1
		PF.cylinder(self, "lamp_post_%02d" % index, 0.17, 5.9, Vector3(x, 2.95, z), PF.material("#26323D", 0.4, 0.55), 10)
		PF.beam(self, "lamp_arm_%02d" % index, Vector3(x, 5.65, z), Vector3(x + (0.6 if x < 0 else -0.6), 5.8, z), 0.07, PF.material("#26323D", 0.4, 0.55))
		PF.sphere(self, "lamp_bulb_%02d" % index, 0.28, Vector3(x + (0.6 if x < 0 else -0.6), 5.65, z), sodium)
		var light := OmniLight3D.new()
		light.name = "lamp_glow_%02d" % index
		light.position = Vector3(x + (0.6 if x < 0 else -0.6), 5.6, z)
		light.light_color = Color("#F3AD54")
		light.light_energy = 1.8
		light.omni_range = 9.0
		add_child(light)

	# Distant tank and utility poles give the skyline a small-town silhouette.
	for side in [-1.0, 1.0]:
		var x: float = float(side) * 7.3
		for z in [1.0, -21.0, -43.0]:
			PF.cylinder(self, "power_pole_%s_%s" % [str(side), str(z)], 0.2, 8.4, Vector3(x, 4.2, z), PF.material("#493A31", 0.9), 8)
			PF.beam(self, "crossarm_%s_%s" % [str(side), str(z)], Vector3(x - 0.75, 7.4, z), Vector3(x + 0.75, 7.4, z), 0.13, PF.material("#574337", 0.9))
			PF.sphere(self, "insulator_%s_%s" % [str(side), str(z)], 0.22, Vector3(x, 7.55, z), PF.material("#BEC7C7", 0.5, 0.1))
	PF.cylinder(self, "water_tower_legs", 0.22, 8.5, Vector3(15, 4.25, -37), PF.material("#4B5960", 0.4, 0.75), 10)
	PF.cylinder(self, "water_tower_tank", 2.5, 2.1, Vector3(15, 8.65, -37), PF.material("#596871", 0.45, 0.65), 16)
	PF.cylinder(self, "water_tower_cap", 1.35, 0.16, Vector3(15, 9.8, -37), PF.material("#596871", 0.45, 0.65), 16)
	PF.label3d(self, "water_tower_name", "MORROW CREEK", Vector3(15, 8.7, -35.7), 48, Color("#C5D2D2"))
	PF.sphere(self, "moon", 3.5, Vector3(-18, 24, -46), moon, 20, 12)

	_build_utility_truck()


func _build_shop(label: String, at: Vector3, size: Vector3, siding: Material, glass: Material, sign_glow: Material) -> void:
	PF.box(self, label, size, at, siding)
	var front_z := at.z + size.z * 0.5 + 0.04
	PF.box(self, label + "_door", Vector3(1.1, 2.2, 0.08), Vector3(at.x, 1.1, front_z), PF.material("#242B32"))
	for offset in [-1.35, 1.35]:
		PF.box(self, label + "_window_%s" % str(offset), Vector3(1.45, 0.95, 0.08), Vector3(at.x + offset, 2.0, front_z), glass)
		PF.box(self, label + "_awning_%s" % str(offset), Vector3(1.75, 0.13, 0.52), Vector3(at.x + offset, 2.63, front_z + 0.18), sign_glow if at.z > 5 else PF.material("#292F37"))


func _build_utility_truck() -> void:
	var truck := Node3D.new()
	truck.name = "UtilityTruck"
	truck.position = Vector3(0, 0, 7)
	add_child(truck)
	var navy := PF.material("#24364A", 0.46, 0.3)
	var high_vis := PF.material("#E9A047", 0.5, 0.0, 0.16)
	var glass := PF.material("#1D4653", 0.24, 0.15, 0.08)
	var rubber := PF.material("#171B21", 0.9)
	PF.box(truck, "truck_chassis", Vector3(2.4, 0.45, 5.2), Vector3(0, 0.8, 0), navy)
	PF.box(truck, "truck_bed", Vector3(2.38, 1.0, 2.6), Vector3(0, 1.48, -1.45), navy)
	PF.box(truck, "truck_cab", Vector3(2.3, 1.48, 2.25), Vector3(0, 1.87, 1.0), navy)
	PF.box(truck, "truck_windshield", Vector3(2.08, 0.92, 0.07), Vector3(0, 2.08, 2.14), glass)
	PF.box(truck, "truck_grille", Vector3(1.7, 0.42, 0.1), Vector3(0, 1.02, 2.17), PF.material("#66737B", 0.4, 0.75))
	PF.box(truck, "truck_bumper", Vector3(2.5, 0.18, 0.26), Vector3(0, 0.63, 2.27), PF.material("#AEB8B8", 0.35, 0.7))
	PF.box(truck, "truck_roof_lightbar", Vector3(1.2, 0.12, 0.24), Vector3(0, 2.65, 1.0), high_vis)
	for side in [-1.0, 1.0]:
		for z in [-1.75, 1.55]:
			var wheel := PF.cylinder(truck, "truck_wheel_%s_%s" % [str(side), str(z)], 0.9, 0.34, Vector3(side * 1.18, 0.52, z), rubber, 12)
			wheel.rotation.z = PI * 0.5
		PF.box(truck, "truck_headlamp_%s" % str(side), Vector3(0.28, 0.22, 0.08), Vector3(side * 0.82, 1.36, 2.25), PF.material("#FFF1BD", 0.4, 0.0, 2.0))



