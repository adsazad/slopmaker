extends "res://props.gd"

const INK := Color("#303632")
const BRASS := Color("#b29058")
const CREAM := Color("#ded0ab")
const WOOD := Color("#986e48")
const STEEL := Color("#676e69")

func shop(title: String, style: String, width: float, floors: int, wall: Color, trim: Color) -> Node3D:
	var root := group(self,title,Vector3.ZERO)
	var height := 3.5+floors*2.64
	var depth := 10.9
	box(root,"Stone foundation",Vector3(0,.08,-depth*.5),Vector3(width,.17,depth),STEEL)
	box(root,"Ground floor",Vector3(0,.16,-depth*.5),Vector3(width-.14,.13,depth-.14),CREAM.darkened(.17))
	for x in [-width*.5+.13,width*.5-.13]:
		box(root,"Side party wall",Vector3(x,height*.5,-depth*.5),Vector3(.26,height,depth),wall.darkened(.13))
	box(root,"Rear wall",Vector3(0,height*.5,-depth+.09),Vector3(width,height,.19),wall.darkened(.25))
	box(root,"Ceiling over retail",Vector3(0,3.54,-depth*.5),Vector3(width,.18,depth),wall.darkened(.18))
	box(root,"Roof slab",Vector3(0,height,-depth*.5),Vector3(width+.11,.24,depth+.16),INK)
	box(root,"Storefront header",Vector3(0,3.21,-.05),Vector3(width,.63,.30),wall)
	for x in [-width*.5+.23,width*.5-.23]:
		box(root,"Front pilaster",Vector3(x,1.68,-.05),Vector3(.46,3.35,.31),wall)
		box(root,"Pilaster cap",Vector3(x,2.76,.13),Vector3(.53,.13,.23),trim)
	var shop_width := (width-2.19)/2.0
	for sign_x in [-1.0,1.0]:
		var x: float = sign_x*(.64+shop_width*.5)
		box(root,"Window knee wall",Vector3(x,.43,-.02),Vector3(shop_width,.52,.24),trim.darkened(.27))
		box(root,"Display sill",Vector3(x,.71,.12),Vector3(shop_width+.07,.095,.31),trim)
		glass(root,Vector3(x,1.72,-.06),Vector3(shop_width,1.99,.03))
		for edge in [-.5,0,.5]:
			box(root,"Display mullion",Vector3(x+edge*shop_width,1.72,.005),Vector3(.065,2.01,.08),trim)
		box(root,"Transom bar",Vector3(x,2.38,.007),Vector3(shop_width,.075,.072),trim)
		box(root,"Display platform",Vector3(x,.65,-.61),Vector3(shop_width-.16,.10,.84),WOOD.darkened(.22))
	door(root,title,trim)
	var size := 42
	var pixels := minf(.017,(width-.75)/maxf(1.0,title.length()*float(size)*.56))
	box(root,"Painted fascia",Vector3(0,3.29,.12),Vector3(width-.7,.47,.115),trim.darkened(.22))
	make_label(root,title.to_upper(),Vector3(0,3.29,.188),size,pixels,CREAM)
	for floor in range(floors):
		build_upper_floor(root,width,3.62+floor*2.64,wall,trim,floor,style)
	box(root,"Cornice",Vector3(0,height+.13,.05),Vector3(width+.27,.24,.43),trim)
	box(root,"Roof coping",Vector3(0,height+.29,.065),Vector3(width+.36,.08,.52),CREAM.darkened(.22))
	for i in range(2 if floors > 0 else 1):
		var vent := box(root,"Roof ventilator",Vector3(width*.22-i*1.42,height+.36,-4.8-i*2),Vector3(.66,.48,.58),STEEL)
		for row in range(4):
			box(vent,"Vent grille",Vector3(0,-.11+row*.075,.298),Vector3(.58,.017,.016),INK)
	var rear_door := box(root,"Service door",Vector3(-width*.21,1.20,-depth-.015),Vector3(.93,2.08,.10),STEEL)
	box(rear_door,"Service lintel",Vector3(0,1.15,-.055),Vector3(1.16,.13,.13),CREAM.darkened(.27))
	for x in [-width*.44,width*.44]:
		cylinder(root,"Cast iron downpipe",Vector3(x,height*.49,-depth-.052),.056,height*.95,INK)
	match style:
		"cafe":
			awning(root,width,trim,CREAM)
			cafe(root,width,trim)
		"outfitter":
			outfitter(root,width)
		"cinema":
			cinema(root,width,trim)
		"hardware","market","bakery","flowers":
			awning(root,width,trim,CREAM)
			retail(root,width,style,trim)
		_:
			retail(root,width,style,trim)
	add_shop_details(root,width,style,trim)
	return root

