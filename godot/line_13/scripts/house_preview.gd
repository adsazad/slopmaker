extends Node3D
const PF=preload("res://scripts/prop_factory.gd")
const HOUSE=preload("res://scenes/house_asset.tscn")
func _ready():
	var env=Environment.new(); env.background_mode=Environment.BG_COLOR; env.background_color=Color("#25313e"); env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR; env.ambient_light_color=Color("#d3d9de"); env.ambient_light_energy=0.8
	var we=WorldEnvironment.new(); we.environment=env; add_child(we)
	var sun=DirectionalLight3D.new(); sun.rotation_degrees=Vector3(-48,-28,0); sun.light_energy=1.4; sun.shadow_enabled=true; add_child(sun)
	var old=HOUSE.instantiate(); old.design=0; old.position.x=-7.0; old.rotation.y=0.25; add_child(old)
	var rental=HOUSE.instantiate(); rental.design=1; rental.position.x=7.0; rental.rotation.y=-0.25; add_child(rental)
	var camera=Camera3D.new(); camera.position=Vector3(0,8,28); camera.fov=48; add_child(camera); camera.look_at(Vector3(0,3.2,0)); camera.current=true
