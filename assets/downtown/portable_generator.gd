extends "res://props.gd"

const STEEL := Color("#737d7b")
const INK := Color("#252d2e")
const ORANGE := Color("#b7683c")
const LABEL := Color("#d9cfb1")

func build() -> void:
	name = "Portable Generator"
	build_frame()
	build_engine()
	build_tank()
	build_panel()

func rod(parent: Node3D,title: String,start: Vector3,finish: Vector3,radius: float,color: Color) -> void:
	var delta := finish-start
	var tube := cylinder(parent,title,start.lerp(finish,.5),radius,delta.length(),color)
	tube.quaternion = Quaternion(Vector3.UP,delta.normalized())

func build_frame() -> void:
	var frame := group(self,"Tubular steel carry frame",Vector3.ZERO)
	for x in [-.31,.31]:
		rod(frame,"Lower tube",Vector3(x,.083,-.24),Vector3(x,.083,.24),.019,INK)
		rod(frame,"Top carry rail",Vector3(x,.513,-.217),Vector3(x,.513,.217),.019,INK)
		rod(frame,"Molded carry grip",Vector3(x,.513,-.089),Vector3(x,.513,.089),.027,INK.lightened(.16))
		for z in [-.217,.217]:
			rod(frame,"Frame upright",Vector3(x,.088,z*1.105),Vector3(x,.509,z),.019,INK)
			box(frame,"Rubber skid foot",Vector3(x,.039,z),Vector3(.078,.073,.114),INK.lightened(.12))
			cylinder(frame,"Handle collar",Vector3(x,.513,signf(z)*.093),.029,.012,STEEL).rotation.x = PI/2
	for z in [-.24,.24]:
		rod(frame,"Base cross tube",Vector3(-.31,.083,z),Vector3(.31,.083,z),.019,INK)
	box(frame,"Pressed chassis tray",Vector3(0,.104,0),Vector3(.575,.035,.385),STEEL.darkened(.20))
	for x in [-.19,.19]:
		for z in [-.12,.12]:
			cylinder(frame,"Rubber engine mount",Vector3(x,.132,z),.035,.028,INK)
			cylinder(frame,"Mount washer",Vector3(x,.151,z),.025,.008,STEEL)

func build_engine() -> void:
	var engine := group(self,"Air cooled engine",Vector3(-.145,.183,0))
	box(engine,"Cast crankcase",Vector3(0,.054,0),Vector3(.231,.131,.215),STEEL)
	box(engine,"Cylinder casting",Vector3(-.012,.159,-.014),Vector3(.14,.152,.126),STEEL.darkened(.15))
	for i in range(8):
		box(engine,"Cast cooling fin",Vector3(-.012,.09+i*.018,-.014),Vector3(.184,.006,.157),STEEL.lightened(.18))
	box(engine,"Cylinder head cover",Vector3(-.012,.244,-.014),Vector3(.169,.029,.142),STEEL)
	var starter := cylinder(engine,"Recoil starter shell",Vector3(0,.081,.126),.111,.056,ORANGE.darkened(.17))
	starter.rotation.x = PI/2
	cylinder(engine,"Starter badge",Vector3(0,.081,.157),.028,.008,INK).rotation.x = PI/2
	for i in range(14):
		var angle := i*TAU/14
		var vent := box(engine,"Intake vent slot",Vector3(sin(angle)*.075,.081+cos(angle)*.075,.158),Vector3(.011,.032,.006),INK)
		vent.rotation.z = -angle
	box(engine,"Starter handle",Vector3(-.096,.148,.151),Vector3(.061,.024,.029),INK).rotation.z = -.28
	box(engine,"Exhaust heat shield",Vector3(-.023,.172,-.145),Vector3(.192,.109,.060),STEEL.darkened(.26))
	for i in range(6):
		box(engine,"Heat shield louver",Vector3(-.087+i*.025,.177,-.177),Vector3(.013,.066,.009),INK)
	var alternator := cylinder(self,"Alternator housing",Vector3(.106,.261,-.02),.113,.246,STEEL.darkened(.18))
	alternator.rotation.z = PI/2
	for i in range(7):
		box(self,"Alternator cooling rib",Vector3(.107,.355,-.072+i*.023),Vector3(.198,.013,.010),STEEL)

func build_tank() -> void:
	var tank := group(self,"Pressed steel fuel tank",Vector3(0,.437,0))
	box(tank,"Tank shell",Vector3.ZERO,Vector3(.554,.116,.342),ORANGE)
	box(tank,"Pressed shell seam",Vector3(0,-.029,0),Vector3(.564,.015,.351),ORANGE.darkened(.25))
	for x in [-.145,.145]:
		box(tank,"Tank embossing",Vector3(x,.061,0),Vector3(.022,.006,.266),ORANGE.lightened(.14))
	cylinder(tank,"Filler neck",Vector3(-.112,.065,.036),.037,.021,STEEL)
	cylinder(tank,"Knurled filler cap",Vector3(-.112,.087,.036),.042,.027,INK)
	for i in range(16):
		var angle := i*TAU/16
		var grip := box(tank,"Cap grip rib",Vector3(-.112+cos(angle)*.041,.088,.036+sin(angle)*.041),Vector3(.006,.023,.010),INK.lightened(.16))
		grip.rotation.y = -angle
	box(tank,"Fuel indicator bezel",Vector3(.108,.060,.079),Vector3(.071,.012,.038),INK)
	box(tank,"Fuel indicator window",Vector3(.108,.068,.079),Vector3(.057,.005,.022),STEEL)

func build_panel() -> void:
	var panel := group(self,"Front control panel",Vector3(.119,.287,.188))
	box(panel,"Stamped face plate",Vector3.ZERO,Vector3(.316,.191,.028),INK)
	box(panel,"Name strip",Vector3(0,.067,.017),Vector3(.272,.034,.006),STEEL.darkened(.33))
	make_label(panel,"PORTABLE GENERATOR",Vector3(0,.068,.023),31,.00054,LABEL)
	for x in [-.041,.055]:
		var socket := group(panel,"Outlet face",Vector3(x,-.013,.017))
		cylinder(socket,"Recessed outlet bezel",Vector3.ZERO,.032,.010,STEEL.darkened(.28)).rotation.x = PI/2
		cylinder(socket,"Outlet face",Vector3(0,0,.007),.026,.005,LABEL.darkened(.40)).rotation.x = PI/2
		for slot in [-.010,.010]:
			box(socket,"Outlet slot",Vector3(slot,.005,.012),Vector3(.005,.012,.004),INK)
		cylinder(socket,"Ground opening",Vector3(0,-.011,.012),.004,.004,INK).rotation.x = PI/2
	box(panel,"Main switch surround",Vector3(.118,-.013,.017),Vector3(.040,.053,.011),STEEL)
	box(panel,"Red rocker switch",Vector3(.118,-.014,.025),Vector3(.024,.035,.010),Color("#9a4135"))
	cylinder(panel,"Unlit indicator",Vector3(-.116,.016,.023),.009,.008,Color("#5d6645")).rotation.x = PI/2
	make_label(panel,"AC OUTPUT",Vector3(.010,-.061,.022),25,.00055,LABEL)
	for x in [-.143,.143]:
		for y in [-.079,.080]:
			cylinder(panel,"Face plate screw",Vector3(x,y,.016),.005,.004,STEEL).rotation.x = PI/2
