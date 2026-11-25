extends "res://props.gd"

const SET = preload("res://assets/road_and_station.glb")
const GARAGE = preload("res://tools_and_garage.gd")
const BLUE = preload("res://assets/blue_family_bungalow.glb")
const WHITE = preload("res://assets/white_colonial.glb")
const BRICK = preload("res://assets/brick_rowhouse.glb")
const SEDAN = preload("res://assets/abandoned_tan_sedan.glb")
const WAGON = preload("res://assets/abandoned_olive_wagon.glb")
const VAN = preload("res://assets/parked_delivery_van.glb")
const PLANT = preload("res://assets/plant_horizon_silhouette.glb")
const BED = preload("res://assets/single_bed.glb")
const DRESSER = preload("res://assets/dresser.glb")
const TABLE = preload("res://assets/dining_table.glb")
const CHAIR = preload("res://assets/dining_chair.glb")
const FRIDGE = preload("res://assets/refrigerator.glb")
const BOOT_L = preload("res://assets/daniel_work_boot_left.glb")
const BOOT_R = preload("res://assets/daniel_work_boot_right.glb")
const INK := Color("#272f32")
const WOOD := Color("#8d7459")
const CREAM := Color("#d7c7a7")

var truck: Node3D
var garage: Node3D
var gamepad: Node3D
var key: Node3D
var boot: Node3D
var atlas: Node3D
var birds: Array[Node3D] = []
var smoke: Array[MeshInstance3D] = []

func _ready() -> void:
	var source := SET.instantiate()
	var original := source.find_child("WestboundPickup",true,false) as Node3D
	truck = original.duplicate()
	add_child(truck)
	source.free()
	for id in ["Windshield","Rear glass"]:
		var window := truck.find_child(id,true,false) as MeshInstance3D
		if window != null:
			var glazing := StandardMaterial3D.new()
			glazing.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			glazing.albedo_color = Color(.69,.80,.84,.12)
			window.material_override = glazing
			window.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	build_atlas()
	build_street()
	build_interior()
	build_nap_set()
	build_horizon()

func instance(resource: PackedScene, parent: Node3D, pos: Vector3, turn := 0.0) -> Node3D:
	var item := resource.instantiate() as Node3D
	parent.add_child(item)
	item.position = pos
	item.rotation.y = turn
	return item