func glass(parent: Node3D,pos: Vector3,dimensions: Vector3) -> void:
	var pane := box(parent,"Window glass",pos,dimensions,Color(.47,.66,.70,.20))
	pane.material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pane.material_override.roughness = .18
	pane.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func door(root: Node3D,title: String,trim: Color) -> void:
	var hinged := group(root,"EntryDoorPivot",Vector3(-.58,.2,.04))
	box(hinged,"Door kick plate",Vector3(.58,.23,0),Vector3(1.14,.46,.072),trim.darkened(.21))
	for x in [.025,1.135]:
		box(hinged,"Door stile",Vector3(x,1.21,0),Vector3(.072,2.42,.07),trim)
	for y in [.55,2.07,2.40]:
		box(hinged,"Door rail",Vector3(.58,y,0),Vector3(1.12,.077,.077),trim)
	glass(hinged,Vector3(.58,1.48,0),Vector3(1.05,1.80,.025))
	box(hinged,"Brass pull",Vector3(1.04,1.16,.065),Vector3(.045,.30,.08),BRASS)
	box(root,"Stone threshold",Vector3(0,.13,.24),Vector3(1.27,.16,.43),CREAM.darkened(.27))
	if title != "Town Library":
		var notice := box(hinged,"Hours placard",Vector3(.58,1.43,.019),Vector3(.32,.17,.011),INK)
		make_label(notice,"HOURS",Vector3(0,0,.01),26,.0035,CREAM)

func build_upper_floor(root: Node3D,width: float,base: float,wall: Color,trim: Color,level: int,style: String) -> void:
	box(root,"Upper masonry",Vector3(0,base+1.32,-.19),Vector3(width,2.64,.28),wall)
	box(root,"Horizontal belt course",Vector3(0,base+.11,.016),Vector3(width+.09,.11,.20),trim.lightened(.14))
	var window_count := 4 if width > 9.0 else 3
	for i in range(window_count):
		var x := (float(i)+.5)*width/window_count-width*.5
		box(root,"Recessed upper window",Vector3(x,base+1.29,-.036),Vector3(1.19,1.54,.071),INK)
		box(root,"Upper glass",Vector3(x,base+1.29,.008),Vector3(1.04,1.40,.03),Color("#506064").lightened(.025*float((i+level)%4)))
		for sign_x in [-1,1]:
			box(root,"Window jamb",Vector3(x+sign_x*.58,base+1.29,.065),Vector3(.08,1.58,.13),trim)
		for y in [.50,2.08]:
			box(root,"Cut stone lintel or sill",Vector3(x,base+y,.073),Vector3(1.34,.13,.23),CREAM.darkened(.18))
		box(root,"Meeting rail",Vector3(x,base+1.29,.044),Vector3(1.08,.065,.066),trim)
		box(root,"Sash stile",Vector3(x,base+1.29,.050),Vector3(.053,1.39,.06),trim)
		if (i+level)%3 == 0 and style != "library":
			box(root,"Curtain",Vector3(x-.32,base+1.28,.029),Vector3(.28,1.32,.023),CREAM.darkened(.24))
		if (i+2*level)%4 == 2:
			box(root,"Window AC casing",Vector3(x+.25,base+.67,.165),Vector3(.49,.26,.34),STEEL)
			for louver in range(4):
				box(root,"AC louver",Vector3(x+.25,base+.59+louver*.05,.342),Vector3(.40,.013,.014),INK)
	if style in ["brick","cafe","hardware","bakery","outfitter","cinema"]:
		for row in range(9):
			var y := base+.27+row*.24
			for side in [-1,1]:
				box(root,"Masonry course",Vector3(side*(width*.5-.27),y,-.032),Vector3(.48,.016,.026),wall.darkened(.26))
				box(root,"Quoin",Vector3(side*(width*.5-.18),y+.105,-.008),Vector3(.30 if row%2==0 else .23,.17,.054),wall.lightened(.14))

func awning(root: Node3D,width: float,trim: Color,light: Color) -> void:
	var count := 13
	var strip_width := (width-.76)/count
	for i in range(count):
		var x := -width*.5+.38+(i+.5)*strip_width
		var tint := trim if i%2==0 else light
		var strip := box(root,"Canvas awning stripe",Vector3(x,2.84,.51),Vector3(strip_width+.003,.062,1.10),tint)
		strip.rotation.x = .22
		box(root,"Awning valance",Vector3(x,2.66,1.04),Vector3(strip_width+.003,.20,.037),tint)

