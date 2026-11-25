extends Node3D

const PF = preload("res://scripts/prop_factory.gd")

var wall: StandardMaterial3D = PF.material("#182433")
var desk_mat: StandardMaterial3D = PF.material("#3A302A")
var monitor: StandardMaterial3D = PF.material("#071B25", 0.35, 0.2)
var grid: StandardMaterial3D = PF.material("#1CE0CB", 0.3, 0.0, 1.3)
var warning: StandardMaterial3D = PF.material("#F44943", 0.3, 0.0, 1.2)
var warm: StandardMaterial3D = PF.material("#E9A94D", 0.65, 0.0, 0.2)


func _ready() -> void:
	name = "ControlRoom"
	PF.box(self, "floor", Vector3(14, 0.25, 14), Vector3(0, -0.18, 0), PF.material("#141D27"))
	PF.box(self, "back_wall", Vector3(14, 7, 0.3), Vector3(0, 3.3, -5.7), wall)
	PF.box(self, "left_wall", Vector3(0.3, 7, 11.4), Vector3(-6.9, 3.3, 0), PF.material("#111A25"))
	PF.box(self, "right_wall", Vector3(0.3, 7, 11.4), Vector3(6.9, 3.3, 0), PF.material("#111A25"))
	PF.box(self, "desk_top", Vector3(5.3, 0.24, 2.0), Vector3(0, 1.18, 0.3), desk_mat)
	PF.box(self, "desk_front", Vector3(4.9, 0.95, 0.22), Vector3(0, 0.65, -0.5), desk_mat)
	PF.box(self, "main_monitor", Vector3(4.6, 2.9, 0.14), Vector3(0, 3.25, -5.38), monitor)
	PF.box(self, "monitor_frame", Vector3(4.76, 3.05, 0.1), Vector3(0, 3.25, -5.47), PF.material("#354553", 0.4, 0.35))
	# The inset dark panel sits in front of its bezel.
	PF.box(self, "monitor_glass", Vector3(4.48, 2.78, 0.05), Vector3(0, 3.25, -5.29), monitor)
	# Line map: one live branch and the forbidden feeder glowing red.
	for index in range(7):
		var x := -1.82 + float(index) * 0.61
		PF.box(self, "grid_vertical_%02d" % index, Vector3(0.018, 2.15, 0.012), Vector3(x, 3.2, -5.24), grid)
	for index in range(5):
		var y := 2.45 + float(index) * 0.35
		PF.box(self, "grid_horizontal_%02d" % index, Vector3(3.78, 0.016, 0.012), Vector3(0, y, -5.24), grid)
	PF.box(self, "line_13_trace", Vector3(0.036, 1.78, 0.02), Vector3(0.65, 3.16, -5.2), warning)
	PF.sphere(self, "line_13_alert", 0.18, Vector3(0.65, 2.3, -5.17), warning, 12, 8)
	PF.label3d(self, "line_13_label", "FEEDER 13  /  NIGHT LOAD", Vector3(0, 4.32, -5.18), 58, Color("#A6F8EB"))
	PF.label3d(self, "alert_label", "14 OLD BELL ROAD", Vector3(0.95, 2.12, -5.15), 42, Color("#FF7169"))
	PF.box(self, "ticket_paper", Vector3(1.15, 0.04, 0.82), Vector3(-1.5, 1.34, 0.45), PF.material("#D3C8AA"))
	PF.label3d(self, "ticket_number", "13", Vector3(-1.5, 1.39, 0.45), 74, Color("#1D2934"))
	PF.cylinder(self, "desk_lamp_stem", 0.08, 0.72, Vector3(2.1, 1.65, -0.3), PF.material("#687884", 0.3, 0.6), 10)
	var lamp := OmniLight3D.new()
	lamp.name = "desk_lamp_glow"
	lamp.position = Vector3(2.1, 2.0, -0.3)
	lamp.light_color = Color("#74D9D6")
	lamp.light_energy = 0.65
	lamp.omni_range = 4.0
	add_child(lamp)