func build_street() -> void:
	box(self,"Neighborhood lawns",Vector3(0,-.23,-56),Vector3(107,.40,152),Color("#77836b"))
	box(self,"Asphalt",Vector3(0,-.06,-56),Vector3(12.9,.13,150),Color("#424a4c"))
	for side in [-1,1]:
		box(self,"Concrete curb",Vector3(side*6.54,.065,-56),Vector3(.18,.17,150),Color("#afa993"))
		box(self,"Walkway",Vector3(side*7.24,.029,-56),Vector3(1.14,.12,150),Color("#a6a090"))
		for i in range(42):
			box(self,"Sidewalk joint",Vector3(side*7.24,.091,12-i*3),Vector3(1.13,.003,.012),Color("#6f736a"))
	for i in range(8):
		if i == 4:
			continue
		var x := 13.9 if i%2 == 0 else -14.1
		var z := -7.0-float(i)*9.8
		instance([BLUE,WHITE,BRICK][i%3],self,Vector3(x,0,z),-PI/2 if x < 0 else PI/2)
	var aunt := instance(BLUE,self,Vector3(13.5,0,-38.4),PI/2)
	aunt.name = "Aunts house exterior"
	box(self,"Driveway",Vector3(8.2,.018,-46.7),Vector3(8.0,.062,5.64),Color("#9c9d8f"))
	build_west_road()
	garage = GARAGE.new()
	add_child(garage)
	garage.position = Vector3(13.45,.002,-46.6)
	garage.rotation.y = -PI/2
	# Every parked vehicle leaves the center lane clear, including the two at an angle.
	var parking := [
		Vector3(-4.78,.008,5.0), Vector3(4.50,.008,-3.7),
		Vector3(-4.31,.008,-13.9), Vector3(4.83,.008,-25.4),
		Vector3(-4.52,.008,-34.2), Vector3(-4.90,.008,-52.0),
		Vector3(4.81,.008,-61.8), Vector3(-4.85,.008,-74.3)
	]
	for i in range(parking.size()):
		var car := instance([SEDAN,WAGON,VAN][i%3],self,parking[i])
		var angle: float = [.07,-.12,.29,-.06,-.11,.09,-.07,.03][i]
		car.rotation.y = angle + (PI if i%3==0 else 0)
	# Scattered copper leaves break up the broad road surface.
	var rng := RandomNumberGenerator.new()
	rng.seed = 41
	for i in range(90):
		var leaf := box(self,"Dry leaf",Vector3(rng.randf_range(-4.8,4.8),.014,rng.randf_range(-70,9)),Vector3(.038,.005,.065),Color("#80674e").lightened(rng.randf()*.24))
		leaf.rotation.y = rng.randf_range(-PI,PI)
	for z in [-21.0,-39.0,-58.0,-76.0]:
		cylinder(self,"Cedar utility pole",Vector3(-7.9,3.85,z),.105,7.7,WOOD.darkened(.34))
		box(self,"Cross arm",Vector3(-7.9,7.31,z),Vector3(2.3,.14,.11),WOOD.darkened(.34))
		for x in [-8.88,-7.9,-6.92]:
			cylinder(self,"Porcelain insulator",Vector3(x,7.47,z),.055,.20,CREAM)
	for x in [-8.88,-7.9,-6.92]:
		for z in [-30.0,-48.5,-67.0]:
			box(self,"Power line",Vector3(x,7.57,z),Vector3(.018,.018,19),INK)

func build_west_road() -> void:
	box(self,"Westbound terrain",Vector3(-55,-.24,-46.7),Vector3(82,.40,28),Color("#77836b"))
	box(self,"Westbound road",Vector3(-47,-.056,-46.7),Vector3(84,.13,8.4),Color("#424a4c"))
	for z in [-50.65,-42.75]:
		box(self,"White edge line",Vector3(-47,.012,z),Vector3(82,.005,.072),Color("#b9b5a5"))
	for i in range(14):
		box(self,"Yellow lane dash",Vector3(-9-i*5.5,.012,-46.7),Vector3(2.0,.005,.075),Color("#c1a762"))
	var marker := group(self,"West route marker",Vector3(-12.6,0,-41.75))
	marker.rotation.y = PI/2
	cylinder(marker,"Galvanized post",Vector3(0,1.13,0),.042,2.26,Color("#818a85"))
	box(marker,"Route sign face",Vector3(0,1.99,0),Vector3(1.21,.46,.04),Color("#315c49"))
	make_label(marker,"WEST",Vector3(0,1.99,.024),44,.0056,Color("#eee9d4"))