func cafe(root: Node3D,width: float,trim: Color) -> void:
	for i in range(4):
		var x := (-1.0 if i%2==0 else 1.0)*(width*.5-1.21)
		bistro_table(root,Vector3(x,.215,-1.35-float(i/2)*2.4),trim)
	for x in [-width*.5+.9,width*.5-.9]:
		bistro_table(root,Vector3(x,.0,1.80),trim)
	box(root,"Tile counter plinth",Vector3(0,.68,-6.58),Vector3(width*.72,.94,.86),trim.darkened(.15))
	box(root,"Timber counter top",Vector3(0,1.18,-6.58),Vector3(width*.74,.16,1.01),WOOD)
	for x in [-1.4,-.3,.8]:
		box(root,"Cafe menu board",Vector3(x,2.30,-8.4),Vector3(.92,.55,.045),INK)
		make_label(root,"COFFEE  •  TEA",Vector3(x,2.31,-8.37),30,.0052,CREAM)
	var machine := box(root,"Espresso machine",Vector3(-1.15,1.46,-6.58),Vector3(.83,.43,.42),STEEL)
	box(machine,"Control fascia",Vector3(0,.115,.22),Vector3(.81,.11,.035),INK)
	for x in [-.24,.02,.28]:
		cylinder(machine,"Brew head",Vector3(x,-.07,.19),.066,.099,STEEL.lightened(.33))
		var cup := cylinder(root,"Ceramic cup",Vector3(-1.15+x,1.55,-6.12),.045,.078,CREAM)
		cylinder(cup,"Dark cup opening",Vector3(0,.040,0),.036,.004,WOOD.darkened(.49))
	box(root,"Pastry case base",Vector3(1.3,1.29,-6.56),Vector3(.88,.07,.55),WOOD)
	glass(root,Vector3(1.3,1.52,-6.27),Vector3(.89,.41,.031))
	glass(root,Vector3(1.3,1.73,-6.55),Vector3(.89,.031,.55))
	for i in range(6):
		cylinder(root,"Pastry",Vector3(.99+i*.12,1.37,-6.54),.05,.057,WOOD.lightened(.25))
	for x in [-1.65,0.0,1.65]:
		var bulb := cylinder(root,"Enamel pendant shade",Vector3(x,2.54,-4.65),.28,.17,trim)
		cylinder(bulb,"Pendant rod",Vector3(0,.54,0),.018,1.08,INK)
	var easel := group(root,"Sidewalk menu",Vector3(1.04,0,1.67))
	box(easel,"Menu board",Vector3(0,.49,0),Vector3(.41,.60,.047),INK).rotation.x = -.17
	box(easel,"Rear support",Vector3(0,.46,-.17),Vector3(.31,.79,.026),WOOD).rotation.x = .32
	make_label(easel,"TODAY",Vector3(0,.59,.04),36,.004,CREAM)

func bistro_table(root: Node3D,pos: Vector3,trim: Color) -> void:
	var table := group(root,"Bistro table and chairs",pos)
	cylinder(table,"Round tabletop",Vector3(0,.72,0),.39,.07,WOOD)
	cylinder(table,"Pedestal",Vector3(0,.37,0),.041,.66,INK)
	cylinder(table,"Cast base",Vector3(0,.032,0),.24,.06,INK)
	for front in [-1,1]:
		var chair := group(table,"Bistro chair",Vector3(0,0,front*.64))
		chair.rotation.y = 0.0 if front > 0 else PI
		box(chair,"Chair seat",Vector3(0,.41,0),Vector3(.36,.07,.36),trim)
		box(chair,"Slat back",Vector3(0,.65,.16),Vector3(.34,.30,.06),trim)
		for x in [-.14,.14]:
			for z in [-.13,.13]:
				cylinder(chair,"Chair leg",Vector3(x,.20,z),.018,.40,INK)

