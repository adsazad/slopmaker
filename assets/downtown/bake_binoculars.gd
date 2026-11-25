extends SceneTree

const BUILDER = preload("res://binoculars.gd")

func _initialize() -> void:
	call_deferred("bake")

func bake() -> void:
	var asset := BUILDER.new()
	root.add_child(asset)
	asset.build()
	asset.set_script(null)
	for child in asset.get_children():
		set_owner_recursive(child,asset)
	var scene := PackedScene.new()
	var result := scene.pack(asset)
	if result == OK:
		result = ResourceSaver.save(scene,"res://scenes/binoculars.scn",ResourceSaver.FLAG_COMPRESS)
	quit(result)

func set_owner_recursive(node: Node,owner_node: Node) -> void:
	node.owner = owner_node
	for child in node.get_children():
		set_owner_recursive(child,owner_node)
