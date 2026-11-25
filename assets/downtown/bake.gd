extends SceneTree

const DOWNTOWN = preload("res://downtown.gd")

func _initialize() -> void:
	call_deferred("bake")

func own_branch(node: Node, scene_root: Node) -> void:
	node.owner = scene_root
	if node.scene_file_path.is_empty():
		for child in node.get_children():
			own_branch(child,scene_root)

func write_scene(scene_root: Node3D,path: String) -> Error:
	for child in scene_root.get_children():
		own_branch(child,scene_root)
	var packed := PackedScene.new()
	var result := packed.pack(scene_root)
	if result != OK:
		return result
	return ResourceSaver.save(packed,path,ResourceSaver.FLAG_COMPRESS)

func bake() -> void:
	var builder := DOWNTOWN.new()
	root.add_child(builder)
	var result := OK
	for block in builder.get_children():
		if not str(block.name).begins_with("Block "):
			continue
		for building in block.get_children():
			if building.get_node_or_null("EntryDoorPivot") == null:
				continue
			var asset := building.duplicate() as Node3D
			asset.transform = Transform3D.IDENTITY
			var file_name := str(asset.name).to_snake_case().replace(" ","_")
			result = write_scene(asset,"res://scenes/"+file_name+".scn")
			asset.free()
			if result != OK:
				quit(result)
				return
	var furniture := builder.get_node("Street furniture and vehicles")
	for item in [["Cast iron bench","bench"],["Tree planter","tree_planter"],
			["Bus shelter","bus_shelter"],["Litter bin","litter_bin"],["Unpowered street lamp","street_lamp"]]:
		var prop := furniture.get_node(item[0]).duplicate() as Node3D
		prop.transform = Transform3D.IDENTITY
		result = write_scene(prop,"res://scenes/"+item[1]+".scn")
		prop.free()
		if result != OK:
			quit(result)
			return
	var assembled := Node3D.new()
	assembled.name = "Downtown"
	root.add_child(assembled)
	for child in builder.get_children():
		child.reparent(assembled,false)
	result = write_scene(assembled,"res://scenes/downtown.scn")
	quit(result)
