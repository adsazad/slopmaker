extends "res://props.gd"

const FRAME := Color("#394142")
const METAL := Color("#5b6260")
const INK := Color("#292e2e")
const WOOD := Color("#946643")
const PAPER := Color("#d4c19a")
const RED := Color("#a35542")

func pistol() -> Node3D:
	var prop := group(self,"Compact Pistol Prop",Vector3.ZERO)
	var slide := box(prop,"Dark upper silhouette",Vector3(0,.147,.012),Vector3(.032,.035,.188),METAL)
	box(prop,"Tapered front face",Vector3(0,.142,.109),Vector3(.027,.027,.010),FRAME)
	box(prop,"Painted muzzle recess",Vector3(0,.148,.115),Vector3(.015,.014,.002),INK)
	box(prop,"Lower frame",Vector3(0,.119,.010),Vector3(.033,.022,.162),FRAME)
	box(prop,"Frame ledge",Vector3(0,.108,.057),Vector3(.028,.012,.073),INK)
	for side in [-1,1]:
		for i in range(7):
			var rib := box(slide,"Raised slide texture",Vector3(side*.0167,-.001,-.077+i*.006),Vector3(.0017,.024,.0027),INK)
			rib.rotation.x = -.24
		box(slide,"Finish inset",Vector3(side*.0166,.005,.031),Vector3(.0015,.012,.035),FRAME)
	box(slide,"Front sight silhouette",Vector3(0,.019,.076),Vector3(.009,.007,.009),INK)
	box(slide,"Rear sight silhouette",Vector3(0,.020,-.082),Vector3(.020,.008,.012),INK)
	var grip := group(prop,"Textured grip",Vector3(0,.063,-.049))
	grip.rotation.x = -.22
	box(grip,"Grip body",Vector3.ZERO,Vector3(.034,.103,.051),FRAME)
	box(grip,"Grip heel",Vector3(0,-.052,0),Vector3(.036,.010,.055),INK)
	for side in [-1,1]:
		box(grip,"Grip insert",Vector3(side*.017,.001,0),Vector3(.003,.075,.037),INK.lightened(.09))
		for row in range(10):
			box(grip,"Molded grip rib",Vector3(side*.019,-.031+row*.007,0),Vector3(.002,.0017,.034),METAL.darkened(.21))
	var guard := group(prop,"Solid guard outline",Vector3(0,.081,.003))
	box(guard,"Guard base",Vector3(0,-.020,0),Vector3(.019,.008,.076),FRAME)
	box(guard,"Guard front radius",Vector3(0,.001,.034),Vector3(.018,.048,.011),FRAME).rotation.x = .18
	box(guard,"Fixed display projection",Vector3(0,.006,-.011),Vector3(.008,.026,.010),INK).rotation.x = -.30
	return prop