func build_interior() -> void:
	var house := group(self,"House interior",Vector3(31,0,-40))
	box(house,"Cutaway floor",Vector3(0,-.08,0),Vector3(8.8,.16,9.6),WOOD)
	for i in range(40):
		box(house,"Floorboard gap",Vector3(0,.001,-4.7+i*.235),Vector3(8.79,.004,.007),WOOD.darkened(.31))
	for x in [-4.32,4.32]:
		box(house,"Side wall",Vector3(x,1.4,0),Vector3(.14,2.8,9.54),Color("#afa98d"))
	box(house,"Kitchen back wall",Vector3(-2.15,1.40,-4.70),Vector3(4.31,2.80,.14),Color("#a3aa95"))
	box(house,"Bedroom back wall",Vector3(2.08,1.40,-4.70),Vector3(4.44,2.80,.14),Color("#a9a28e"))
	for z in [-3.6,1.44]:
		box(house,"Hall divider",Vector3(.36,1.4,z),Vector3(.12,2.8,2.14),Color("#a4a38e"))
	instance(TABLE,house,Vector3(-2.38,0,-2.77))
	instance(CHAIR,house,Vector3(-2.15,0,-1.89),PI)
	instance(FRIDGE,house,Vector3(-3.82,0,-4.19))
	instance(BED,house,Vector3(2.90,0,-3.58))
	instance(DRESSER,house,Vector3(1.38,0,-2.16),PI/2)
	box(house,"Hall runner",Vector3(-.11,.014,2.10),Vector3(.94,.025,3.89),Color("#656e5d"))
	var door := group(house,"Unlocked door insert",Vector3(.27,0,4.03))
	for x in [-.57,.57]:
		box(door,"Front door jamb",Vector3(x,1.13,0),Vector3(.13,2.26,.15),CREAM)
	box(door,"Door head",Vector3(0,2.24,0),Vector3(1.2,.13,.13),CREAM)
	box(door,"Threshold",Vector3(0,.041,0),Vector3(1.16,.08,.32),WOOD.darkened(.3))
	var leaf := group(door,"Open leaf",Vector3(-.50,0,0))
	leaf.rotation.y = -.65
	box(leaf,"Raised panel door",Vector3(.51,1.09,0),Vector3(1.02,2.16,.077),Color("#4a6460"))
	for y in [.54,1.55]:
		box(leaf,"Door panel",Vector3(.51,y,.049),Vector3(.77,.76,.035),Color("#59736d"))
	cylinder(leaf,"Brass knob",Vector3(.92,1.02,.084),.038,.075,Color("#b39962")).rotation.x = PI/2
	var pot := cylinder(house,"Terracotta pot",Vector3(1.11,.215,4.34),.19,.36,Color("#a4654d"))
	cylinder(pot,"Raised rim",Vector3(0,.166,0),.202,.062,Color("#ad6b51"))
	cylinder(pot,"Dry soil",Vector3(0,.193,0),.18,.022,WOOD.darkened(.42))
	key = group(house,"Spare house key",Vector3(.92,.025,4.43))
	var brass := Color("#b3a46c")
	box(key,"Key blade",Vector3(.017,0,0),Vector3(.048,.006,.016),brass)
	for i in range(3):
		box(key,"Key tooth",Vector3(.015+i*.009,0,.009),Vector3(.006,.006,.009),brass)
	var ring := TorusMesh.new()
	ring.inner_radius = .009
	ring.outer_radius = .019
	mesh(key,"Key bow",ring,Vector3(-.022,0,0),brass)
	build_gamepad(house)

func build_gamepad(house: Node3D) -> void:
	gamepad = group(house,"Cousins gamepad",Vector3(1.35,1.024,-2.14))
	var shell := SphereMesh.new()
	shell.radius = 1
	shell.height = 2
	mesh(gamepad,"Matte controller shell",shell,Vector3.ZERO,Color("#d8d5cb")).scale = Vector3(.085,.017,.052)
	for side in [-1,1]:
		var grip := mesh(gamepad,"Rounded grip",shell,Vector3(side*.060,-.003,.033),Color("#cfccbf"))
		grip.scale = Vector3(.027,.019,.056)
		grip.rotation.y = side*.28
		box(gamepad,"Shoulder trigger",Vector3(side*.057,.003,-.049),Vector3(.045,.018,.016),INK)
	for pos in [Vector3(-.023,.021,.022),Vector3(.026,.021,.022)]:
		cylinder(gamepad,"Analog stick stem",pos,.005,.013,INK)
		cylinder(gamepad,"Thumbstick cap",pos+Vector3(0,.008,0),.012,.005,INK)
	box(gamepad,"Directional pad horizontal",Vector3(-.056,.019,-.017),Vector3(.027,.005,.009),INK)
	box(gamepad,"Directional pad vertical",Vector3(-.056,.019,-.017),Vector3(.009,.005,.027),INK)
	for i in range(4):
		var angle := i*PI/2
		cylinder(gamepad,"Face button",Vector3(.054+cos(angle)*.012,.017,-.018+sin(angle)*.012),.0058,.007,[Color.SALMON,Color.SKY_BLUE,Color.SEA_GREEN,Color.GOLD][i])
	box(gamepad,"Player light off",Vector3(0,.014,-.038),Vector3(.03,.005,.006),INK)

