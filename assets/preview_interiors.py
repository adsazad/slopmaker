"""Render six sample rooms from the exported Sand3D props."""
import json
from math import radians
from pathlib import Path
from tempfile import TemporaryDirectory

import bpy
import numpy as np
from mathutils import Vector

ROOT = Path(__file__).with_name("interiors")

# Each placement is asset name, (X, Y, Z) in metres, and heading in degrees.
ROOMS = {
    "Living room": [
        ("three_seat_sofa", (-.48, 1.35, 0), 0),
        ("armchair", (1.46, .58, 0), -32),
        ("area_rug", (-.40, .05, 0), 0),
        ("coffee_table", (-.42, .13, .013), 0),
        ("book_stack", (-.18, .12, .446), 8),
        ("side_table", (-1.87, 1.39, 0), 0),
        ("table_lamp", (-1.87, 1.39, .524), 0),
        ("media_console", (-.65, -1.27, 0), 165),
        ("television", (-.65, -1.27, .52), 165),
        ("floor_lamp", (1.89, 1.48, 0), 0),
        ("framed_print", (-.50, 1.82, 1.15), 0),
        ("potted_plant", (-1.93, -1.0, 0), 0),
    ],
    "Bedroom": [
        ("double_bed", (.15, .66, 0), 0),
        ("nightstand", (1.31, 1.47, 0), 0),
        ("table_lamp", (1.31, 1.48, .545), 0),
        ("wardrobe", (-1.84, .52, 0), 72),
        ("dresser", (-1.49, -1.26, 0), 12),
        ("book_stack", (-1.68, -1.27, .875), 0),
        ("area_rug", (.19, -.64, 0), 0),
        ("laundry_hamper", (1.80, -.83, 0), 0),
        ("double_hung_window", (.08, 1.81, 1.15), 0),
        ("curtain_pair", (.08, 1.67, 1.01), 0),
    ],
    "Kitchen and dining": [
        ("refrigerator", (-1.82, 1.35, 0), 0),
        ("kitchen_sink", (-.96, 1.43, 0), 0),
        ("range_oven", (-.16, 1.43, 0), 0),
        ("base_cabinet", (.62, 1.43, 0), 0),
        ("dishwasher", (1.38, 1.43, 0), 0),
        ("wall_cabinet", (-.92, 1.55, 1.4), 0),
        ("wall_cabinet", (.66, 1.55, 1.4), 0),
        ("microwave", (.63, 1.40, .904), 0),
        ("stockpot", (-.01, 1.31, .897), 0),
        ("dining_table", (.43, -.64, 0), 0),
        ("dish_set", (.43, -.71, .758), 0),
        ("dining_chair", (1.47, -.65, 0), -90),
        ("dining_chair", (-.60, -.63, 0), 90),
        ("wall_clock", (-.13, 1.83, 1.67), 0),
    ],
    "Bathroom": [
        ("shower_stall", (-1.63, 1.24, 0), 0),
        ("bathroom_vanity", (-.48, 1.50, 0), 0),
        ("mirror", (-.48, 1.82, 1.16), 0),
        ("wall_sconce", (-1.0, 1.77, 1.70), 0),
        ("toilet", (.50, 1.46, 0), 0),
        ("bathtub", (1.48, .36, 0), 180),
        ("bath_mat", (.05, .30, 0), 0),
        ("towel_rack", (1.52, 1.81, 1.03), 0),
        ("wastebasket", (-1.1, .79, 0), 0),
    ],
    "Home office": [
        ("writing_desk", (-.38, 1.22, 0), 0),
        ("desk_chair", (-.33, .47, 0), 169),
        ("laptop", (-.41, 1.17, .762), 0),
        ("table_lamp", (.05, 1.39, .762), 0),
        ("bookcase", (-1.61, 1.45, 0), 0),
        ("book_stack", (-1.61, 1.43, 1.197), 0),
        ("book_stack", (-1.84, 1.43, .837), 14),
        ("filing_cabinet", (.74, 1.47, 0), 0),
        ("potted_plant", (1.66, 1.07, 0), 0),
        ("framed_print", (-.33, 1.81, 1.37), 0),
        ("area_rug", (-.15, .07, 0), 0),
    ],
    "Entry and laundry": [
        ("interior_door", (1.59, 1.76, 0), 0),
        ("light_switch", (.91, 1.81, 1.12), 0),
        ("shoe_bench", (.22, 1.51, 0), 0),
        ("coat_hooks", (.25, 1.81, 1.38), 0),
        ("entry_mat", (1.59, 1.02, 0), 0),
        ("washing_machine", (-1.77, 1.44, 0), 0),
        ("tumble_dryer", (-1.12, 1.44, 0), 0),
        ("floating_shelf", (-1.43, 1.78, 1.16), 0),
        ("storage_box", (-1.44, 1.67, 1.35), 0),
        ("laundry_hamper", (-.77, .64, 0), 0),
        ("storage_shelving", (-1.94, -.12, 0), 77),
        ("storage_box", (-1.95, -.12, .537), 77),
    ],
}

WALL_COLORS = [(0.78, 0.77, 0.68, 1), (0.70, 0.73, 0.69, 1), (0.76, 0.76, 0.65, 1),
               (0.69, 0.77, 0.78, 1), (0.76, 0.73, 0.68, 1), (0.74, 0.72, 0.65, 1)]


