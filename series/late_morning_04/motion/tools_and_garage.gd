extends "res://props.gd"

const STEEL := Color("#858c89")
const RUBBER := Color("#272c2c")
const WOOD := Color("#957453")
const RED := Color("#a64935")
var case: Node3D
var pump: Node3D
var pliers: Node3D
var gauge: Node3D
var pedal: MeshInstance3D

func _ready() -> void:
	box(self,"Concrete slab",Vector3(0,-.08,0),Vector3(5.6,.16,6.4),Color("#8a8980"))
	for p in [-1.8,0,1.8]:
		box(self,"Expansion joint",Vector3(p,.002,0),Vector3(.011,.004,6.37),RUBBER)
	box(self,"Back wall",Vector3(0,1.39,-3.18),Vector3(5.62,2.8,.18),Color("#b1a590"))
	for x in [-2.74,2.74]:
		box(self,"Side wall",Vector3(x,1.39,0),Vector3(.15,2.8,6.4),Color("#baac93"))
		for i in range(8):
			box(self,"Exposed stud",Vector3(x*.965,1.39,-2.9+i*.81),Vector3(.09,2.8,.05),WOOD)
	box(self,"Roof",Vector3(0,2.88,0),Vector3(5.75,.22,6.43),WOOD)
	for z in [-2.55,-1.7,-.85,0,.85,1.7,2.55]:
		box(self,"Ceiling joist",Vector3(0,2.70,z),Vector3(5.55,.16,.065),WOOD.darkened(.16))
	for x in [-2.45,2.45]:
		box(self,"Rolling door track",Vector3(x,2.31,1.34),Vector3(.07,.06,3.6),STEEL)
		box(self,"Door jamb",Vector3(x,1.28,3.15),Vector3(.14,2.55,.21),WOOD.darkened(.32))
	for i in range(4):
		box(self,"Raised garage door panel",Vector3(0,2.41,1.56+i*.43),Vector3(4.85,.055,.42),Color("#888982"))
	box(self,"Fluorescent housing",Vector3(0,2.59,-.89),Vector3(1.35,.105,.27),STEEL)
	box(self,"Unlit diffuser",Vector3(0,2.516,-.89),Vector3(1.26,.03,.21),Color("#d0cbb5"))
	build_bench()
	build_storage()
	build_kit()

func build_bench() -> void:
	box(self,"Workbench maple top",Vector3(.25,.91,-2.72),Vector3(2.8,.12,.75),WOOD.lightened(.11))
	for x in [-1.0,1.5]:
		for z in [-2.42,-3.00]:
			box(self,"Bench leg",Vector3(x,.445,z),Vector3(.095,.89,.095),WOOD.darkened(.24))
	box(self,"Lower workbench shelf",Vector3(.25,.29,-2.72),Vector3(2.61,.07,.64),WOOD)
	box(self,"Pegboard",Vector3(.25,1.61,-3.045),Vector3(2.77,1.02,.04),WOOD.darkened(.19))
	for row in range(10):
		for col in range(27):
			box(self,"Peg hole",Vector3(-1.05+col*.10,1.15+row*.099,-3.021),Vector3(.012,.011,.003),RUBBER)
	var vise := group(self,"Bench vise",Vector3(1.31,.97,-2.47))
	box(vise,"Vise base",Vector3(0,.038,0),Vector3(.31,.07,.26),Color("#48605b"))
	for x in [-.10,.10]:
		box(vise,"Vise jaw",Vector3(x,.14,0),Vector3(.07,.155,.23),STEEL)
	cylinder(vise,"Vise screw",Vector3(0,.105,.116),.016,.33,STEEL).rotation.z = PI/2
	for i in range(7):
		var jar := cylinder(self,"Fastener jar",Vector3(-1.01+i*.145,1.025,-2.93),.048,.11,Color("#7b8271"))
		cylinder(jar,"Jar lid",Vector3(0,.059,0),.049,.019,STEEL)
	box(self,"Drawer cabinet",Vector3(-1.84,.42,-2.62),Vector3(.75,.83,.60),RED.darkened(.28))
	for i in range(5):
		var y := .175+i*.129
		box(self,"Drawer face",Vector3(-1.84,y,-2.307),Vector3(.72,.114,.021),RED.darkened(.16))
		box(self,"Chrome pull",Vector3(-1.84,y+.015,-2.277),Vector3(.23,.024,.034),STEEL)

