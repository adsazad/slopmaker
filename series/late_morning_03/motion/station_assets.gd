extends Node3D

const ROAD = preload("res://assets/road_and_station.glb")
const CONTINUITY = preload("res://assets/continuity_props.glb")
const LEFT_BOOT = preload("res://assets/daniel_work_boot_left.glb")
const RIGHT_BOOT = preload("res://assets/daniel_work_boot_right.glb")
const INK := Color("#252c2c")
const STEEL := Color("#777e7b")
const RUST := Color("#87543c")
const CREAM := Color("#dbcbae")
const RED := Color("#af4a39")

var world: Node3D
var pickup: Node3D
var dog: Node3D
var radio: Node3D
var police_radio: Node3D
var cans: Array[Node3D] = []
var forecourt_can: Node3D
var rigged_hose: Node3D
var hand: Node3D
var sleeve: MeshInstance3D

func _ready() -> void:
	world = ROAD.instantiate()
	add_child(world)
	pickup = world.find_child("WestboundPickup", true, false)
	dog = world.find_child("DanielDog", true, false)
	var props := CONTINUITY.instantiate()
	radio = props.find_child("CabRadio", true, false)
	radio.owner = null
	radio.get_parent().remove_child(radio)
	pickup.add_child(radio)
	radio.position = Vector3(.14, .89, -.30)
	props.free()
	for obsolete in ["CounterMap", "CounterNote", "CargoWaterA", "CargoWaterB"]:
		world.find_child(obsolete, true, false).hide()
	for glass_name in ["Windshield", "Rear glass"]:
		var pane := pickup.find_child(glass_name, true, false) as MeshInstance3D
		if pane != null:
			var clear := StandardMaterial3D.new()
			clear.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			clear.albedo_color = Color(.58,.74,.82,.14)
			clear.roughness = .25
			pane.material_override = clear
			pane.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	build_tank_yard()
	build_shop_stock()
	build_police_van()
	build_cab_insert()
	build_fuel_props()
	build_hand()

func group(parent: Node3D, title: String, pos: Vector3) -> Node3D:
	var item := Node3D.new()
	item.name = title
	parent.add_child(item)
	item.position = pos
	return item

func mesh(parent: Node3D, title: String, geom: Mesh, pos: Vector3, color: Color) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	item.name = title
	item.mesh = geom
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = .82
	item.material_override = mat
	parent.add_child(item)
	item.position = pos
	return item

func box(parent: Node3D, title: String, pos: Vector3, dimensions: Vector3, color: Color) -> MeshInstance3D:
	var geom := BoxMesh.new()
	geom.size = dimensions
	return mesh(parent, title, geom, pos, color)

func cylinder(parent: Node3D, title: String, pos: Vector3, radius: float, height: float, color: Color) -> MeshInstance3D:
	var geom := CylinderMesh.new()
	geom.top_radius = radius
	geom.bottom_radius = radius
	geom.height = height
	geom.radial_segments = 24
	return mesh(parent, title, geom, pos, color)

func make_label(parent: Node3D, copy: String, pos: Vector3, size: int, pixel: float, color: Color) -> Label3D:
	var label := Label3D.new()
	label.text = copy
	label.font_size = size
	label.pixel_size = pixel
	label.outline_size = 0
	label.modulate = color
	parent.add_child(label)
	label.position = pos
	return label

