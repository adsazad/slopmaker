extends "res://props.gd"

const COAT := Color("#916347")
const BACK := Color("#765239")
const LIGHT := Color("#c99d73")
const CREAM := Color("#e2cfaa")
const EAR := Color("#ae786a")
const INK := Color("#302b29")
const ANTLER := Color("#b6a184")

func build() -> void:
	name = "Whitetail Deer"
	var torso := group(self,"Torso",Vector3.ZERO)
	body(torso,"Rib cage",Vector3(0,.97,.062),Vector3(.222,.262,.49),COAT)
	body(torso,"Saddle coat",Vector3(0,1.086,.020),Vector3(.183,.156,.433),BACK)
	body(torso,"Chest",Vector3(0,.943,.327),Vector3(.195,.256,.235),COAT)
	body(torso,"Haunch",Vector3(0,.944,-.337),Vector3(.193,.236,.250),COAT.darkened(.035))
	body(torso,"Pale underside",Vector3(0,.795,-.057),Vector3(.155,.115,.34),LIGHT)
	body(torso,"Rump patch",Vector3(0,.973,-.563),Vector3(.145,.147,.038),CREAM)
	for i in [-1,1]:
		build_leg(i,true)
		build_leg(i,false)
	var tail := group(self,"Tail pivot",Vector3(0,1.077,-.544))
	tail.rotation.x = -.24
	body(tail,"Tail coat",Vector3(0,-.062,-.071),Vector3(.078,.046,.138),BACK).rotation.x = .43
	body(tail,"White tail underside",Vector3(0,-.090,-.073),Vector3(.058,.034,.116),CREAM).rotation.x = .43
	build_head()

func body(parent: Node3D,title: String,pos: Vector3,radii: Vector3,tint: Color) -> MeshInstance3D:
	var shape := SphereMesh.new()
	shape.radius = 1.0
	shape.height = 2.0
	shape.radial_segments = 12
	shape.rings = 7
	var part := mesh(parent,title,shape,pos,tint)
	part.scale = radii
	return part

func limb(parent: Node3D,title: String,start: Vector3,end: Vector3,radius_a: float,radius_b: float,tint: Color) -> void:
	var delta := end-start
	var shape := CylinderMesh.new()
	shape.top_radius = radius_b
	shape.bottom_radius = radius_a
	shape.height = delta.length()
	shape.radial_segments = 9
	var part := mesh(parent,title,shape,start.lerp(end,.5),tint)
	part.quaternion = Quaternion(Vector3.UP,delta.normalized())

func build_leg(side: int,front: bool) -> void:
	var side_name := "Left" if side < 0 else "Right"
	var name_prefix := ("Fore " if front else "Hind ")+side_name
	var leg := group(self,name_prefix+" hip pivot",Vector3(side*(.13 if front else .129),.91,.343 if front else -.348))
	var knee := Vector3(side*.012,-.342,.004 if front else -.110)
	var ankle := Vector3(side*.008,-.460,.006 if front else .113)
	if front:
		limb(leg,"Upper foreleg",Vector3.ZERO,knee,.077,.032,COAT)
	else:
		body(leg,"Haunch muscle",Vector3(side*.011,-.09,-.044),Vector3(.086,.186,.105),COAT).rotation.x = .14
		limb(leg,"Hind leg above hock",Vector3(0,-.064,-.018),knee,.083,.039,COAT)
	var lower := group(leg,name_prefix+" knee pivot",knee)
	body(lower,"Knee joint",Vector3.ZERO,Vector3(.033,.044,.034),COAT.darkened(.07))
	limb(lower,"Lower leg",Vector3.ZERO,ankle,.031,.020,COAT.darkened(.14))
	limb(lower,"Pastern",ankle,ankle+Vector3(0,-.043,.026),.022,.024,BACK)
	var hoof := group(lower,name_prefix+" hoof",ankle+Vector3(0,-.069,.031))
	for s in [-1,1]:
		body(hoof,"Cloven toe",Vector3(s*.016,0,.012),Vector3(.016,.030,.048),INK)
	body(hoof,"Hoof heel",Vector3(0,.006,-.021),Vector3(.029,.028,.022),INK)

func build_head() -> void:
	var neck := group(self,"Neck pivot",Vector3(0,1.03,.319))
	body(neck,"Sloping neck",Vector3(0,.224,.134),Vector3(.119,.300,.132),COAT).rotation.x = .53
	body(neck,"Pale throat",Vector3(0,.224,.222),Vector3(.069,.202,.074),LIGHT).rotation.x = .53
	var head := group(neck,"Head pivot",Vector3(0,.421,.242))
	body(head,"Skull",Vector3(0,0,.045),Vector3(.106,.111,.147),COAT)
	body(head,"Nasal bridge",Vector3(0,-.042,.153),Vector3(.074,.079,.135),LIGHT).rotation.x = .31
	body(head,"Muzzle",Vector3(0,-.083,.232),Vector3(.065,.053,.062),CREAM.darkened(.10))
	body(head,"Dark nose",Vector3(0,-.066,.280),Vector3(.054,.035,.022),INK)
	for side in [-1,1]:
		body(head,"Nostril",Vector3(side*.034,-.061,.296),Vector3(.013,.008,.006),INK.darkened(.50))
		var eye_socket := group(head,"Eye socket",Vector3(side*.091,.013,.110))
		eye_socket.rotation.y = side*.10
		body(eye_socket,"Pale eye marking",Vector3.ZERO,Vector3(.014,.027,.035),CREAM.darkened(.10))
		body(eye_socket,"Eye",Vector3(side*.010,.001,.002),Vector3(.013,.018,.023),INK.darkened(.34))
		body(eye_socket,"Eye catchlight",Vector3(side*.020,.005,.009),Vector3(.004,.004,.005),Color("#d9d5c9"))
		var ear := group(head,"Left ear swivel" if side < 0 else "Right ear swivel",Vector3(side*.082,.049,-.034))
		ear.rotation.z = -side*.78
		ear.rotation.y = side*.19
		body(ear,"Outer ear",Vector3(side*.013,.092,-.018),Vector3(.048,.102,.020),COAT.lightened(.1))
		body(ear,"Inner ear",Vector3(side*.016,.100,-.002),Vector3(.035,.074,.011),EAR)
		build_antler(head,side)

func build_antler(head: Node3D,side: int) -> void:
	var antler := group(head,"Left antler" if side < 0 else "Right antler",Vector3(side*.051,.093,.014))
	var base := Vector3.ZERO
	var burr := Vector3(side*.024,.086,-.047)
	var sweep := Vector3(side*.086,.163,-.106)
	var crown := Vector3(side*.145,.228,-.058)
	limb(antler,"Antler base",base,burr,.019,.016,ANTLER.darkened(.19))
	limb(antler,"Antler beam",burr,sweep,.016,.013,ANTLER)
	limb(antler,"Antler sweep",sweep,crown,.013,.008,ANTLER)
	limb(antler,"Beam tip",crown,Vector3(side*.153,.282,.017),.008,.002,ANTLER)
	limb(antler,"Brow tine",burr.lerp(sweep,.32),Vector3(side*.058,.193,.006),.010,.002,ANTLER)
	limb(antler,"Second tine",sweep,Vector3(side*.119,.298,-.129),.011,.002,ANTLER)
	limb(antler,"Third tine",sweep.lerp(crown,.57),Vector3(side*.156,.310,-.093),.009,.002,ANTLER)
