extends Node3D

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