func build_tank_yard() -> void:
	var yard := group(self, "StorageTankYard", Vector3(24, 0, -269))
	box(yard, "ConcretePad", Vector3(0,.03,0), Vector3(8,.12,7), STEEL.darkened(.25))
	for z in [-1.65, 1.2]:
		for x in [-1.9, 1.9]:
			box(yard, "TankSaddle", Vector3(x,.42,z), Vector3(.48,.78,1.47), INK)
		cylinder(yard, "TankShell", Vector3(0,1.27,z), .89, 5.25, CREAM).rotation.z = PI / 2
		for x in [-2.62, 2.62]:
			var dome := SphereMesh.new()
			dome.radius = .89
			dome.height = 1.78
			mesh(yard, "DishedEnd", dome, Vector3(x,1.27,z), CREAM).scale.x = .30
		for x in [-1.7, .08, 1.7]:
			cylinder(yard, "WeldBand", Vector3(x,1.27,z), .905, .05, STEEL).rotation.z = PI / 2
		cylinder(yard, "Riser", Vector3(1.2,2.29,z), .09, .33, STEEL)
		cylinder(yard, "RiserCap", Vector3(1.2,2.47,z), .15, .06, RUST)
		make_label(yard, "FLAMMABLE", Vector3(0,1.44,z+.907), 40, .0050, RED)
	for x in [-3.7,-1.85,0,1.85,3.7]:
		cylinder(yard, "SteelPost", Vector3(x,.75,3.1), .036, 1.5, STEEL)
	for y in [.31, .82, 1.45]:
		box(yard, "FenceRail", Vector3(0,y,3.1), Vector3(7.4,.045,.045), STEEL)
	for x in range(-36, 37):
		box(yard, "FenceWire", Vector3(x*.10,.88,3.1), Vector3(.009,1.16,.009), STEEL)
	box(yard, "WarningPlate", Vector3(0,1.1,3.13), Vector3(.69,.26,.018), CREAM)
	make_label(yard, "KEEP CLEAR", Vector3(0,1.1,3.145), 35, .003, RED)

func build_shop_stock() -> void:
	var shelf := group(self, "SnackDisplay", Vector3(14.55,.16,-263.4))
	box(shelf, "PegboardBack", Vector3(0,.78,-.19), Vector3(1.34,1.56,.04), CREAM.darkened(.28))
	for h in [.25,.64,1.03]:
		box(shelf, "ShelfDeck", Vector3(0,h,0), Vector3(1.37,.038,.43), STEEL)
		box(shelf, "PriceRail", Vector3(0,h,.216), Vector3(1.37,.045,.02), CREAM)
	for i in range(7):
		var x := (i-3)*.16
		make_label(shelf, "2.49", Vector3(x,1.03,.229), 25, .0015, INK)
		if i != 4:
			snack(shelf, Vector3(x,1.17,.03), i)
		if i != 2:
			food_can(shelf, Vector3(x,.725,.07), i)
			food_can(shelf, Vector3(x,.725,-.065), i + 1)
	for i in [0, 2, 3, 6]:
		snack(shelf, Vector3((i-3)*.17,.39,.04), i + 1)
	var bag := group(pickup, "CabSnacks", Vector3(.45,1.03,.04))
	snack(bag, Vector3.ZERO, 0).rotation.x = PI / 2
	food_can(bag, Vector3(.15,.04,.08), 2)
	bag.hide()

func snack(parent: Node3D, pos: Vector3, i: int) -> Node3D:
	var colors := [Color("#ba673a"), Color("#526c58"), Color("#914838")]
	var bag := group(parent, "CrispsPacket", pos)
	var shape := SphereMesh.new()
	shape.radius = 1.0
	shape.height = 2.0
	mesh(bag, "PuffedFoil", shape, Vector3.ZERO, colors[i % 3]).scale = Vector3(.069,.119,.030)
	for y in [-.106,.106]:
		box(bag, "CrimpedSeal", Vector3(0,y,0), Vector3(.12,.013,.038), colors[i % 3].darkened(.23))
	make_label(bag, "CRISPS", Vector3(0,.018,.031), 36, .00085, CREAM)
	make_label(bag, "SEA SALT", Vector3(0,-.039,.029), 26, .00065, CREAM)
	return bag

func food_can(parent: Node3D, pos: Vector3, i: int) -> void:
	var can := group(parent, "FoodCan", pos)
	cylinder(can, "LabeledBody", Vector3.ZERO, .047,.138, [RED, CREAM, Color("#537263")][i % 3])
	for y in [-.069,.069]:
		cylinder(can, "RolledRim", Vector3(0,y,0), .049,.009, STEEL)
	box(can, "PullTab", Vector3(0,.076,.009), Vector3(.021,.003,.032), STEEL.lightened(.24))
	make_label(can, "BEANS", Vector3(0,.002,.048), 27, .00074, INK)

