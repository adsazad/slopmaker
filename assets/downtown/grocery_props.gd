extends "res://props.gd"

const STEEL := Color("#909d97")
const INK := Color("#303936")
const PAPER := Color("#e1d3ac")
const BEANS := Color("#6b3b28")
const SOUP := Color("#aa6c3e")
const BLUE := Color("#507583")

func water() -> Node3D:
	var root := group(self,"Water bottles",Vector3.ZERO)
	for i in range(3):
		var bottle := group(root,"Sealed water bottle",Vector3((i-1)*.082,0,-.016 if i==1 else .02))
		bottle.rotation.y = .15*(i-1)
		var body := cylinder(bottle,"Tinted water body",Vector3(0,.094,0),.035,.145,Color(.38,.63,.67,.79))
		body.material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		body.material_override.roughness = .26
		body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		cylinder(bottle,"Molded heel",Vector3(0,.015,0),.035,.027,BLUE.lightened(.24))
		var shoulder := CylinderMesh.new()
		shoulder.top_radius = .014
		shoulder.bottom_radius = .035
		shoulder.height = .031
		shoulder.radial_segments = 24
		mesh(bottle,"Tapered shoulder",shoulder,Vector3(0,.181,0),Color("#93afb0"))
		cylinder(bottle,"Bottle neck",Vector3(0,.204,0),.014,.021,BLUE.lightened(.23))
		var cap := cylinder(bottle,"Tamper cap",Vector3(0,.218,0),.016,.014,BLUE.darkened(.12))
		for rib in range(16):
			var angle := rib*TAU/16
			box(cap,"Cap rib",Vector3(cos(angle)*.016,0,sin(angle)*.016),Vector3(.002,.012,.003),BLUE).rotation.y = -angle
		for h in [.040,.057,.130,.149]:
			cylinder(bottle,"Molded bottle rib",Vector3(0,h,0),.0355,.004,Color("#85a6a7"))
		cylinder(bottle,"Printed wrap",Vector3(0,.088,0),.0357,.042,BLUE)
		box(bottle,"Front label",Vector3(0,.089,.035),Vector3(.048,.023,.003),PAPER)
		make_label(bottle,"WATER",Vector3(0,.089,.0372),28,.00043,INK)
	return root

func beans() -> Node3D:
	return cans("Canned beans","BEANS",Color("#895637"),BEANS)

func soup() -> Node3D:
	return cans("Canned soup","SOUP",Color("#944d3c"),SOUP)

func cans(title: String,copy: String,wrapper: Color,contents: Color) -> Node3D:
	var root := group(self,title,Vector3.ZERO)
	food_can(root,Vector3(-.050,0,0),copy,wrapper,contents,false)
	food_can(root,Vector3(.048,0,-.008),copy,wrapper,contents,true)
	var lid := group(root,"Loose can lid",Vector3(.047,.004,.062))
	cylinder(lid,"Stamped tin lid",Vector3.ZERO,.036,.004,STEEL.lightened(.17))
	rim(lid,"Concentric stamp",Vector3(0,.002,0),.025,.028,STEEL.darkened(.19))
	return root

func food_can(parent: Node3D,pos: Vector3,copy: String,wrapper: Color,contents: Color,opened: bool) -> void:
	var can := group(parent,"Open can" if opened else "Sealed can",pos)
	cylinder(can,"Tin base",Vector3(0,.006,0),.038,.009,STEEL)
	cylinder(can,"Paper wrap",Vector3(0,.052,0),.037,.086,wrapper)
	for y in [.018,.085]:
		cylinder(can,"Cream stripe",Vector3(0,y,0),.0375,.006,PAPER)
	box(can,"Front label panel",Vector3(0,.052,.037),Vector3(.053,.029,.003),PAPER)
	make_label(can,copy,Vector3(0,.054,.0391),30,.00052,INK)
	rim(can,"Rolled top rim",Vector3(0,.098,0),.032,.039,STEEL.lightened(.11))
	if opened:
		cylinder(can,"Dark inner wall",Vector3(0,.095,0),.032,.006,STEEL.darkened(.46))
		cylinder(can,"Food surface",Vector3(0,.098,0),.029,.004,contents)
		for i in range(12):
			var angle := i*2.4
			var radius := .006+.021*float(i%6)/5.0
			var piece := cylinder(can,"Food piece",Vector3(cos(angle)*radius,.1005,sin(angle)*radius),.0035,.003,contents.lightened(.11+.02*(i%4)))
			piece.scale.z = .68
	else:
		cylinder(can,"Sealed tin lid",Vector3(0,.098,0),.034,.005,STEEL)
		rim(can,"Pressed lid ring",Vector3(0,.1006,0),.022,.025,STEEL.darkened(.21))