func build_nap_set() -> void:
	var cab := group(self,"Rear seat insert",Vector3(27,0,-55))
	box(cab,"Cushion",Vector3(0,.83,.35),Vector3(1.55,.19,.52),WOOD.darkened(.20))
	box(cab,"Bench back",Vector3(0,1.14,.61),Vector3(1.55,.59,.14),WOOD.darkened(.18))
	for x in [-.46,0,.46]:
		box(cab,"Upholstery seam",Vector3(x,1.15,.537),Vector3(.010,.54,.012),WOOD.lightened(.2))
	for x in [-.82,.82]:
		box(cab,"Cab inner door",Vector3(x,1.04,0),Vector3(.092,.55,1.59),INK)
		box(cab,"Window frame",Vector3(x,1.56,-.63),Vector3(.09,.51,.10),INK)
	box(cab,"Headliner",Vector3(0,1.83,0),Vector3(1.71,.07,1.64),WOOD)
	instance(BOOT_L,cab,Vector3(.46,.94,.26),PI/2)
	instance(BOOT_R,cab,Vector3(.55,.94,.15),PI/2)
	boot = instance(BOOT_L,self,Vector3.ZERO)

func build_horizon() -> void:
	instance(PLANT,self,Vector3(-26,0,-174),.12).scale = Vector3.ONE*.32
	var hill := BoxMesh.new()
	hill.size = Vector3(120,.25,35)
	mesh(self,"Plant approach",hill,Vector3(-26,-.11,-174),Color("#7c8876"))
	var cloud := SphereMesh.new()
	cloud.radius = 1
	cloud.height = 2
	cloud.radial_segments = 12
	cloud.rings = 7
	for i in range(29):
		var puff := mesh(self,"Smoke billow",cloud,Vector3.ZERO,Color("#353e45"))
		puff.material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		puff.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		smoke.append(puff)
		puff.hide()
	for i in range(57):
		var bird := group(self,"Bird%02d" % i,Vector3.ZERO)
		var body := mesh(bird,"Body",cloud,Vector3.ZERO,INK)
		body.scale = Vector3(.064,.08,.12)
		for side in [-1,1]:
			var wing := group(bird,"Left" if side < 0 else "Right",Vector3(side*.025,0,0))
			var feather := mesh(wing,"Wing silhouette",cloud,Vector3(side*.095,0,.015),INK)
			feather.scale = Vector3(.13,.016,.051)
			feather.rotation.y = side*.20
		birds.append(bird)
		bird.hide()

func build_atlas() -> void:
	atlas = group(truck,"Map from Last Stop Fuel",Vector3(.29,1.026,.15))
	atlas.rotation.y = -.24
	box(atlas,"Open atlas pages",Vector3.ZERO,Vector3(.37,.012,.25),Color("#c6bda0"))
	box(atlas,"Spine",Vector3(0,.009,0),Vector3(.006,.004,.245),WOOD)
	for i in range(9):
		var road := box(atlas,"Printed county road",Vector3(-.149+i*.037,.009,-.029+sin(i*1.56)*.034),Vector3(.007,.002,.143),Color("#9c9985"))
		road.rotation.y = i*.51
	for i in range(4):
		var route := box(atlas,"Red hand marked route",Vector3(-.114+i*.062,.013,-.05+i*.006),Vector3(.066,.002,.005),Color("#963f37"))
		route.rotation.y = -.10
	var note := group(atlas,"Noon note",Vector3(.035,.018,.035))
	note.rotation.y = -.29
	box(note,"Folded note paper",Vector3.ZERO,Vector3(.269,.003,.104),Color("#e4d6ac"))
	var ink := make_label(note,"USE THE OLD COUNTY ROAD\nI LEFT THIS AT NOON.",Vector3(0,.003,0),30,.00059,INK)
	ink.rotation.x = -PI/2