func build_police_van() -> void:
	var van := world.find_child("parked_delivery_van_006", true, false) as Node3D
	if van == null:
		for child in world.get_children():
			if child is Node3D and child.position.distance_to(Vector3(22.8,0,-260)) < .10:
				van = child
				break
	if van == null:
		push_error("Could not locate the station van")
		return
	van.rotation.y = PI / 2
	var livery := group(self, "PoliceVanLivery", van.position)
	livery.rotation.y = van.rotation.y
	for side in [-1,1]:
		var stripe := box(livery, "ReflectiveDoorStripe", Vector3(side*.96,1.15,-.44), Vector3(.018,.34,2.15), Color("#24384d"))
		var label := make_label(livery, "COUNTY POLICE", stripe.position+Vector3(side*.015,0,0), 44, .0039, CREAM)
		label.rotation.y = side * PI/2
	box(livery,"LightbarMount",Vector3(0,2.34,.32),Vector3(1.58,.09,.25),INK)
	for x in [-.53,.53]:
		box(livery, "UnlitLightbarLens", Vector3(x,2.43,.32),Vector3(.48,.11,.23), Color("#334d69") if x > 0 else RED)
	police_radio = group(livery, "PoliceHandheld", Vector3(.83,1.18,.75))
	box(police_radio,"RubberBody", Vector3.ZERO, Vector3(.084,.19,.051),INK)
	box(police_radio,"UnlitLCD",Vector3(0,.045,.029),Vector3(.051,.028,.004),Color("#6c796c"))
	for y in range(5):
		box(police_radio,"SpeakerVent",Vector3(0,-.047+y*.008,.028),Vector3(.053,.003,.004),STEEL)
	cylinder(police_radio,"Antenna",Vector3(-.028,.187,0),.007,.19,INK)
	cylinder(police_radio,"VolumeKnob",Vector3(.024,.105,0),.014,.028,STEEL)
	box(police_radio,"PushToTalk",Vector3(-.044,.038,0),Vector3(.009,.044,.028),INK.lightened(.22))

func build_cab_insert() -> void:
	# Separate close-up set lets the camera sit at back-seat height.
	var cab := group(self, "RearCabCloseup", Vector3(35,0,-249))
	box(cab,"RubberFootwell",Vector3(0,.62,0),Vector3(1.75,.10,1.67),INK)
	box(cab,"BenchCushion",Vector3(0,.82,.33),Vector3(1.57,.24,.57),Color("#634d40"))
	box(cab,"SeatBack",Vector3(0,1.14,.62),Vector3(1.58,.62,.13),Color("#735849"))
	for x in [-.71,-.42,0,.42,.71]:
		box(cab,"UpholsteryStitch",Vector3(x,1.13,.548),Vector3(.006,.51,.007),CREAM.darkened(.31))
	for x in [-.84,.84]:
		box(cab,"InnerDoorCard",Vector3(x,1.0,0),Vector3(.08,.58,1.54),Color("#55554b"))
		box(cab,"DoorPull",Vector3(x*.91,1.24,.14),Vector3(.07,.065,.27),INK)
		box(cab,"WindowLowerTrim",Vector3(x,1.31,0),Vector3(.10,.05,1.56),INK)
		box(cab,"Pillar",Vector3(x,1.57,-.71),Vector3(.09,.57,.11),INK)
	for x in [-.39,.39]:
		box(cab,"FrontSeatBack",Vector3(x,1.13,-.46),Vector3(.49,.66,.14),Color("#6a5345"))
		box(cab,"Headrest",Vector3(x,1.50,-.46),Vector3(.25,.20,.13),Color("#6a5345"))
	box(cab,"Headliner",Vector3(0,1.80,0),Vector3(1.73,.06,1.65),Color("#817a69"))

	for i in range(2):
		var boot: Node3D = (LEFT_BOOT if i == 0 else RIGHT_BOOT).instantiate()
		cab.add_child(boot)
		boot.position = Vector3(.44+i*.15,.96,.30-i*.10)
		boot.rotation_degrees = Vector3(-6,82,14)
		box(cab, "DenimCuff", Vector3(.34+i*.13,1.02,.30-i*.10), Vector3(.16,.13,.14), Color("#373f48"))