func rim(parent: Node3D,title: String,pos: Vector3,inner: float,outer: float,tint: Color) -> void:
	var shape := TorusMesh.new()
	shape.inner_radius = inner
	shape.outer_radius = outer
	mesh(parent,title,shape,pos,tint)

func opener() -> Node3D:
	var root := group(self,"Manual can opener",Vector3.ZERO)
	for side in [-1,1]:
		var arm := group(root,"Hinged handle",Vector3(0,.017,-.055))
		arm.rotation.y = side*.31
		box(arm,"Stamped lever",Vector3(0,0,.040),Vector3(.014,.008,.099),STEEL)
		var grip := box(arm,"Green rubber grip",Vector3(0,-.003,.089),Vector3(.023,.020,.078),Color("#4e6960"))
		for i in range(5):
			box(grip,"Grip texture",Vector3(0,.011,-.023+i*.011),Vector3(.018,.002,.004),INK.lightened(.20))
	box(root,"Opener head",Vector3(0,.023,-.058),Vector3(.043,.016,.043),STEEL)
	cylinder(root,"Pivot rivet",Vector3(0,.033,-.056),.009,.007,STEEL.lightened(.30))
	cylinder(root,"Toothed feed wheel",Vector3(-.019,.017,-.071),.014,.009,STEEL.darkened(.19))
	for i in range(14):
		var angle := i*TAU/14
		box(root,"Feed wheel rib",Vector3(-.019+cos(angle)*.014,.016,-.071+sin(angle)*.014),Vector3(.004,.008,.004),STEEL).rotation.y = -angle
	cylinder(root,"Cutter disk",Vector3(-.012,.011,-.057),.011,.004,STEEL.lightened(.23))
	var crank := group(root,"Hand crank",Vector3(.012,.040,-.073))
	cylinder(crank,"Crank pivot",Vector3(0,-.006,0),.007,.015,STEEL)
	box(crank,"Turning wing",Vector3(.006,.003,0),Vector3(.043,.010,.015),INK)
	cylinder(crank,"Rounded grip",Vector3(.027,.004,0),.011,.014,INK)
	return root

func dog_food() -> Node3D:
	var root := group(self,"Dog food and bowl",Vector3.ZERO)
	var bag := group(root,"Kibble bag",Vector3(-.102,0,-.05))
	build_kibble_bag(bag)
	var bowl := group(root,"Filled enamel dog bowl",Vector3(.101,0,.038))
	var shell := CylinderMesh.new()
	shell.top_radius = .079
	shell.bottom_radius = .090
	shell.height = .042
	shell.radial_segments = 28
	mesh(bowl,"Pressed blue enamel bowl",shell,Vector3(0,.024,0),BLUE)
	rim(bowl,"Rolled bowl rim",Vector3(0,.046,0),.069,.080,STEEL.lightened(.2))
	cylinder(bowl,"Kibble bed",Vector3(0,.044,0),.068,.008,BEANS)
	var rng := RandomNumberGenerator.new()
	rng.seed = 27
	for i in range(36):
		var angle := rng.randf_range(0,TAU)
		var distance := sqrt(rng.randf())*.061
		var bit := cylinder(bowl,"Kibble piece",Vector3(cos(angle)*distance,.051,sin(angle)*distance),rng.randf_range(.004,.0065),.006,BEANS.lightened(rng.randf_range(.02,.22)))
		bit.scale.z = rng.randf_range(.55,1.08)
	return root

