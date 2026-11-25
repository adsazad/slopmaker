extends Node3D

const VIEWS := [
	[Vector3(-2.1,13.1,18.6),Vector3(0,2.50,-31.0),58.0],
	[Vector3(-8.36,1.78,3.20),Vector3(-11.90,1.85,-7.1),65.0],
	[Vector3(-13.57,1.82,1.30),Vector3(-18.74,1.44,-.68),68.0],
	[Vector3(-3.44,2.58,-35.1),Vector3(-11.90,1.74,-46.2),62.0],
	[Vector3(-12.54,1.94,-46.56),Vector3(-20.40,1.6,-46.90),66.0],
	[Vector3(8.32,1.94,-76.2),Vector3(-6.76,2.22,-85.0),64.0]
]

var camera: Camera3D
var capture := false
var shot := 0
var frames := 0
var dragging := false

func _ready() -> void:
	capture = OS.get_cmdline_user_args().has("--capture")
	var town := load("res://scenes/downtown.scn") as PackedScene
	add_child(town.instantiate())
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var material := ProceduralSkyMaterial.new()
	material.sky_top_color = Color("#6e8795")
	material.sky_horizon_color = Color("#d3d5bd")
	material.ground_bottom_color = Color("#777562")
	material.ground_horizon_color = material.sky_horizon_color
	material.sun_angle_max = 0
	sky.sky_material = material
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#c4ccc2")
	environment.ambient_light_energy = .73
	world.environment = environment
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-37,-38,0)
	sun.light_color = Color("#ffe3ba")
	sun.light_energy = 1.16
	sun.shadow_enabled = true
	add_child(sun)
	camera = Camera3D.new()
	camera.near = .04
	camera.far = 240
	add_child(camera)
	camera.current = true
	apply_view(0)

func apply_view(index: int) -> void:
	shot = index
	var view: Array = VIEWS[index]
	camera.position = view[0]
	camera.look_at(view[1])
	camera.fov = view[2]

func _unhandled_input(event: InputEvent) -> void:
	if capture:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode >= KEY_1 and event.keycode <= KEY_6:
			apply_view(event.keycode-KEY_1)
		elif event.keycode == KEY_ESCAPE:
			get_tree().quit()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		dragging = event.pressed
	elif event is InputEventMouseMotion and dragging:
		camera.rotation.y -= event.relative.x*.003
		camera.rotation.x = clampf(camera.rotation.x-event.relative.y*.003,-1.56,1.56)

func _process(delta: float) -> void:
	if capture:
		frames += 1
		if frames >= 24*(shot+1):
			if shot == VIEWS.size()-1:
				get_tree().quit()
			else:
				apply_view(shot+1)
		return
	var movement := Vector3(
		float(Input.is_physical_key_pressed(KEY_D))-float(Input.is_physical_key_pressed(KEY_A)),
		float(Input.is_physical_key_pressed(KEY_E))-float(Input.is_physical_key_pressed(KEY_Q)),
		float(Input.is_physical_key_pressed(KEY_S))-float(Input.is_physical_key_pressed(KEY_W)))
	camera.translate(movement.normalized()*delta*7.4)