func build_fuel_props() -> void:
	for i in range(2):
		var can := group(pickup, "FuelCan%d" % i, Vector3(-.43+i*.36,.747,-1.46))
		var color := RED.darkened(i*.18)
		box(can,"PressedSteelBody",Vector3(0,.21,0),Vector3(.28,.40,.17),color)
		for side in [-1,1]:
			for tilt in [-1,1]:
				box(can,"ReinforcingRib",Vector3(0,.20,side*.089),Vector3(.021,.32,.013),color.lightened(.1)).rotation.z = tilt*.50
		for x in [-.085,.045]:
			box(can,"HandleSupport",Vector3(x,.43,0),Vector3(.03,.07,.043),color)
		box(can,"CarryHandle",Vector3(-.02,.47,0),Vector3(.17,.034,.044),color)
		cylinder(can,"FuelCap",Vector3(.103,.427,.008),.036,.037,INK)
		make_label(can,"FUEL",Vector3(0,.30,.097),30,.003,CREAM)
		cans.append(can)
	cans[1].hide()
	forecourt_can = cans[0].duplicate()
	add_child(forecourt_can)
	forecourt_can.position = Vector3(22.47,.032,-251.07)
	forecourt_can.rotation.y = -.37
	forecourt_can.hide()
	var hose := group(self,"RecoveredHose",Vector3(20.6,.10,-256))
	var coil := TorusMesh.new()
	coil.inner_radius = .157
	coil.outer_radius = .18
	for i in range(3):
		mesh(hose,"RubberCoil",coil,Vector3(i*.015,i*.02,0),INK)
	rigged_hose = group(self,"ParkedCarFuelHose",Vector3.ZERO)
	var curve := Curve3D.new()
	curve.add_point(Vector3(23.03,.77,-251.49),Vector3.ZERO,Vector3(-.28,-.06,.13))
	curve.add_point(Vector3(22.37,.42,-251.02),Vector3(.12,.16,-.12),Vector3(.05,-.08,-.09))
	curve.add_point(Vector3(22.56,.478,-251.07),Vector3(-.10,.03,.03))
	var points := curve.get_baked_points()
	for i in range(points.size()-1):
		var a := points[i]
		var b := points[i+1]
		var piece := cylinder(rigged_hose,"HoseSection",a.lerp(b,.5),.010,a.distance_to(b)+.004,INK)
		piece.quaternion = Quaternion(Vector3.UP,(b-a).normalized())
	rigged_hose.hide()
	var stone := SphereMesh.new()
	stone.radial_segments = 6
	stone.rings = 3
	mesh(self,"ForecourtStone",stone,Vector3(20.89,.05,-255.78),STEEL).scale = Vector3(.13,.08,.11)

func build_hand() -> void:
	var skin := Color("#b48465")
	var shape := SphereMesh.new()
	shape.radius = .5
	shape.height = 1.0
	hand = group(self,"DanielRightHand",Vector3.ZERO)
	mesh(hand,"Palm",shape,Vector3.ZERO,skin).scale = Vector3(.085,.105,.042)
	for i in range(4):
		var finger := mesh(hand,"Finger",shape,Vector3((i-1.5)*.019,.052,.016),skin)
		finger.scale = Vector3(.018,.054-i*.004,.020)
		finger.rotation.x = .58
	var thumb := mesh(hand,"Thumb",shape,Vector3(-.047,.011,.012),skin)
	thumb.scale = Vector3(.028,.058,.026)
	thumb.rotation.z = .66
	sleeve = mesh(self,"WorkJacketSleeve",shape,Vector3.ZERO,Color("#46565b"))
	hand.hide()
	sleeve.hide()

func reach(from: Vector3, to: Vector3) -> void:
	var axis := (to-from).normalized()
	hand.global_position = to
	hand.quaternion = Quaternion(Vector3.UP, axis)
	sleeve.global_position = from.lerp(to,.46)
	sleeve.quaternion = hand.quaternion
	sleeve.scale = Vector3(.102,from.distance_to(to)*1.12,.094)
	hand.show()
	sleeve.show()
