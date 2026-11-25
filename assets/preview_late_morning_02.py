"""Stage the Episode 2 kit for a roadside preview."""
from pathlib import Path
from math import radians

import bpy
from mathutils import Vector

ASSETS = Path(__file__).resolve().parent
KIT = ASSETS / "late_morning_02"

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.world = bpy.data.worlds.new("Daylight")


def place(relative, where, turn=0, kit=KIT):
    before = set(scene.objects)
    bpy.ops.import_scene.gltf(filepath=str(kit / (relative + ".glb")))
    roots = [ob for ob in set(scene.objects) - before if ob.parent is None]
    anchor = bpy.data.objects.new(Path(relative).stem, None)
    scene.collection.objects.link(anchor)
    for ob in roots:
        ob.parent = anchor
    anchor.location = where
    anchor.rotation_euler.z = radians(turn)
    return anchor


def base(name, center, dims, rgb):
    bpy.ops.mesh.primitive_cube_add(size=1, location=center)
    ob = bpy.context.object
    ob.name = name
    ob.dimensions = dims
    material = bpy.data.materials.new(name)
    material.diffuse_color = (*rgb, 1)
    ob.data.materials.append(material)


base("Dirt and grass", (0, 0, -.24), (95, 100, .48), (.43, .47, .35))
base("Station forecourt", (7.0, 2.6, -.085), (23.5, 18.5, .17), (.54, .53, .48))
for y in (-24, 0, 24):
    place("highway/two_lane_highway_24m", (-8.5, y, -.06))
place("highway/overhead_west_route_sign", (-8.5, 2.5, .08))
place("highway/highway_guardrail_8m", (-13.7, -7.5, .02))
place("highway/county_road_signpost", (-2.9, -7.8, 0))
place("highway/roadside_utility_pole", (-14.2, 7.5, 0))
place("houses/borrowed_split_level", (-21, 8.5, 0), 53)
place("houses/cedar_roadside_bungalow", (-19.5, -1.1, 0), 66)
for model, p in [("round_oak", (-22, 16, 0)), ("layered_pine", (-17, 17, 0)),
                 ("silver_birch", (-25, 0, 0)), ("italian_cypress", (16, 11.0, 0))]:
    place("trees/" + model, p, kit=ASSETS)

place("station/last_stop_shop_shell", (11.5, 8.1, 0))
place("station/shop_glass_door", (11.10, 5.0, .139), -34)
place("station/fuel_canopy", (3.20, .90, 0))
place("station/last_stop_price_sign", (-.7, -6.2, 0))
for x in (.9, 4.5):
    place("station/dark_fuel_dispenser", (x, .32, 0))
    place("station/pump_hose", (x, .32, 0))
    place("station/fuel_nozzle", (x+.45, .15, .979), 0)

truck = place("vehicle/fathers_pickup", (8.2, -2.15, .02), -12)
door = place("vehicle/pickup_passenger_door", (0, 0, 0), -23)
door.parent = truck
door.location = (.852, -.771, .665)
for x in (-.32, -.07):
    supply = place("props/pickup_water_jug", (0, 0, 0))
    supply.parent = truck
    supply.location = (x, 1.25, .73)

camera_data = bpy.data.cameras.new("Roadside camera")
camera = bpy.data.objects.new("Roadside camera", camera_data)
scene.collection.objects.link(camera)
camera.location = (18, -36, 20)
camera.rotation_euler = (Vector((-4.8, 3.0, 1.62)) - camera.location).to_track_quat("-Z", "Y").to_euler()
camera_data.type = "ORTHO"
camera_data.ortho_scale = 51
scene.camera = camera
scene.render.engine = "BLENDER_WORKBENCH"
shading = scene.display.shading
shading.light = "STUDIO"
shading.color_type = "MATERIAL"
shading.show_shadows = True
shading.show_specular_highlight = False
shading.show_cavity = True
shading.cavity_type = "BOTH"
shading.background_type = "WORLD"
scene.world.color = (.71, .75, .78)
scene.render.resolution_x = 1700
scene.render.resolution_y = 800
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = "PNG"
scene.render.filepath = str(KIT / "roadside_preview.png")
bpy.ops.render.render(write_still=True)
