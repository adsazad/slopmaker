extends "res://props.gd"

const ALUMINUM := Color("#858d88")
const STEEL := Color("#727b78")
const WOOD := Color("#905f3e")
const ENAMEL := Color("#bcb49a")
const DARK := Color("#303632")

func build() -> void:
	name = "Cooking Utensils"
	var pot := group(self,"Cooking pot",Vector3(-.15,0,-.10))
	vessel(pot,"Hollow aluminum pot",[[.001,.004],[.095,.004],[.103,.017],[.105,.132],[.104,.137],[.099,.138],[.098,.132],[.095,.016],[.001,.016]],ALUMINUM)
	for side in [-1,1]:
		for z in [-.030,.030]:
			box(pot,"Handle bracket",Vector3(side*.110,.090,z),Vector3(.027,.013,.013),STEEL)
			cylinder(pot,"Pot rivet",Vector3(side*.100,.090,z),.005,.009,STEEL).rotation.z = PI/2
		box(pot,"Insulated loop grip",Vector3(side*.134,.091,0),Vector3(.020,.017,.079),DARK)
	var lid := group(self,"Removable pot lid",Vector3(-.12,0,.125))
	vessel(lid,"Pressed lid crown",[[.001,.018],[.044,.017],[.096,.008],[.105,.003],[.107,.006],[.105,.011],[.044,.020],[.001,.022]],ALUMINUM.lightened(.12))
	cylinder(lid,"Bakélite lid knob",Vector3(0,.036,0),.020,.025,DARK)
	var pan := group(self,"Frying pan",Vector3(.16,0,-.15))
	vessel(pan,"Seasoned frying pan",[[.001,.005],[.102,.005],[.118,.016],[.123,.048],[.120,.053],[.115,.052],[.110,.023],[.100,.013],[.001,.013]],DARK.lightened(.16))
	box(pan,"Pan handle shank",Vector3(.139,.040,0),Vector3(.057,.013,.024),STEEL)
	box(pan,"Wooden pan grip",Vector3(.205,.045,0),Vector3(.094,.023,.026),WOOD).rotation.z = .10
	cylinder(pan,"Handle hanging eye",Vector3(.240,.058,0),.005,.003,DARK)
	var plate := group(self,"Enamel plate",Vector3(.15,0,.125))
	vessel(plate,"Rolled plate",[[.001,.004],[.077,.004],[.104,.011],[.111,.021],[.111,.026],[.106,.027],[.100,.021],[.075,.013],[.001,.013]],ENAMEL)
	vessel(plate,"Dark enamel rim",[[.105,.026],[.108,.028],[.112,.026],[.112,.022],[.108,.020]],Color("#4d6763"))
	var mug := group(self,"Enamel mug",Vector3(.356,0,.101))
	vessel(mug,"Hollow enamel cup",[[.001,.003],[.038,.003],[.041,.010],[.041,.086],[.039,.090],[.036,.089],[.036,.014],[.001,.014]],ENAMEL)
	vessel(mug,"Dark cup rim",[[.039,.085],[.042,.086],[.042,.089],[.039,.091],[.036,.089]],Color("#4d6763"))
	var handle := TorusMesh.new()
	handle.inner_radius = .019
	handle.outer_radius = .024
	mesh(mug,"Mug handle",handle,Vector3(.049,.048,0),ENAMEL).rotation.x = PI/2
	cutlery("Spoon",Vector3(-.34,0,.195),false)
	cutlery("Fork",Vector3(-.285,0,.197),true)
	var ladle := group(self,"Ladle",Vector3(-.33,0,.07))
	vessel(ladle,"Deep ladle bowl",[[.001,.003],[.019,.005],[.032,.013],[.036,.028],[.034,.030],[.031,.027],[.028,.016],[.001,.007]],ALUMINUM)
	box(ladle,"Ladle metal shank",Vector3(0,.022,-.091),Vector3(.012,.005,.140),STEEL)
	box(ladle,"Wooden ladle grip",Vector3(0,.025,-.151),Vector3(.022,.013,.060),WOOD)

func cutlery(title: String,pos: Vector3,fork: bool) -> void:
	var item := group(self,title,pos)
	box(item,"Tapered handle",Vector3(0,.007,.043),Vector3(.012,.007,.092),ALUMINUM)
	if fork:
		box(item,"Fork shoulder",Vector3(0,.008,-.009),Vector3(.024,.005,.021),STEEL)
		for i in range(4):
			box(item,"Fork tine",Vector3((i-1.5)*.006,.009,-.024),Vector3(.003,.004,.021),ALUMINUM)
	else:
		var bowl := group(item,"Spoon bowl",Vector3(0,0,-.021))
		bowl.scale.z = 1.5
		vessel(bowl,"Shallow spoon bowl",[[.001,.004],[.010,.005],[.015,.009],[.014,.011],[.010,.008],[.001,.007]],ALUMINUM)

func vessel(parent: Node3D,title: String,profile: Array,tint: Color) -> void:
	var builder := SurfaceTool.new()
	builder.begin(Mesh.PRIMITIVE_TRIANGLES)
	var steps := 32
	for ring in range(profile.size()-1):
		for sector in range(steps):
			var angle := TAU*sector/steps
			var next := TAU*(sector+1)/steps
			var a := revolve(profile[ring],angle)
			var b := revolve(profile[ring+1],angle)
			var c := revolve(profile[ring],next)
			var d := revolve(profile[ring+1],next)
			for point in [a,b,c,c,b,d]:
				builder.add_vertex(point)
	builder.generate_normals()
	var item := mesh(parent,title,builder.commit(),Vector3.ZERO,tint)
	item.material_override.metallic = .42
	item.material_override.roughness = .39
	item.material_override.cull_mode = BaseMaterial3D.CULL_DISABLED

func revolve(point: Array,angle: float) -> Vector3:
	return Vector3(cos(angle)*point[0],point[1],sin(angle)*point[0])
