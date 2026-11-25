extends "res://props.gd"

const BODY := Color("#3c4843")
const BLACK := Color("#252d2e")
const STEEL := Color("#818982")
const BRASS := Color("#aa8d60")
const GLASS := Color("#9daeaa")

func build() -> void:
	name = "Handheld Torch"
	build_handle()
	build_lamp_head()
	build_beam()

func tube(title: String,z: float,front: float,back: float,length: float,tint: Color) -> MeshInstance3D:
	var shape := CylinderMesh.new()
	shape.top_radius = front
	shape.bottom_radius = back
	shape.height = length
	shape.radial_segments = 32
	var piece := mesh(self,title,shape,Vector3(0,.039,z),tint)
	piece.rotation.x = PI/2
	return piece

func bezel(title: String,z: float,inner: float,outer: float,tint: Color) -> void:
	var shape := TorusMesh.new()
	shape.inner_radius = inner
	shape.outer_radius = outer
	mesh(self,title,shape,Vector3(0,.039,z),tint).rotation.x = PI/2

func build_handle() -> void:
	tube("Anodized battery tube",-.039,.021,.021,.158,BODY)
	tube("Rubber grip sleeve",-.052,.023,.023,.100,BLACK.lightened(.07))
	for i in range(20):
		var angle := i*TAU/20
		var ridge := box(self,"Longitudinal grip rib",Vector3(cos(angle)*.023,.039+sin(angle)*.023,-.052),Vector3(.0025,.004,.092),BLACK.lightened(.16))
		ridge.rotation.z = angle
	for z in [-.097,-.005]:
		bezel("Grip end rib",z,.0215,.0241,BLACK)
	tube("Threaded tail cap",-.125,.025,.023,.028,BODY.darkened(.25))
	tube("Recessed tail boot",-.140,.014,.014,.004,BLACK)
	for i in range(18):
		var angle := i*TAU/18
		var flute := box(self,"Tail cap flute",Vector3(cos(angle)*.024,.039+sin(angle)*.024,-.128),Vector3(.003,.004,.016),STEEL.darkened(.33))
		flute.rotation.z = angle
	box(self,"Side switch mount",Vector3(0,.061,.019),Vector3(.025,.006,.031),BLACK)
	var rubber_switch := cylinder(self,"Rubber push switch",Vector3(0,.065,.018),.010,.006,Color("#8d633d"))
	for i in range(3):
		box(rubber_switch,"Raised switch rib",Vector3(0,.003,-.004+i*.004),Vector3(.013,.002,.0015),BRASS)
	var clip := box(self,"Spring belt clip",Vector3(.025,.046,-.069),Vector3(.004,.014,.094),STEEL.darkened(.09))
	clip.rotation.y = -.05
	box(self,"Rolled belt clip tip",Vector3(.027,.046,-.118),Vector3(.005,.014,.012),STEEL)
	var plate := box(self,"Torch name plate",Vector3(0,.061,-.033),Vector3(.020,.0025,.048),BODY.darkened(.25))
	var mark := make_label(plate,"FIELD",Vector3(0,.0017,0),30,.00022,Color("#babbab"))
	mark.rotation.x = -PI/2

func build_lamp_head() -> void:
	tube("Lamp shoulder",.060,.035,.022,.057,BODY)
	tube("Machined head barrel",.102,.037,.035,.033,BODY.darkened(.11))
	for z in [.082,.091,.100]:
		bezel("Heat sink ridge",z,.035,.039,BLACK)
	tube("Black bezel outer rim",.123,.038,.038,.016,BLACK)
	tube("Reflector bowl",.128,.032,.026,.008,STEEL)
	bezel("Polished reflector rim",.133,.028,.034,STEEL.lightened(.27))
	var lens := tube("Recessed clear lens",.133,.028,.028,.002,Color(GLASS,.44))
	lens.material_override.roughness = .11
	lens.material_override.metallic = .56
	lens.material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	lens.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	tube("Unpowered LED package",.134,.007,.007,.002,Color("#cfc297"))
	bezel("Raised impact lip",.132,.034,.038,BLACK)

func build_beam() -> void:
	var light := SpotLight3D.new()
	light.name = "Torch beam"
	add_child(light)
	light.position = Vector3(0,.039,.145)
	light.rotation.y = PI
	light.light_color = Color("#fff0d2")
	light.light_energy = 3.4
	light.spot_range = 17.0
	light.spot_angle = 19.0
	light.shadow_enabled = true
	light.visible = false
