extends "res://storefronts.gd"

const OAK = preload("res://models/round_oak.glb")
const MAPLE = preload("res://models/autumn_maple.glb")
const SEDAN = preload("res://models/abandoned_tan_sedan.glb")
const WAGON = preload("res://models/abandoned_olive_wagon.glb")
const VAN = preload("res://models/parked_delivery_van.glb")
const ASPHALT := Color("#484b47")
const CONCRETE := Color("#aaa694")
const MARK := Color("#cec9ac")
const BLOCKS := [
	[
		["Daybreak Coffee","cafe",9.4,2,"a36f56","3c5854"],
		["Riverside Pharmacy","pharmacy",8.8,1,"bcb59b","46766d"],
		["Miller Hardware","hardware",9.1,2,"a37458","744d32"],
		["Union Barbers","barber",8.1,1,"9f9178","70483d"],
		["West End Market","market",9.8,2,"988561","426457"],
		["Cedar Books","books",8.1,2,"a58c67","425853"],
		["Hearth Bakery","bakery",8.7,1,"ad805d","80533f"],
		["Main Street Laundry","laundry",8.8,2,"9a9c87","4d6466"]
	],
	[
		["Briar Sporting Arms","outfitter",10.4,2,"96705e","3e5146"],
		["Oak Street Florist","flowers",7.8,2,"a38f79","5f6c52"],
		["The Rialto","cinema",10.3,2,"ad8873","763e41"],
		["Dale Shoe Repair","repair",7.7,1,"a18e68","655e48"],
		["Juniper Cafe","cafe",9.7,2,"b19a76","795a38"],
		["Parcel and Post","post",8.8,2,"ac9c84","57666b"],
		["Main Street Dental","office",9.0,1,"a8ab98","58686e"],
		["Fox Record Shop","records",8.7,2,"9c7256","574750"]
	],
	[
		["Town Library","library",10.9,2,"bab19c","55696c"],
		["Carter Tailoring","tailor",7.6,2,"9d8e74","6e5748"],
		["Elm Diner","diner",9.4,1,"c1b198","8b584f"],
		["Merchant Apartments","brick",8.1,3,"a17761","5a5349"],
		["County Savings","bank",10.2,2,"c1b394","727663"],
		["Corner News","news",7.3,1,"b09069","715e49"],
		["Bridge Cycle Works","repair",9.0,2,"9d8c72","50686a"],
		["Walnut Antiques","antiques",9.2,2,"988064","5e5c49"]
	]
]

func _ready() -> void:
	build_grid()
	build_blocks()
	furnish_street()
	build_background()

func model(resource: PackedScene,parent: Node3D,pos: Vector3,turn := 0.0,scale_factor := 1.0) -> Node3D:
	var item := resource.instantiate() as Node3D
	parent.add_child(item)
	item.position = pos
	item.rotation.y = turn
	item.scale *= scale_factor
	return item