func build_kibble_bag(bag: Node3D) -> void:
	# Width and depth vary up the bag to form a flat bottom and folded shoulders.
	var sections := [
		Vector3(.090,.006,.032), Vector3(.093,.023,.036),
		Vector3(.094,.048,.040), Vector3(.088,.173,.040),
		Vector3(.083,.202,.025), Vector3(.086,.218,.005)
	]
	var outline := [
		Vector2(-.77,1),Vector2(.77,1),Vector2(1,.66),Vector2(.87,0),
		Vector2(1,-.65),Vector2(.77,-1),Vector2(-.77,-1),Vector2(-1,-.65),
		Vector2(-.87,0),Vector2(-1,.66)
	]
	var kraft := Color("#987044")
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for row in range(sections.size()-1):
		for edge in range(outline.size()):
			var next := (edge+1)%outline.size()
			var a := bag_corner(sections[row],outline[edge])
			var b := bag_corner(sections[row],outline[next])
			var c := bag_corner(sections[row+1],outline[edge])
			var d := bag_corner(sections[row+1],outline[next])
			var tint := kraft.darkened(.19) if edge in [2,3,7,8] else kraft
			if row >= 3:
				tint = tint.lightened(.08)
			for point in [a,b,c,b,d,c]:
				surface.set_color(tint)
				surface.add_vertex(point)
	for row in [0,sections.size()-1]:
		var section: Vector3 = sections[row]
		for edge in range(outline.size()):
			for point in [Vector3(0,section.y,0),bag_corner(section,outline[edge]),
					bag_corner(section,outline[(edge+1)%outline.size()])]:
				surface.set_color(kraft.darkened(.13))
				surface.add_vertex(point)
	surface.generate_normals()
	var shell := mesh(bag,"Folded kraft paper sack",surface.commit(),Vector3.ZERO,Color.WHITE)
	shell.material_override.vertex_color_use_as_albedo = true
	shell.material_override.cull_mode = BaseMaterial3D.CULL_DISABLED

	box(bag,"Crimped top seal",Vector3(0,.222,0),Vector3(.173,.012,.012),kraft.darkened(.22))
	for i in range(36):
		box(bag,"Seal crimp",Vector3(-.083+i*.0047,.223,.0062),Vector3(.0015,.009,.001),kraft.lightened(.09))
	box(bag,"Folded lower paper seam",Vector3(0,.023,.0365),Vector3(.142,.009,.003),kraft.darkened(.23))

	var print_green := Color("#3d6257")
	box(bag,"Printed front panel",Vector3(0,.114,.0403),Vector3(.125,.109,.0012),print_green)
	box(bag,"Printed cream stripe",Vector3(0,.082,.0411),Vector3(.125,.023,.0011),PAPER)
	make_label(bag,"DOG FOOD",Vector3(0,.121,.0414),32,.00067,Color("#f4e4c0"))
	make_label(bag,"DRY KIBBLE",Vector3(0,.082,.042),27,.00052,INK)
	cylinder(bag,"Paw print pad",Vector3(0,.145,.0416),.010,.0013,PAPER).rotation.x = PI/2
	for x in [-.011,-.004,.004,.011]:
		cylinder(bag,"Paw print toe",Vector3(x,.158-absf(x)*.25,.0416),.0036,.0013,PAPER).rotation.x = PI/2
	for i in range(12):
		box(bag,"Printed barcode line",Vector3(-.022+i*.004,.045,.0408),Vector3(.0013+.0005*(i%3),.011,.001),INK)

func bag_corner(section: Vector3,point: Vector2) -> Vector3:
	return Vector3(section.x*point.x,section.y,section.z*point.y)

func cold_drinks() -> Node3D:
	var root := group(self,"Cold drink cans",Vector3.ZERO)
	var drinks := [
		["ORANGE","CITRUS FIZZ",Color("#b85c32")],
		["LIME","LIME SODA",Color("#518244")],
		["COLA","CLASSIC COLA",Color("#a3453c")]
	]
	for i in range(drinks.size()):
		var drink: Array = drinks[i]
		var color: Color = drink[2]
		var can := group(root,drink[1],Vector3((i-1)*.073,0,0))
		cylinder(can,"Printed aluminum can",Vector3(0,.059,0),.0315,.108,color)
		cylinder(can,"Rolled bottom ring",Vector3(0,.007,0),.029,.007,STEEL)
		var shoulder := CylinderMesh.new()
		shoulder.top_radius = .027
		shoulder.bottom_radius = .0315
		shoulder.height = .008
		shoulder.radial_segments = 32
		mesh(can,"Tapered can shoulder",shoulder,Vector3(0,.113,0),color.darkened(.11))
		cylinder(can,"Recessed aluminum top",Vector3(0,.118,0),.027,.004,STEEL.lightened(.19))
		rim(can,"Rolled upper rim",Vector3(0,.120,0),.025,.029,STEEL.lightened(.23))
		var tab := group(can,"Pull tab",Vector3(0,.121,0))
		rim(tab,"Pull ring",Vector3(0,.002,-.005),.0043,.0076,STEEL.lightened(.29))
		box(tab,"Tab tongue",Vector3(0,.002,.0035),Vector3(.008,.002,.008),STEEL.lightened(.29))
		cylinder(tab,"Tab rivet",Vector3(0,.004,.004),.0027,.002,STEEL)
		rim(can,"Scored opening",Vector3(0,.121,.014),.006,.0075,STEEL.darkened(.30))
		for y in [.027,.092]:
			cylinder(can,"Printed accent band",Vector3(0,y,0),.0317,.006,color.lightened(.31))
		make_label(can,drink[0],Vector3(0,.069,.0319),34,.00045,PAPER.lightened(.31))
		make_label(can,drink[1],Vector3(0,.049,.0319),27,.00032,PAPER.lightened(.31))
	return root