func shotgun() -> Node3D:
	var prop := group(self,"Short Shotgun Prop",Vector3.ZERO)
	var barrel := cylinder(prop,"Solid barrel silhouette",Vector3(0,.101,.142),.017,.36,METAL.darkened(.12))
	barrel.rotation.x = PI/2
	var front := cylinder(prop,"Painted muzzle recess",Vector3(0,.101,.323),.010,.002,INK)
	front.rotation.x = PI/2
	box(prop,"Front sight silhouette",Vector3(0,.122,.308),Vector3(.011,.009,.009),INK)
	box(prop,"Solid receiver housing",Vector3(0,.078,-.035),Vector3(.054,.068,.165),FRAME)
	for side in [-1,1]:
		box(prop,"Receiver side plate",Vector3(side*.028,.081,-.028),Vector3(.003,.037,.105),METAL.darkened(.18))
		box(prop,"Stamped line",Vector3(side*.030,.089,-.012),Vector3(.002,.004,.065),INK.lightened(.15))
	var fore := group(prop,"Ribbed walnut foregrip",Vector3(0,.056,.121))
	box(fore,"Foregrip core",Vector3.ZERO,Vector3(.050,.041,.145),WOOD)
	for i in range(10):
		box(fore,"Walnut grip groove",Vector3(0,-.021,-.061+i*.013),Vector3(.049,.003,.004),WOOD.darkened(.29))
		for side in [-1,1]:
			box(fore,"Foregrip side groove",Vector3(side*.025,0,-.061+i*.013),Vector3(.002,.038,.005),WOOD.darkened(.29))
	var stock := group(prop,"Short walnut stock",Vector3(0,.059,-.183))
	var wrist := box(stock,"Stock wrist",Vector3(0,-.009,.044),Vector3(.044,.053,.116),WOOD)
	wrist.rotation.x = -.17
	box(stock,"Shaped stock body",Vector3(0,-.018,-.040),Vector3(.055,.074,.116),WOOD.darkened(.08))
	box(stock,"Rubber butt pad",Vector3(0,-.020,-.102),Vector3(.056,.076,.013),INK)
	for y in [-.019,0,.019]:
		box(stock,"Butt pad tread",Vector3(0,y-.020,-.109),Vector3(.047,.004,.003),METAL.darkened(.32))
	var guard := box(prop,"Guard lower edge",Vector3(0,.014,-.065),Vector3(.022,.010,.075),FRAME)
	box(guard,"Guard front",Vector3(0,.021,.034),Vector3(.020,.039,.012),FRAME)
	box(guard,"Fixed display projection",Vector3(0,.023,-.008),Vector3(.009,.032,.012),INK)
	return prop

func pistol_refills() -> Node3D:
	var prop := group(self,"Pistol Ammunition Props",Vector3.ZERO)
	paper_box(prop,"Pistol rounds","PISTOL ROUNDS",Color("#33575a"),Vector3(-.06,0,0),Vector3(.098,.034,.059))
	var magazine := group(prop,"Spare magazine prop",Vector3(.048,.014,.006))
	magazine.rotation.y = .12
	box(magazine,"Solid magazine body",Vector3(0,0,0),Vector3(.028,.019,.092),FRAME)
	box(magazine,"Molded base plate",Vector3(0,0,-.048),Vector3(.032,.024,.010),INK)
	box(magazine,"Painted end cap",Vector3(0,0,.047),Vector3(.025,.017,.003),METAL)
	for i in range(5):
		box(magazine,"Stamped side detail",Vector3(0,.010,-.024+i*.012),Vector3(.013,.002,.003),INK)
	return prop

func shotgun_refills() -> Node3D:
	var prop := group(self,"Shotgun Ammunition Props",Vector3.ZERO)
	paper_box(prop,"Shotgun shells","SHOTGUN SHELLS",RED,Vector3(-.035,0,0),Vector3(.117,.045,.072))
	paper_box(prop,"Spare carton","SHOTGUN SHELLS",RED.darkened(.16),Vector3(.082,0,.025),Vector3(.108,.041,.069))
	return prop

func paper_box(parent: Node3D,title: String,copy: String,band: Color,pos: Vector3,dim: Vector3) -> void:
	var carton := group(parent,title,pos)
	box(carton,"Printed cardboard box",Vector3(0,dim.y*.5,0),dim,PAPER)
	box(carton,"Front color band",Vector3(0,dim.y*.57,dim.z*.5+.0004),Vector3(dim.x,.017,.001),band)
	box(carton,"Top paper seam",Vector3(dim.x*.33,dim.y+.0005,0),Vector3(.002,.001,dim.z),PAPER.darkened(.26))
	box(carton,"Folded side flap",Vector3(-dim.x*.5,dim.y*.75,0),Vector3(.001,.006,dim.z),PAPER.darkened(.13))
	make_label(carton,copy,Vector3(0,dim.y*.57,dim.z*.5+.0012),30,.00030,PAPER.lightened(.15))
	var label := make_label(carton,copy,Vector3(0,dim.y+.0012,-.006),30,.00034,band)
	label.rotation.x = -PI/2