func build_grid() -> void:
	var grid := group(self,"Roads and footpaths",Vector3.ZERO)
	box(grid,"Town ground",Vector3(0,-.27,-59),Vector3(132,.43,161),Color("#797d68"))
	box(grid,"Main Street asphalt",Vector3(0,-.07,-59),Vector3(15.0,.14,151),ASPHALT)
	for i in range(26):
		var z := 13-i*5.55
		if absf(z+41)<6.0 or absf(z+87)<6.0:
			continue
		box(grid,"Center line dash",Vector3(0,.006,z),Vector3(.13,.006,2.4),Color("#c9a563"))
	for index in range(3):
		var back := 5.0-index*46.0
		for side in [-1.0,1.0]:
			box(grid,"Raised footpath",Vector3(side*9.67,.09,back-19),Vector3(4.33,.19,38.6),CONCRETE)
			box(grid,"Stone curb face",Vector3(side*7.55,.084,back-19),Vector3(.16,.18,38.6),MARK)
			for s in range(24):
				var z := back-.1-s*1.64
				box(grid,"Footpath seam",Vector3(side*9.67,.187,z),Vector3(4.22,.004,.014),Color("#858579"))
			box(grid,"Continuous frontage seam",Vector3(side*10.05,.189,back-19),Vector3(.014,.004,38.4),Color("#858579"))
			for stall in range(6):
				box(grid,"Parallel parking tick",Vector3(side*6.17,.007,back-2.6-stall*6.0),Vector3(1.96,.006,.075),MARK)
	for z in [-37.92,-83.92]:
		box(grid,"Side street",Vector3(0,-.086,z),Vector3(91,.16,7.22),ASPHALT.darkened(.04))
		for direction in [-1,1]:
			for i in range(10):
				box(grid,"Zebra crossing stripe",Vector3(-6.2+i*1.37,.012,z+direction*3.70),Vector3(.63,.009,1.41),MARK)
			for edge in [-1,1]:
				box(grid,"Curb ramp",Vector3(edge*8.20,.081,z+direction*3.73),Vector3(1.55,.17,1.34),CONCRETE)
				box(grid,"Tactile pad",Vector3(edge*8.15,.173,z+direction*3.54),Vector3(.96,.016,.46),Color("#ab874e"))
				for row in range(3):
					for column in range(7):
						cylinder(grid,"Tactile stud",Vector3(edge*8.15-.36+column*.12,.185,z+direction*3.54-.13+row*.13),.022,.017,Color("#b18f54"))
		cylinder(grid,"Manhole rim",Vector3(2.06,.008,z-.15),.42,.017,STEEL)
		cylinder(grid,"Manhole cover",Vector3(2.06,.019,z-.15),.376,.015,INK)
		for side in [-1,1]:
			var drain := box(grid,"Storm drain frame",Vector3(side*7.39,.023,z+4.83),Vector3(.22,.028,.56),STEEL)
			for slat in range(7):
				box(drain,"Storm grate slot",Vector3(0,.017,-.22+slat*.074),Vector3(.154,.007,.028),INK)
			var corner := group(grid,"Intersection signal",Vector3(side*7.92,.18,z+(3.0 if side>0 else -3.0)))
			cylinder(corner,"Signal pole",Vector3(0,2.15,0),.065,4.3,STEEL)
			box(corner,"Traffic signal housing",Vector3(0,3.8,.09),Vector3(.34,.95,.32),INK)
			for i in range(3):
				cylinder(corner,"Unlit signal lens",Vector3(0,4.09-i*.28,.267),.092,.04,[Color("#774740"),Color("#a18b4b"),Color("#496553")][i]).rotation.x = PI/2
			box(corner,"Pedestrian signal",Vector3(.17,2.35,0),Vector3(.26,.34,.22),INK)

func build_blocks() -> void:
	for block in range(BLOCKS.size()):
		for side in [-1,1]:
			var z := 4.35-block*46.0
			var row := group(self,"Block %s %s" % [block+1,"East" if side > 0 else "West"],Vector3.ZERO)
			for i in range(4):
				var info: Array = BLOCKS[block][i+(4 if side>0 else 0)]
				var width := float(info[2])
				var building := shop(info[0],info[1],width,int(info[3]),Color(info[4]),Color(info[5]))
				if i == 0 or i == 3:
					add_corner_windows(building,width,int(info[3]),Color(info[5]))
				building.reparent(row,false)
				building.position = Vector3(side*11.96,.10,z-width*.5)
				building.rotation.y = -side*PI/2
				z -= width+.75
			box(row,"Back alley pavement",Vector3(side*24.35,-.035,-14.6-block*46.0),Vector3(4.5,.11,37.7),ASPHALT.lightened(.07))
			dumpster(row,Vector3(side*24.46,.035,-10.85-block*46.0),side*PI/2)
			for i in range(4):
				box(row,"Loading pallet",Vector3(side*23.52,.095,-20.35-block*46.0+i*.18),Vector3(.84,.12,.12),WOOD.darkened(.29))