def slab(name, p, size, color):
    bpy.ops.mesh.primitive_cube_add(size=1, location=p)
    obj = bpy.context.object
    obj.name = name
    obj.scale = size
    obj.color = color
    return obj


def place(path, position, heading=0):
    before = set(bpy.context.scene.objects)
    bpy.ops.import_scene.gltf(filepath=str(path))
    roots = [obj for obj in set(bpy.context.scene.objects) - before if obj.parent is None]
    pivot = bpy.data.objects.new(path.stem, None)
    bpy.context.scene.collection.objects.link(pivot)
    for obj in roots:
        obj.parent = pivot
    pivot.location = position
    pivot.rotation_euler.z = radians(heading)


def render_room(path, title, layout, wall_color, assets):
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for data in (bpy.data.meshes, bpy.data.materials, bpy.data.cameras):
        for item in list(data):
            if item.users == 0:
                data.remove(item)
    scene = bpy.context.scene
    floor_color = (0.56, 0.46, 0.34, 1)
    if title == "Bathroom":
        floor_color = (0.45, 0.52, 0.51, 1)
    plank_color = [floor_color, tuple(c * .94 for c in floor_color[:3]) + (1,)]
    slab("Room section", (0, 0, -.108), (4.62, 3.92, .185), (.45, .42, .36, 1))
    for i in range(14):
        slab("Floor course", (0, -1.82 + .273 * i, -.016),
             (4.59, .270, .032), plank_color[i % 2])
    if title == "Bedroom":
        # Leave a real opening in the wall behind the window module.
        slab("Lower back wall", (0, 1.887, .575), (4.61, .12, 1.15), wall_color)
        slab("Left wall infill", (-1.397, 1.887, 1.755), (1.815, .12, 1.21), wall_color)
        slab("Right wall infill", (1.477, 1.887, 1.755), (1.66, .12, 1.21), wall_color)
    else:
        slab("Back wall", (0, 1.887, 1.18), (4.61, .12, 2.36), wall_color)
    slab("Left cutaway wall", (-2.265, .47, .72), (.12, 2.75, 1.44), wall_color)
    slab("Back skirting", (0, 1.804, .049), (4.45, .042, .098), (.78, .72, .60, 1))
    for name, location, heading in layout:
        place(assets[name], location, heading)

    camera_data = bpy.data.cameras.new("Catalog camera")
    camera = bpy.data.objects.new("Catalog camera", camera_data)
    scene.collection.objects.link(camera)
    camera.location = (5.6, -8.6, 6.45)
    camera.rotation_euler = (Vector((0, .04, .99)) - camera.location).to_track_quat("-Z", "Y").to_euler()
    camera_data.type = "ORTHO"
    camera_data.ortho_scale = 7.16
    scene.camera = camera
    scene.render.engine = "BLENDER_WORKBENCH"
    shading = scene.display.shading
    shading.light = "STUDIO"
    shading.color_type = "MATERIAL"
    # Workbench uses the viewport color of material-less objects.
    for obj in scene.objects:
        if obj.type == "MESH" and not obj.data.materials:
            mat = bpy.data.materials.new(obj.name)
            mat.diffuse_color = obj.color
            obj.data.materials.append(mat)
    shading.show_shadows = True
    shading.show_specular_highlight = False
    shading.show_cavity = True
    shading.cavity_type = "BOTH"
    shading.curvature_ridge_factor = .48
    shading.curvature_valley_factor = .42
    shading.background_type = "WORLD"
    scene.world.color = (.75, .75, .70)
    scene.render.resolution_x = 680
    scene.render.resolution_y = 499
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.filepath = str(path)
    bpy.ops.render.render(write_still=True)


def main():
    inventory = json.loads((ROOT / "inventory.json").read_text(encoding="utf-8"))
    assets = {entry["name"]: ROOT / entry["asset"] for entry in inventory}
    width, height, gap = 680, 499, 12
    sheet_width, sheet_height = 3 * width + 4 * gap, 2 * height + 3 * gap
    sheet = np.empty((sheet_height, sheet_width, 4), dtype=np.float32)
    sheet[:] = (.91, .89, .85, 1)
    with TemporaryDirectory(dir=ROOT) as temp:
        for i, (title, layout) in enumerate(ROOMS.items()):
            path = Path(temp) / f"room_{i}.png"
            render_room(path, title, layout, WALL_COLORS[i], assets)
            x = gap + (i % 3) * (width + gap)
            y = gap + (1 - i // 3) * (height + gap)
            room = bpy.data.images.load(str(path))
            pixels = np.empty(width * height * 4, dtype=np.float32)
            room.pixels.foreach_get(pixels)
            sheet[y:y + height, x:x + width] = pixels.reshape((height, width, 4))
            bpy.data.images.remove(room)
    output = bpy.data.images.new("Interior kit preview", width=sheet_width, height=sheet_height)
    output.pixels.foreach_set(sheet.ravel())
    output.filepath_raw = str(ROOT / "interior_kit_preview.png")
    output.file_format = "PNG"
    output.save()


if __name__ == "__main__":
    main()
