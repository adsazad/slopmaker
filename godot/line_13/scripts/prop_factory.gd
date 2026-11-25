extends RefCounted
class_name PilotPropFactory


static func material(hex_color: String, roughness: float = 0.75, metallic: float = 0.0, glow: float = 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color.from_string(hex_color, Color.WHITE)
	mat.roughness = roughness
	mat.metallic = metallic
	if glow > 0.0:
		mat.emission_enabled = true
		mat.emission = mat.albedo_color
		mat.emission_energy_multiplier = glow
	return mat


static func box(parent: Node3D, label: String, size: Vector3, at: Vector3, mat: Material, bevel: float = 0.0) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.name = label
	instance.mesh = mesh
	instance.material_override = mat
	instance.position = at
	parent.add_child(instance)
	return instance


static func cylinder(parent: Node3D, label: String, diameter: float, height: float, at: Vector3, mat: Material, radial_segments: int = 12) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = diameter * 0.5
	mesh.bottom_radius = diameter * 0.5
	mesh.height = height
	mesh.radial_segments = radial_segments
	var instance := MeshInstance3D.new()
	instance.name = label
	instance.mesh = mesh
	instance.material_override = mat
	instance.position = at
	parent.add_child(instance)
	return instance


static func sphere(parent: Node3D, label: String, diameter: float, at: Vector3, mat: Material, radial_segments: int = 12, rings: int = 8) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = diameter * 0.5
	mesh.height = diameter
	mesh.radial_segments = radial_segments
	mesh.rings = rings
	var instance := MeshInstance3D.new()
	instance.name = label
	instance.mesh = mesh
	instance.material_override = mat
	instance.position = at
	parent.add_child(instance)
	return instance


static func label3d(parent: Node3D, label: String, value: String, at: Vector3, size: int, color: Color, outline: Color = Color(0.015, 0.02, 0.03, 1.0)) -> Label3D:
	var instance := Label3D.new()
	instance.name = label
	instance.text = value
	instance.position = at
	instance.font_size = size
	instance.pixel_size = 0.004
	instance.modulate = color
	instance.outline_size = 5
	instance.outline_modulate = outline
	instance.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	parent.add_child(instance)
	return instance


static func beam(parent: Node3D, label: String, from: Vector3, to: Vector3, radius: float, mat: Material) -> MeshInstance3D:
	var span := to - from
	var instance := cylinder(parent, label, radius * 2.0, span.length(), (from + to) * 0.5, mat, 8)
	instance.quaternion = Quaternion(Vector3.UP, span.normalized())
	return instance
