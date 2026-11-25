extends SceneTree

const BUILDER = preload("res://grocery_props.gd")

func _initialize() -> void:
	call_deferred("bake")

func bake() -> void:
	var builder := BUILDER.new()
	root.add_child(builder)
	var assets := {
		"water_bottles": builder.water(),

		"canned_beans": builder.beans(),

		"canned_soup": builder.soup(),

		"manual_can_opener": builder.opener(),
		"dog_food": builder.dog_food(),
		"cold_drinks": builder.cold_drinks(),
		"chips": builder.chips()

	}
	var selected := OS.get_cmdline_user_args()
	for id in assets:
		if not selected.is_empty() and id not in selected:
			continue
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
