extends "res://props.gd"

const RUBBER := Color("#303737")
const SHELL := Color("#4e5750")
const STEEL := Color("#787f77")
const STRAP := Color("#525a4d")

func build() -> void:
	name = "Binoculars"
	for side in [-1,1]:
		build_barrel(side)
	build_hinge()
	build_strap()

func tube(parent: Node3D,title: String,pos: Vector3,front: float,back: float,length: float,tint: Color) -> MeshInstance3D:
	var shape := CylinderMesh.new()
	shape.top_radius = front
	shape.bottom_radius = back
	shape.height = length
	shape.radial_segments = 32
	var piece := mesh(parent,title,shape,pos,tint)
	piece.rotation.x = PI/2
	return piece

func ring(parent: Node3D,title: String,pos: Vector3,inner: float,outer: float,tint: Color) -> void:
	var shape := TorusMesh.new()
	shape.inner_radius = inner
	shape.outer_radius = outer
	var piece := mesh(parent,title,shape,pos,tint)
	piece.rotation.x = PI/2

func lens(parent: Node3D,title: String,pos: Vector3,radius: float,tint: Color) -> void:
	var shape := SphereMesh.new()
	shape.radius = radius
	shape.height = radius*2
	shape.radial_segments = 32
	shape.rings = 12
	var piece := mesh(parent,title,shape,pos,tint)
	piece.scale.z = .17
	piece.material_override.roughness = .13
	piece.material_override.metallic = .49

func build_barrel(side: int) -> void:
	var pod := group(self,"Left optical barrel" if side < 0 else "Right optical barrel",Vector3(side*.044,.051,0))
	tube(pod,"Rubber armored body",Vector3(0,0,-.005),.040,.034,.089,SHELL)
	tube(pod,"Flared objective shoulder",Vector3(0,0,.047),.046,.040,.029,RUBBER)
	tube(pod,"Objective shroud",Vector3(0,0,.067),.046,.046,.017,RUBBER)
	tube(pod,"Recess shadow",Vector3(0,0,.076),.040,.040,.002,RUBBER.darkened(.48))
	lens(pod,"Coated objective lens",Vector3(0,0,.076),.035,Color("#335b61"))
	ring(pod,"Rounded objective lip",Vector3(0,0,.082),.039,.047,RUBBER)
	tube(pod,"Eyepiece collar",Vector3(0,0,-.059),.028,.027,.030,RUBBER)
	ring(pod,"Folded rubber eye cup",Vector3(0,0,-.076),.019,.030,RUBBER.darkened(.18))
	lens(pod,"Coated ocular lens",Vector3(0,0,-.073),.018,Color("#40526a"))
	for i in range(8):
		var ridge := box(pod,"Side grip rib",Vector3(side*(.036+.0008*i),.010,-.039+i*.009),Vector3(.009,.025,.004),RUBBER.lightened(.13))
		ridge.rotation.z = side*-.31
	if side > 0:
		for i in range(18):
			var angle := i*TAU/18
			var ridge := box(pod,"Diopter grip",Vector3(cos(angle)*.027,sin(angle)*.027,-.060),Vector3(.003,.007,.015),STEEL.darkened(.28))
			ridge.rotation.z = angle
	var lug := group(pod,"Strap eyelet",Vector3(side*.040,.012,-.035))
	for z in [-.009,.009]:
		box(lug,"Eyelet base",Vector3(0,0,z),Vector3(.013,.009,.006),STEEL)
	box(lug,"Eyelet bridge",Vector3(side*.009,0,0),Vector3(.006,.009,.022),STEEL)

func build_hinge() -> void:
	var hinge := group(self,"Central hinge and focus",Vector3(0,.059,0))
	for z in [-.042,.040]:
		box(hinge,"Hinge bridge",Vector3(0,0,z),Vector3(.055,.021,.018),SHELL)
	tube(hinge,"Hinge shaft",Vector3.ZERO,.015,.015,.10,STEEL.darkened(.21))
	tube(hinge,"Focus dial",Vector3(0,.005,-.016),.021,.021,.031,RUBBER)
	for i in range(24):
		var angle := i*TAU/24
		var flute := box(hinge,"Focus grip flute",Vector3(cos(angle)*.021,.005+sin(angle)*.021,-.016),Vector3(.0025,.005,.028),RUBBER.lightened(.20))
		flute.rotation.z = angle
	tube(hinge,"Hinge cap",Vector3(0,0,.054),.012,.012,.007,STEEL)
	var plaque := box(hinge,"Specification plaque",Vector3(0,.012,.041),Vector3(.034,.002,.016),RUBBER)
	var mark := make_label(plaque,"8 × 42",Vector3(0,.0018,0),30,.00022,Color("#d7d5c9"))
	mark.rotation.x = -PI/2

func build_strap() -> void:
	var ribbon := group(self,"Woven neck strap",Vector3.ZERO)
	var curve := Curve3D.new()
	curve.bake_interval = .007
	curve.add_point(Vector3(-.091,.061,-.033),Vector3.ZERO,Vector3(-.030,-.045,-.024))
	curve.add_point(Vector3(-.135,.010,-.122),Vector3(.003,.005,.044),Vector3(-.003,0,-.041))
	curve.add_point(Vector3(-.122,.007,-.215),Vector3(-.026,0,.008),Vector3(.039,0,-.013))
	curve.add_point(Vector3(.106,.007,-.206),Vector3(-.042,0,-.031),Vector3(.041,0,.031))
	curve.add_point(Vector3(.106,.015,-.100),Vector3(.003,-.006,-.033),Vector3(-.004,.016,.041))
	curve.add_point(Vector3(.091,.061,-.033),Vector3(.015,-.025,-.027))
	var points := curve.get_baked_points()
	for i in range(points.size()-1):
		var a := points[i]
		var b := points[i+1]
		var segment := box(ribbon,"Woven strap section",a.lerp(b,.5),Vector3(.013,.0026,a.distance_to(b)+.0014),STRAP.lightened(.012*(i%3)))
		segment.look_at_from_position(segment.position,b,Vector3.UP)
	box(ribbon,"Strap slider",Vector3(.114,.018,-.136),Vector3(.018,.007,.027),RUBBER)