func chips() -> Node3D:
	var root := group(self,"Assorted chips",Vector3.ZERO)
	var brands := [
		["RIDGEWAY","SEA SALT",Color("#4b6e86"),Color("#e0c78d"),.073,.194],
		["KETTLE LANE","SMOKED BBQ",Color("#8b483b"),Color("#e1b376"),.081,.208],
		["CRUNCH CO.","CHEDDAR",Color("#b16d37"),Color("#f2d381"),.071,.178],
		["POTATO PATCH","SOUR CREAM",Color("#537c5b"),Color("#d7d6b2"),.076,.199]
	]
	for i in range(brands.size()):
		var spec: Array = brands[i]
		var color: Color = spec[2]
		var accent: Color = spec[3]
		var half_width: float = spec[4]
		var height: float = spec[5]
		var bag := group(root,spec[0],Vector3((float(i)-1.5)*.174,0,0))
		build_chip_bag(bag,half_width,height,color)
		var main_y := height*.62
		box(bag,"Printed brand field",Vector3(0,main_y,.0288),Vector3(half_width*1.40,.047,.0015),color.darkened(.24))
		make_label(bag,spec[0],Vector3(0,main_y+.007,.030),34,.00044,accent)
		make_label(bag,spec[1],Vector3(0,main_y-.012,.030),29,.00036,PAPER.lightened(.18))
		for chip in range(3):
			var wafer := cylinder(bag,"Printed chip illustration",Vector3((chip-1)*.021,.057+float(chip%2)*.006,.029),.014,.001,accent.darkened(chip*.085))
			wafer.rotation.x = PI/2
			wafer.scale.x = 1.13
	return root

func build_chip_bag(parent: Node3D,width: float,height: float,color: Color) -> void:
	var bands := [
		Vector3(width*.97,.005,.004), Vector3(width,.033,.019),
		Vector3(width*.98,.057,.028), Vector3(width*.98,height-.052,.028),
		Vector3(width,height-.025,.017),Vector3(width*.95,height-.004,.004)
	]
	var outline := [Vector2(-.77,1),Vector2(.77,1),Vector2(1,.52),Vector2(1,-.52),
		Vector2(.77,-1),Vector2(-.77,-1),Vector2(-1,-.52),Vector2(-1,.52)]
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for row in range(bands.size()-1):
		for edge in range(outline.size()):
			var next := (edge+1)%outline.size()
			var a := bag_corner(bands[row],outline[edge])
			var b := bag_corner(bands[row],outline[next])
			var c := bag_corner(bands[row+1],outline[edge])
			var d := bag_corner(bands[row+1],outline[next])
			var tint := color if edge in [0,4] else color.darkened(.12)
			for point in [a,b,c,b,d,c]:
				surface.set_color(tint)
				surface.add_vertex(point)
	surface.generate_normals()
	var shell := mesh(parent,"Folded snack wrapper",surface.commit(),Vector3.ZERO,Color.WHITE)
	shell.material_override.vertex_color_use_as_albedo = true
	shell.material_override.cull_mode = BaseMaterial3D.CULL_DISABLED
	for y in [.005,height-.005]:
		box(parent,"Heat-sealed wrapper edge",Vector3(0,y,0),Vector3(width*1.94,.010,.011),color.darkened(.18))
		for i in range(24):
			box(parent,"Seal crimp",Vector3((i-11.5)*width*.080,y,.006),Vector3(.0015,.008,.0012),color.lightened(.21))
