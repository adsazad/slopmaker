extends Node3D

const PF = preload("res://scripts/prop_factory.gd")
@export_enum("Old Bell House", "Foundry Rental") var design := 0

func _ready() -> void:
	if design == 0:
		_build_old_bell()
	else:
		_build_rental()

func _window(parent: Node3D, x: float, y: float, z: float, w: float, h: float, lit: bool, trim: Material, glass: Material) -> void:
	PF.box(parent, "window_trim", Vector3(w + 0.20, h + 0.20, 0.16), Vector3(x,y,z), trim)
	var pane := PF.box(parent, "window_glass", Vector3(w,h,0.08), Vector3(x,y,z+0.10), glass if not lit else PF.material("#e6b77f",0.3,0,1.1))
	PF.box(parent,"vertical_mullion",Vector3(0.065,h,0.06),Vector3(x,y,z+0.16),trim)
	PF.box(parent,"horizontal_mullion",Vector3(w,0.065,0.06),Vector3(x,y,z+0.16),trim)
	PF.box(parent,"sill",Vector3(w+0.28,0.12,0.28),Vector3(x,y-h*0.5-0.12,z+0.18),trim)

func _gable(parent: Node3D, x: float, y: float, z: float, width: float, height: float, depth: float, wall: Material, trim: Material) -> void:
	PF.box(parent,"gable_face",Vector3(width,height,depth),Vector3(x,y,z),wall)
	PF.beam(parent,"gable_left_rake",Vector3(x-width*0.57,y-height*0.52,z+depth*0.55),Vector3(x,y+height*0.52,z+depth*0.55),0.10,trim)
	PF.beam(parent,"gable_right_rake",Vector3(x,y+height*0.52,z+depth*0.55),Vector3(x+width*0.57,y-height*0.52,z+depth*0.55),0.10,trim)

func _build_old_bell() -> void:
	name = "Old_Bell_Road_House"
	var siding=PF.material("#5a5148"); var trim=PF.material("#c0b39a"); var roof=PF.material("#252a30"); var glass=PF.material("#18212a",0.2,0.15)
	PF.box(self,"stone_foundation",Vector3(9.2,0.55,7.2),Vector3(0,0.3,0),PF.material("#34373a"))
	PF.box(self,"main_cottage",Vector3(8.8,4.3,6.8),Vector3(0,2.65,0),siding)
	# cross-gable roof made of two broad planes
	var a=PF.box(self,"front_roof_left",Vector3(5.2,0.28,7.8),Vector3(-1.28,5.15,0),roof); a.rotation.z=-0.53
	var b=PF.box(self,"front_roof_right",Vector3(5.2,0.28,7.8),Vector3(1.28,5.15,0),roof); b.rotation.z=0.53
	_gable(self,0,5.05,3.36,4.6,2.2,0.16,siding,trim)
	PF.box(self,"gable_roof_trim_left",Vector3(5.25,0.20,7.95),Vector3(-1.28,5.15,0.02),trim).rotation.z=-0.53
	# recessed porch, thick posts, header, steps
	PF.box(self,"porch_deck",Vector3(4.3,0.25,2.0),Vector3(1.55,0.7,4.05),PF.material("#53483d"))
	PF.box(self,"porch_header",Vector3(4.5,0.25,0.25),Vector3(1.55,3.0,4.85),trim)
	for x in [-0.5,3.6]:
		PF.box(self,"porch_post",Vector3(0.22,2.5,0.22),Vector3(x,1.85,4.75),trim)
	PF.box(self,"front_door",Vector3(1.2,2.5,0.15),Vector3(2.35,1.95,3.48),PF.material("#302a28"))
	PF.box(self,"door_panel",Vector3(0.76,1.6,0.07),Vector3(2.35,1.92,3.58),PF.material("#51413a"))
	PF.sphere(self,"brass_knob",0.11,Vector3(1.94,1.92,3.68),PF.material("#c7a667",0.3,0.7),10,6)
	_window(self,-1.15,3.25,3.48,1.22,1.45,true,trim,glass)
	_window(self,2.45,3.15,3.48,1.20,1.45,false,trim,glass)
	_window(self,-2.55,2.65,0.01,1.30,1.55,false,trim,glass)
	# angled side wing + chimney + old utility details
	PF.box(self,"side_wing",Vector3(3.4,3.4,4.4),Vector3(5.0,2.2,-0.7),PF.material("#48433f"))
	PF.box(self,"chimney",Vector3(0.85,3.2,0.95),Vector3(-2.8,6.3,-1.45),PF.material("#54483d"))
	PF.box(self,"chimney_cap",Vector3(1.05,0.2,1.12),Vector3(-2.8,7.95,-1.45),trim)
	PF.box(self,"meter_box",Vector3(0.62,0.9,0.25),Vector3(-4.47,1.6,1.2),PF.material("#758181",0.4,0.5))
	PF.box(self,"front_steps",Vector3(2.2,0.24,0.75),Vector3(1.5,0.35,5.25),PF.material("#66605a"))
	PF.box(self,"yard_slab",Vector3(14,0.18,12),Vector3(0,-0.15,0),PF.material("#35383a"))

func _build_rental() -> void:
	name = "Foundry_Rental_House"
	var wall=PF.material("#77766d"); var trim=PF.material("#dad1bc"); var roof=PF.material("#303640"); var glass=PF.material("#17222a",0.2,0.1)
	PF.box(self,"raised_foundation",Vector3(8.8,0.45,6.8),Vector3(0,0.25,0),PF.material("#4b4b49"))
	PF.box(self,"rental_body",Vector3(8.4,3.8,6.4),Vector3(0,2.35,0),wall)
	var l=PF.box(self,"roof_left",Vector3(5.1,0.25,7.3),Vector3(-1.22,4.7,0),roof); l.rotation.z=-0.49
	var r=PF.box(self,"roof_right",Vector3(5.1,0.25,7.3),Vector3(1.22,4.7,0),roof); r.rotation.z=0.49
	_gable(self,0,4.62,3.17,4.3,1.65,0.13,wall,trim)
	PF.box(self,"front_door",Vector3(1.1,2.35,0.16),Vector3(2.4,1.65,3.3),PF.material("#3c3532"))
	_window(self,-1.45,2.75,3.3,1.5,1.45,true,trim,glass)
	_window(self,0.75,2.75,3.3,1.45,1.45,false,trim,glass)
	PF.box(self,"porch_roof",Vector3(4.0,0.22,1.6),Vector3(1.2,3.15,4.0),roof)
	for x in [-0.7,3.1]: PF.box(self,"porch_column",Vector3(0.18,2.6,0.18),Vector3(x,1.75,4.55),trim)
	PF.box(self,"front_steps",Vector3(2.2,0.22,0.7),Vector3(1.2,0.35,4.85),PF.material("#77736d"))
	PF.box(self,"garage_wing",Vector3(3.4,2.8,4.8),Vector3(5.0,1.8,-0.2),PF.material("#68685f"))
	PF.box(self,"garage_door",Vector3(2.7,2.1,0.12),Vector3(5.0,1.35,2.25),trim)
	for y in [0.65,1.05,1.45,1.85]: PF.box(self,"garage_panel_line",Vector3(2.45,0.035,0.04),Vector3(5.0,y,2.33),PF.material("#88877d"))
	PF.box(self,"yard_slab",Vector3(14,0.18,12),Vector3(0,-0.15,0),PF.material("#454643"))
