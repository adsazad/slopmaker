"""Render a contact sheet of exported Sand3D models with Blender's Python module."""
import argparse
from math import radians
import bpy
from pathlib import Path
from mathutils import Vector

root = Path(__file__).resolve().parent
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("group", nargs="?", choices=("original", "trees", "houses", "street"), default="original")
group = parser.parse_args().group
if group == "street":
    folder = root / "houses"
    out = folder / "street_buildings_preview.png"
    names = ("bay_window_house", "ochre_townhouse", "red_gable_house",
             "corner_grocery", "brick_walkup")
    positions = (-19, -10, -.5, 9.2, 19.1)
    view_width = 52
elif group == "houses":
    folder = root / "houses"
    out = folder / "new_houses_preview.png"
    names = ("craftsman_cottage", "brick_rowhouse", "alpine_a_frame")
    positions = (-11.9, 0, 11)
    view_width = 37
elif group == "trees":
    folder = root / "trees"
    out = folder / "new_trees_preview.png"
    names = ("autumn_maple", "weeping_willow", "italian_cypress")
    positions = (-8.1, 0, 7.5)
    view_width = 25.7
else:
    folder = root / "trees"
    out = folder / "trees_preview.png"
    names = ("round_oak", "layered_pine", "tropical_palm", "silver_birch")
    positions = (-10.5, -3.4, 3.0, 10.2)
    view_width = 30
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
for name, position in zip(names, positions):
    before = set(bpy.context.scene.objects)
    bpy.ops.import_scene.gltf(filepath=str(folder / f"{name}.glb"))
    pivot = bpy.data.objects.new(f"{name} display", None)
    bpy.context.scene.collection.objects.link(pivot)
    for ob in set(bpy.context.scene.objects) - before:
        if ob != pivot and ob.parent is None:
            ob.parent = pivot
    pivot.location.x = position
    if group in ("houses", "street"):
        pivot.rotation_euler.z = radians(22)

bpy.ops.mesh.primitive_plane_add(size=200, location=(0, 0, -.025))
ground = bpy.data.materials.new("Warm gray ground")
ground.diffuse_color = (.78, .80, .74, 1)
bpy.context.object.data.materials.append(ground)

scene = bpy.context.scene
scene.render.engine = "BLENDER_WORKBENCH"
scene.display.shading.light = "STUDIO"
scene.display.shading.color_type = "MATERIAL"
scene.display.shading.show_shadows = True
scene.display.shading.show_specular_highlight = False
scene.display.shading.show_cavity = True
scene.display.shading.cavity_type = "BOTH"
scene.display.shading.curvature_ridge_factor = .55
scene.display.shading.curvature_valley_factor = .45
scene.display.shading.background_type = "WORLD"
scene.world.color = (0.72, 0.79, 0.84)
camera_data = bpy.data.cameras.new("preview_camera")
camera = bpy.data.objects.new("preview_camera", camera_data)
scene.collection.objects.link(camera)
camera.location = (0, -39, 15) if group != "street" else (0, -62, 19)
target = Vector((0, 0, 4.08))
camera.rotation_euler = (target - Vector(camera.location)).to_track_quat("-Z", "Y").to_euler()
camera_data.type = "ORTHO"
camera_data.ortho_scale = view_width
camera_data.clip_end = 100
scene.camera = camera
scene.render.resolution_x = 1800
scene.render.resolution_y = 690 if group in ("original", "street") else 810
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = "PNG"
scene.render.filepath = str(out)
bpy.ops.render.render(write_still=True)
print(out)