func outfitter(root: Node3D,width: float) -> void:
	for x in [-width*.28,width*.28]:
		box(root,"Exterior display riser",Vector3(x,.79,-.58),Vector3(1.60,.27,.54),WOOD.darkened(.31))
		make_label(root,"SPORTING GOODS",Vector3(x,1.99,-.085),30,.006,CREAM)
		for i in range(4):
			box(root,"Outdoor gear carton",Vector3(x-.55+i*.35,.99,-.62),Vector3(.26,.15,.24),[CREAM,STEEL,WOOD,INK][i])
	box(root,"Sales counter",Vector3(0,.70,-4.75),Vector3(width*.76,.96,1.0),WOOD.darkened(.30))
	box(root,"Glass display counter top",Vector3(0,1.26,-4.75),Vector3(width*.78,.045,1.04),Color("#819e97"))
	for x in [-width*.27,0,width*.27]:
		var cabinet := group(root,"Rear display cabinet",Vector3(x,.21,-8.31))
		box(cabinet,"Cabinet backing",Vector3(0,1.30,-.25),Vector3(1.82,2.54,.11),WOOD.darkened(.33))
		for edge in [-.88,.88]:
			box(cabinet,"Cabinet side",Vector3(edge,1.30,0),Vector3(.075,2.54,.55),INK)
		for y in [.19,.71,2.40]:
			box(cabinet,"Cabinet shelf",Vector3(0,y,0),Vector3(1.82,.075,.55),WOOD.darkened(.14))
		glass(cabinet,Vector3(0,1.34,.27),Vector3(1.74,2.17,.03))
		for i in range(3):
			var silhouette := box(cabinet,"Opaque display silhouette",Vector3(-.55+i*.55,1.43,-.11),Vector3(.08,1.03,.08),INK)
			silhouette.rotation.z = -.18
			box(silhouette,"Display stand",Vector3(0,-.26,0),Vector3(.16,.33,.10),INK)
		make_label(cabinet,"DISPLAY",Vector3(0,2.28,.286),30,.006,CREAM)
	box(root,"Rubber entry mat",Vector3(0,.23,-1.15),Vector3(1.8,.02,.82),INK)
	box(root,"Register",Vector3(1.15,1.35,-4.74),Vector3(.34,.17,.32),INK)
	for i in range(14):
		box(root,"Worn floorboard joint",Vector3((i-6.5)*width*.066,.226,-2.49),Vector3(.012,.004,4.48),WOOD.darkened(.26))
	for x in [-width*.32,width*.32]:
		for z in [-2.24,-6.28]:
			var fixture := box(root,"Ceiling strip housing",Vector3(x,3.39,z),Vector3(.26,.10,1.08),STEEL)
			box(fixture,"Unpowered light diffuser",Vector3(0,-.06,0),Vector3(.20,.025,1.00),CREAM)
	for x in [-width*.38,width*.38]:
		var shelf := group(root,"Gear shelf",Vector3(x,.21,-6.43))
		box(shelf,"Slat wall",Vector3(0,1.11,-.24),Vector3(.88,2.20,.09),WOOD.darkened(.29))
		for y in [.42,.94,1.46]:
			box(shelf,"Steel shelf",Vector3(0,y,0),Vector3(.86,.055,.43),STEEL)
			for i in range(3):
				box(shelf,"Unmarked supply carton",Vector3(-.28+i*.28,y+.10,0),Vector3(.24,.15,.28),[WOOD,CREAM,STEEL][i])
	box(root,"Repair and accessories pegboard",Vector3(0,1.89,-9.8),Vector3(width*.62,1.25,.12),STEEL)

func cinema(root: Node3D,width: float,trim: Color) -> void:
	box(root,"Projecting marquee",Vector3(0,3.03,1.04),Vector3(width-.68,.49,1.92),trim)
	box(root,"Marquee directory",Vector3(0,3.04,2.023),Vector3(width-.87,.30,.042),CREAM)
	make_label(root,"MATINEE   •   EVENING SHOW",Vector3(0,3.04,2.05),36,.011,INK)
	for i in range(24):
		cylinder(root,"Unlit marquee bulb",Vector3(-width*.43+i*width*.86/23,2.77,1.73),.039,.047,CREAM)
	for x in [-width*.33,width*.33]:
		box(root,"Poster box frame",Vector3(x,1.64,.16),Vector3(.95,1.37,.14),WOOD.darkened(.27))
		box(root,"Poster insert",Vector3(x,1.64,.24),Vector3(.79,1.19,.017),trim.lightened(.21))
		make_label(root,"COMING\nSOON",Vector3(x,1.68,.257),36,.007,CREAM)
	retail(root,width,"cinema",trim)

func retail(root: Node3D,width: float,style: String,trim: Color) -> void:
	for side in [-1,1]:
		var x: float = side*(width*.5-.74)
		for y in [.57,1.11,1.65]:
			box(root,"Interior display shelf",Vector3(x,y,-3.25),Vector3(.51,.061,3.9),WOOD.darkened(.19))
			for i in range(6):
				var shade: Color = [trim.lightened(.32),CREAM,Color("#8c6d56"),STEEL][(i+int(y*10))%4]
				box(root,"Packaged inventory",Vector3(x,y+.13,-1.66-i*.61),Vector3(.28,.21,.24),shade)
		var pos := Vector3(side*width*.28,.81,-.47)
		if style in ["flowers","bakery","market"]:
			for i in range(4):
				cylinder(root,"Window display item",pos+Vector3(-.49+i*.32,.08,0),.095,.22,WOOD.lightened(.12))
		else:
			for i in range(3):
				box(root,"Window display stack",pos+Vector3(-.47+i*.46,.068,0),Vector3(.35,.19,.35),trim.lightened(.18))
	box(root,"Cash counter",Vector3(width*.23,.68,-6.71),Vector3(width*.36,.95,.69),trim.darkened(.21))
	box(root,"Register",Vector3(width*.21,1.23,-6.7),Vector3(.31,.16,.23),INK)