func furnish_street() -> void:
	var furniture := group(self,"Street furniture and vehicles",Vector3.ZERO)
	for block in range(3):
		for side in [-1,1]:
			var z := -15.4-block*46.0
			bench(furniture,Vector3(side*8.41,.184,z+3.65),-side*PI/2)
			bench(furniture,Vector3(side*8.41,.184,z-12.05),-side*PI/2)
			lamp(furniture,Vector3(side*7.89,.185,z+13.1),side)
			lamp(furniture,Vector3(side*7.89,.185,z-4.7),side)
			planter(furniture,Vector3(side*8.32,.184,z+8.18),block+side)
			planter(furniture,Vector3(side*8.32,.184,z-8.18),block-side)
			bin(furniture,Vector3(side*7.94,.185,z+1.65))
			for i in range(2):
				var rack := cylinder(furniture,"Bike rack upright",Vector3(side*(8.03+i*.40),.45,z-10.5),.027,.55,STEEL)
				cylinder(rack,"Bike rack top rail",Vector3(0,.27,.16),.027,.32,STEEL).rotation.x = PI/2
			var car := [SEDAN,WAGON,VAN][(block+2 if side<0 else block)%3] as PackedScene
			model(car,furniture,Vector3(side*5.91,.005,z+5.0),PI if side>0 else 0.0)
			var second := [VAN,SEDAN,WAGON][(block+1 if side<0 else block)%3] as PackedScene
			model(second,furniture,Vector3(side*5.77,.005,z-3.1),PI-.08 if side>0 else .12)
	var shelter := group(furniture,"Bus shelter",Vector3(8.96,.184,-92.21))
	shelter.rotation.y = -PI/2
	box(shelter,"Shelter roof",Vector3(0,2.25,0),Vector3(2.22,.14,1.02),Color("#58656a"))
	for x in [-1,1]:
		for z in [-.43,.43]:
			cylinder(shelter,"Canopy post",Vector3(x,1.13,z),.045,2.26,STEEL)
	glass(shelter,Vector3(0,1.3,-.42),Vector3(1.87,1.75,.032))
	bench(shelter,Vector3(0,0,-.18),0.0)
	box(shelter,"Route board",Vector3(.62,1.69,-.38),Vector3(.52,.61,.044),CREAM)
	make_label(shelter,"MAIN ST\nBUS STOP",Vector3(.62,1.69,-.351),30,.004,INK)
	var stand := group(furniture,"News dispenser",Vector3(-8.0,.184,-24.9))
	stand.rotation.y = PI/2
	box(stand,"Newspaper box",Vector3(0,.54,0),Vector3(.46,1.03,.38),Color("#5b767d"))
	box(stand,"Inset window",Vector3(0,.67,.20),Vector3(.36,.38,.026),INK)
	make_label(stand,"DAILY",Vector3(0,.67,.219),40,.007,CREAM)

func bench(parent: Node3D,pos: Vector3,turn: float) -> Node3D:
	var seat := group(parent,"Cast iron bench",pos)
	seat.rotation.y = turn
	for i in range(4):
		box(seat,"Seat slat",Vector3(0,.45,-.19+i*.115),Vector3(1.67,.053,.098),WOOD.lightened(.055*i))
	for i in range(4):
		var back := box(seat,"Back slat",Vector3(0,.61+i*.105,-.235-i*.018),Vector3(1.67,.087,.049),WOOD.lightened(.035*i))
		back.rotation.x = -.15
	for x in [-.70,.70]:
		for z in [-.20,.17]:
			box(seat,"Cast foot",Vector3(x,.043,z),Vector3(.13,.075,.162),INK)
			box(seat,"Curved leg upright",Vector3(x,.244,z),Vector3(.091,.41,.058),INK).rotation.x = z*.28
		box(seat,"Arm rest",Vector3(x,.65,-.012),Vector3(.092,.062,.43),INK)
		box(seat,"Back pillar",Vector3(x,.68,-.25),Vector3(.068,.55,.068),INK).rotation.x = .17
	return seat

func planter(parent: Node3D,pos: Vector3,index: int) -> void:
	var pot := group(parent,"Tree planter",pos)
	box(pot,"Stone planter",Vector3(0,.21,0),Vector3(1.18,.42,1.18),STEEL.lightened(.16))
	box(pot,"Soil",Vector3(0,.435,0),Vector3(1.02,.035,1.02),WOOD.darkened(.37))
	for s in [-1,1]:
		box(pot,"Planter coping",Vector3(s*.55,.45,0),Vector3(.092,.096,1.21),CONCRETE)
		box(pot,"Planter coping",Vector3(0,.45,s*.55),Vector3(1.21,.096,.092),CONCRETE)
	model(OAK if index%2==0 else MAPLE,pot,Vector3(0,.45,0),index*.55,.59)