func build_storage() -> void:
	for x in [1.95,2.54]:
		for z in [-2.24,-.07]:
			box(self,"Shelf upright",Vector3(x,1.08,z),Vector3(.055,2.15,.055),STEEL.darkened(.34))
	for y in [.21,.72,1.23,1.74]:
		box(self,"Steel shelf",Vector3(2.25,y,-1.15),Vector3(.64,.052,2.24),STEEL)
	for i in range(8):
		var pos := Vector3(2.25,.37+(i/3)*.50,-1.92+(i%3)*.67)
		box(self,"Storage carton",pos,Vector3(.48,.27,.47),WOOD.lightened(.23))
		box(self,"Packing tape",pos+Vector3(0,.138,0),Vector3(.085,.005,.47),WOOD.lightened(.45))
		make_label(self,"SPARES",pos+Vector3(0,.04,.238),24,.002,Color("#e8dbc2"))
	for z in [-.61,-.35]:
		var tire := TorusMesh.new()
		tire.inner_radius = .166
		tire.outer_radius = .326
		mesh(self,"Spare tire",tire,Vector3(-2.40,.342,z),RUBBER).rotation.x = PI/2
	for x in [-2.55,-2.27]:
		box(self,"Ladder rail",Vector3(x,1.10,-1.89),Vector3(.046,2.16,.067),STEEL).rotation.x = -.10
	for i in range(7):
		box(self,"Ladder rung",Vector3(-2.41,.25+i*.273,-1.80-i*.028),Vector3(.31,.027,.051),STEEL)
	box(self,"Dusty window frame",Vector3(-2.637,1.82,.71),Vector3(.052,.68,1.00),WOOD)
	var window := box(self,"Dusty blue pane",Vector3(-2.60,1.82,.71),Vector3(.022,.55,.87),Color("#718d95"))
	window.material_override.emission_enabled = true
	window.material_override.emission = Color("#536471")

func build_kit() -> void:
	case = group(self,"Socket set",Vector3(-.51,.978,-2.60))
	box(case,"Blow molded case",Vector3(0,.024,0),Vector3(.52,.048,.34),Color("#324442"))
	box(case,"Hinged lid",Vector3(0,.175,-.179),Vector3(.52,.302,.031),Color("#3b5650")).rotation.x = -.13
	for x in [-.18,.18]:
		box(case,"Case latch",Vector3(x,.028,.178),Vector3(.06,.024,.019),STEEL)
	for i in range(9):
		var x := -.20+i*.050
		var radius := .012+i*.0013
		cylinder(case,"Chrome socket",Vector3(x,.069,-.067),radius,.040+float(i)*.002,STEEL.lightened(.24))
		cylinder(case,"Recess",Vector3(x,.091+i*.001,-.067),radius*.61,.002,RUBBER)
	box(case,"Ratchet shank",Vector3(-.018,.068,.071),Vector3(.32,.014,.018),STEEL)
	box(case,"Ratchet grip",Vector3(.06,.070,.071),Vector3(.17,.031,.034),RUBBER)
	cylinder(case,"Ratchet head",Vector3(-.187,.071,.071),.029,.026,STEEL.lightened(.32))
	pliers = group(self,"Slip joint pliers",Vector3(.13,1.005,-2.60))
	for side in [-1,1]:
		box(pliers,"Drop forged jaw",Vector3(side*.019,.014,-.065),Vector3(.018,.034,.092),STEEL).rotation.y = side*.24
		box(pliers,"Red vinyl grip",Vector3(side*.027,.015,.047),Vector3(.021,.034,.109),RED).rotation.y = side*.23
		for i in range(4):
			box(pliers,"Jaw tooth",Vector3(side*.013,.033,-.083+i*.011),Vector3(.01,.007,.006),RUBBER)
	cylinder(pliers,"Pivot rivet",Vector3(0,.033,-.017),.020,.012,STEEL.lightened(.22))
	gauge = group(self,"Tire pressure gauge",Vector3(.51,.985,-2.57))
	cylinder(gauge,"Chrome barrel",Vector3(0,.019,0),.011,.17,STEEL.lightened(.25)).rotation.x = PI/2
	cylinder(gauge,"Valve head",Vector3(0,.019,-.084),.019,.028,STEEL).rotation.x = PI/2
	box(gauge,"Pocket clip",Vector3(.01,.028,.036),Vector3(.01,.009,.071),STEEL)
	pump = group(self,"Foot pump",Vector3(-1.37,.008,-1.69))
	for x in [-.12,.12]:
		box(pump,"Stable base rail",Vector3(x,.026,0),Vector3(.045,.052,.41),STEEL)
	var barrel := cylinder(pump,"Painted piston barrel",Vector3(0,.102,-.025),.050,.23,RED)
	barrel.rotation.x = 1.16
	cylinder(pump,"Exposed piston rod",Vector3(0,.171,.112),.016,.15,STEEL).rotation.x = 1.16
	pedal = box(pump,"Hinged foot pedal",Vector3(0,.229,.04),Vector3(.25,.035,.23),RUBBER)
	for i in range(7):
		box(pedal,"Grip rib",Vector3(0,.019,-.09+i*.03),Vector3(.21,.008,.009),STEEL.darkened(.32))
	var hose := TorusMesh.new()
	hose.inner_radius = .080
	hose.outer_radius = .096
	mesh(pump,"Air hose",hose,Vector3(.19,.041,-.02),RUBBER)