func add_corner_windows(root: Node3D,width: float,floors: int,tint: Color) -> void:
	for side in [-1,1]:
		var facade := group(root,"Side window bay",Vector3(side*(width*.5+.015),0,0))
		facade.rotation.y = side*PI/2
		for floor in range(floors):
			var y := 4.91+floor*2.64
			for offset in [2.1,5.02,8.24]:
				var x: float = side*offset
				box(facade,"Side sash recess",Vector3(x,y,0),Vector3(.94,1.37,.062),INK)
				box(facade,"Opaque sash glass",Vector3(x,y,.045),Vector3(.78,1.19,.032),Color("#576765"))
				box(facade,"Sash meeting bar",Vector3(x,y,.066),Vector3(.84,.066,.06),tint)
				box(facade,"Side masonry sill",Vector3(x,y-.72,.079),Vector3(1.10,.106,.23),CREAM.darkened(.18))

func add_shop_details(root: Node3D,width: float,style: String,trim: Color) -> void:
	match style:
		"pharmacy":
			var enamel := group(root,"Pharmacy cross",Vector3(width*.37,3.57,.41))
			box(enamel,"Green enamel sign",Vector3.ZERO,Vector3(.52,.52,.13),trim)
			box(enamel,"Cross vertical",Vector3(0,0,.075),Vector3(.10,.36,.028),CREAM)
			box(enamel,"Cross horizontal",Vector3(0,0,.076),Vector3(.36,.10,.028),CREAM)
		"barber":
			var pole := group(root,"Barber pole",Vector3(-width*.40,1.87,.28))
			cylinder(pole,"Glass tube",Vector3.ZERO,.105,.53,CREAM)
			for i in range(7):
				var stripe := box(pole,"Paint stripe",Vector3(0,-.20+i*.065,.103),Vector3(.17,.035,.015),Color("#9b5744") if i%2==0 else Color("#54767e"))
				stripe.rotation.z = -.35
			for y in [-.301,.301]:
				cylinder(pole,"Chrome cap",Vector3(0,y,0),.112,.06,STEEL)
		"library","bank":
			for x in [-width*.43,width*.43]:
				var pier := group(root,"Stone entrance column",Vector3(x,0,.27))
				box(pier,"Plinth",Vector3(0,.18,0),Vector3(.48,.35,.45),CREAM)
				cylinder(pier,"Column shaft",Vector3(0,1.63,0),.158,2.83,CREAM)
				box(pier,"Capital",Vector3(0,3.02,0),Vector3(.40,.20,.42),CREAM)
		"market","flowers":
			for k in range(2):
				var produce := group(root,"Crate display",Vector3(-width*.28+k*1.06,.10,.55))
				box(produce,"Pine crate",Vector3(0,.26,0),Vector3(.73,.36,.46),WOOD)
				for i in range(4):
					for j in range(2):
						var fruit := SphereMesh.new()
						fruit.radius = .055
						fruit.height = .11
						fruit.radial_segments = 10
						fruit.rings = 5
						mesh(produce,"Display item",fruit,Vector3(-.25+i*.16,.47,-.10+j*.20),Color("#9c6850") if k == 0 else Color("#728052"))
		"laundry":
			for i in range(5):
				var washer := box(root,"Front loading washer",Vector3(width*.34,.68,-1.41-i*1.16),Vector3(.73,.92,.82),STEEL.lightened(.25))
				washer.rotation.y = -PI/2
				cylinder(washer,"Chrome door ring",Vector3(0,.03,.43),.27,.036,STEEL).rotation.x = PI/2
				cylinder(washer,"Dark door glass",Vector3(0,.03,.452),.217,.013,INK).rotation.x = PI/2
		"post":
			var mailbox := box(root,"Post collection box",Vector3(width*.27,.64,.72),Vector3(.46,1.17,.49),trim)
			box(mailbox,"Letter flap",Vector3(0,.24,.252),Vector3(.32,.05,.025),STEEL)
			make_label(mailbox,"POST",Vector3(0,.01,.255),30,.004,CREAM)