func lamp(parent: Node3D,pos: Vector3,side: int) -> void:
	var post := group(parent,"Unpowered street lamp",pos)
	cylinder(post,"Cast base",Vector3(0,.22,0),.17,.44,INK)
	cylinder(post,"Fluted pole",Vector3(0,2.12,0),.06,4.0,INK)
	box(post,"Outreach arm",Vector3(-side*.30,4.09,0),Vector3(.64,.055,.058),INK)
	var shade := cylinder(post,"Lamp shade",Vector3(-side*.61,4.00,0),.24,.13,INK)
	cylinder(shade,"Clouded lamp glass",Vector3(0,-.077,0),.185,.05,CREAM.darkened(.31))

func bin(parent: Node3D,pos: Vector3) -> void:
	var root := group(parent,"Litter bin",pos)
	cylinder(root,"Bin liner",Vector3(0,.38,0),.218,.76,INK)
	for i in range(16):
		var angle := i*TAU/16
		box(root,"Steel slat",Vector3(cos(angle)*.221,.39,sin(angle)*.221),Vector3(.033,.72,.042),STEEL).rotation.y = -angle
	cylinder(root,"Bin mouth collar",Vector3(0,.78,0),.237,.077,STEEL)
	cylinder(root,"Dark opening",Vector3(0,.819,0),.183,.008,INK)

func dumpster(parent: Node3D,pos: Vector3,turn: float) -> void:
	var root := group(parent,"Alley dumpster",pos)
	root.rotation.y = turn
	box(root,"Steel hopper",Vector3(0,.62,0),Vector3(1.63,1.07,.83),Color("#485e53"))
	for i in range(2):
		var lid := box(root,"Hinged lid",Vector3(i*.78-.39,1.18,0),Vector3(.79,.091,.94),INK)
		for rib in range(4):
			box(lid,"Stamped lid rib",Vector3(-.27+rib*.17,.054,0),Vector3(.028,.02,.82),STEEL.darkened(.28))
	for x in [-.60,.6]:
		cylinder(root,"Rubber caster",Vector3(x,.073,.29),.09,.07,INK).rotation.z = PI/2

func build_background() -> void:
	var skyline := group(self,"Side streets and background blocks",Vector3.ZERO)
	box(skyline,"Extended ground",Vector3(0,-.34,-102),Vector3(238,.48,271),Color("#777c6a"))
	var colors := [Color("#94806c"),Color("#a1927a"),Color("#88796b"),Color("#b1a086")]
	for side in [-1,1]:
		for row in range(3):
			for column in range(3):
				var x: float = side*(34.0+column*12.7)
				var z := -16.9-row*46.0+float(column%2)*1.7
				var height := 6.2+float((row+column)%3)*2.2
				var block := group(skyline,"Side street commercial block",Vector3(x,0,z))
				var wall: Color = colors[(row+column)%colors.size()]
				box(block,"Brick shell",Vector3(0,height*.5,0),Vector3(11.8,height,15.4),wall)
				box(block,"Flat roof",Vector3(0,height,0),Vector3(12.1,.26,15.7),INK)
				for floor in range(int(height/2.6)):
					var y := 1.65+floor*2.45
					for bay in range(5):
						var wx := -4.65+bay*2.30
						for front in [-1,1]:
							box(block,"Window recess",Vector3(wx,y,front*7.716),Vector3(1.20,1.49,.071),Color("#505d5c"))
							box(block,"Window sill",Vector3(wx,y-.78,front*7.75),Vector3(1.36,.096,.14),CREAM.darkened(.29))
		for i in range(4):
			var x: float = side*(7.0+i*14.0)
			var height := 8.1+i%3*2.15
			box(skyline,"Far roofline",Vector3(x,height*.5,-137.5-i%2*5),Vector3(12,height,16.4),colors[i])
