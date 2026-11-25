extends SceneTree

const BUILDER = preload("res://sporting_goods_props.gd")

func _initialize() -> void:
	call_deferred("bake")

func bake() -> void:
	var builder := BUILDER.new()
	root.add_child(builder)
	var assets := {
		"pistol": builder.pistol(),
		"short_shotgun": builder.shotgun(),
		"pistol_ammunition": builder.pistol_refills(),
		"shotgun_ammunition": builder.shotgun_refills()
	}
	for id in assets:
		var asset: Node3D = assets[id]
		for child in asset.get_children():
			set_owner_recursive(child,asset)
		var scene := PackedScene.new()
		var result := scene.pack(asset)
		if result == OK:
			result = ResourceSaver.save(scene,"res://scenes/"+id+".scn",ResourceSaver.FLAG_COMPRESS)
		if result != OK:
			quit(result)
			return
	quit()

func set_owner_recursive(node: Node,owner_node: Node) -> void:
	node.owner = owner_node
	for child in node.get_children():
		set_owner_recursive(child,owner_node)
