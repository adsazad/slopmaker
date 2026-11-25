"""Build the second-wave Sand3D cast and an at-a-glance roster render.

Run from the workspace root:
    .venv/Scripts/python.exe assets/characters/build_roster.py

Each GLB keeps the avatar's body parts as separately named meshes and has its
own origin at the soles. The roster render is for browsing; it is not an asset.
"""

from __future__ import annotations

import json
from pathlib import Path

import bpy
import sand3d as s3d
from mathutils import Vector


HERE = Path(__file__).resolve().parent
OUT = HERE / "roster"

# Character design records; STORY_ORDER below controls story and display order.
CAST = [
    {
        "id": "rhea_star_scout", "name": "Rhea Star Scout", "role": "curious trailblazer",
        "skin": "#8A5336", "torso": "#8657D6", "sleeve": "#E987B4", "pants": "#303B62",
        "boots": "#302B41", "sole": "#F0C45B", "accent": "#F7D653", "trim": "#C4B5F2",
        "head": "starband", "gear": "wings",
    },
    {
        "id": "byte_arcade_runner", "name": "Byte Arcade Runner", "role": "arcade tinkerer",
        "skin": "#F0C59B", "torso": "#173846", "sleeve": "#18ABB3", "pants": "#252B39",
        "boots": "#E1E9DB", "sole": "#7BE3C0", "accent": "#C3F25B", "trim": "#5ED9D5",
        "head": "headphones", "gear": "screen",
    },
    {
        "id": "fern_garden_ranger", "name": "Fern Garden Ranger", "role": "keeper of the wild paths",
        "skin": "#593A2D", "torso": "#507D46", "sleeve": "#D59A4C", "pants": "#304B3B",
        "boots": "#49352D", "sole": "#C9A56B", "accent": "#D9E89D", "trim": "#90B56A",
        "head": "ranger", "gear": "satchel",
    },
    {
        "id": "jax_street_skater", "name": "Jax Street Skater", "role": "bold shortcut finder",
        "skin": "#7A4639", "torso": "#F06A3E", "sleeve": "#41435C", "pants": "#292D43",
        "boots": "#E7C54D", "sole": "#F2E8CE", "accent": "#EA4F63", "trim": "#F2B35C",
        "head": "beanie", "gear": "skateboard",
    },
    {
        "id": "luna_moon_mage", "name": "Luna Moon Mage", "role": "gentle spell-caster",
        "skin": "#E8C5A7", "torso": "#4D3978", "sleeve": "#9D67C7", "pants": "#342C55",
        "boots": "#332A42", "sole": "#D9C7EF", "accent": "#F5D36A", "trim": "#C6AAE7",
        "head": "wizard", "gear": "wand_cape",
    },
    {
        "id": "rex_dino_defender", "name": "Rex Dino Defender", "role": "courageous little guardian",
        "skin": "#A76A45", "torso": "#74B84C", "sleeve": "#F0A447", "pants": "#43503A",
        "boots": "#57442F", "sole": "#B8AA64", "accent": "#D9E65D", "trim": "#367B4C",
        "head": "dino", "gear": "spines",
    },
    {
        "id": "coral_captain", "name": "Coral Captain", "role": "cheerful map-reader",
        "skin": "#C98D62", "torso": "#C94E51", "sleeve": "#F0D5B1", "pants": "#263853",
        "boots": "#503A32", "sole": "#DDB766", "accent": "#F5D371", "trim": "#F4E0C2",
        "head": "captain", "gear": "parrot_patch",
    },
    {
        "id": "mira_wave_rider", "name": "Mira Wave Rider", "role": "sunny shoreline explorer",
        "skin": "#A86647", "torso": "#16A6AD", "sleeve": "#F18E91", "pants": "#25435F",
        "boots": "#E9EEE1", "sole": "#F0C45B", "accent": "#F4D16A", "trim": "#BCE9DE",
        "head": "goggles", "gear": "float",
    },
    {
        "id": "bolt_speed_runner", "name": "Bolt Speed Runner", "role": "first to every finish line",
        "skin": "#EECBAA", "torso": "#343B45", "sleeve": "#F3D43E", "pants": "#252A35",
        "boots": "#3BA9BB", "sole": "#E8E7D9", "accent": "#F5D746", "trim": "#4AC4C5",
        "head": "racer", "gear": "speed_bands",
    },
    {
        "id": "tavi_frost_explorer", "name": "Tavi Frost Explorer", "role": "patient mountain guide",
        "skin": "#805144", "torso": "#67B4D0", "sleeve": "#E5F0E9", "pants": "#486D83",
        "boots": "#4B5662", "sole": "#C7DBDD", "accent": "#E5C1A0", "trim": "#A7E4EA",
        "head": "arctic", "gear": "pack",
    },
    {
        "id": "echo_music_maker", "name": "Echo Music Maker", "role": "inventor of catchy tunes",
        "skin": "#D5976D", "torso": "#7652B7", "sleeve": "#83BE70", "pants": "#30354B",
        "boots": "#E7E5D5", "sole": "#E1BC5E", "accent": "#F2C64C", "trim": "#B598E1",
        "head": "headphones", "gear": "guitar",
    },
    {
        "id": "atlas_space_mechanic", "name": "Atlas Space Mechanic", "role": "fixer of curious machines",
        "skin": "#684238", "torso": "#93AAB6", "sleeve": "#425D83", "pants": "#293A53",
        "boots": "#4B4B50", "sole": "#E9BF57", "accent": "#F4C84F", "trim": "#C2D6DC",
        "head": "space", "gear": "jetpack",
    },
]

# Suggested introduction order for the first story. The IDs stay unchanged so
# filenames remain stable while the cast can be resequenced here at any time.
STORY_ORDER = [
    "rhea_star_scout",
    "fern_garden_ranger",
    "jax_street_skater",
    "bolt_speed_runner",
    "byte_arcade_runner",
    "coral_captain",
    "mira_wave_rider",
    "tavi_frost_explorer",
    "rex_dino_defender",
    "luna_moon_mage",
    "echo_music_maker",
    "atlas_space_mechanic",
]
_CAST_BY_ID = {character["id"]: character for character in CAST}
CAST = [_CAST_BY_ID[character_id] for character_id in STORY_ORDER]


def part(name, size, pos, color, kind="plastic"):
    ob = s3d.box(name, *size)
    s3d.transform(ob, *pos)
    s3d.material(ob, kind, color=color)
    return ob


def sphere(name, diameter, pos, color, kind="plastic"):
    ob = s3d.sphere(name, diameter)
    s3d.transform(ob, pos[0], pos[1], pos[2] - diameter / 2)
    s3d.material(ob, kind, color=color)
    return ob


def cylinder(name, diameter, height, pos, color, kind="plastic"):
    ob = s3d.cylinder(name, diameter, height)
    s3d.transform(ob, *pos)
    s3d.material(ob, kind, color=color)
    return ob


def cone(name, diameter, height, top_diameter, pos, color, rx=0, ry=0, rz=0):
    ob = s3d.cone(name, diameter, height, d2=top_diameter)
    s3d.transform(ob, *pos, rx=rx, ry=ry, rz=rz)
    s3d.material(ob, "plastic", color=color)
    return ob


def build_avatar(cfg):
    prefix = cfg["id"]
    def n(label):
        return f"{prefix}_{label}"

    c = cfg
    p = []
    # Backpack and silhouette gear are behind the body (front is -Y).
    if c["gear"] in {"satchel", "pack", "jetpack"}:
        p.append(part(n("backpack"), (196, 112, 270), (0, 118, 565), c["trim"], "fabric"))
        p.append(part(n("backpack_flap"), (206, 120, 58), (0, 112, 816), c["accent"], "leather"))
    if c["gear"] == "wand_cape":
        p.append(part(n("cape"), (286, 38, 370), (0, 119, 505), c["torso"], "fabric"))
        p.append(part(n("cape_clasp"), (72, 18, 48), (0, 94, 815), c["accent"]))
    if c["gear"] == "wings":
        p.append(part(n("left_wing"), (112, 44, 210), (-184, 126, 650), c["trim"], "fabric"))
        p.append(part(n("right_wing"), (112, 44, 210), (184, 126, 650), c["trim"], "fabric"))
        p.append(part(n("left_wing_tip"), (80, 42, 100), (-208, 123, 770), c["accent"]))
        p.append(part(n("right_wing_tip"), (80, 42, 100), (208, 123, 770), c["accent"]))
    if c["gear"] == "skateboard":
        p.append(part(n("skate_deck"), (92, 36, 425), (164, 148, 505), c["accent"], "oak"))
        for z in (565, 835):
            p.append(cylinder(n(f"skate_wheel_{z}"), 54, 28, (164, 170, z), c["trim"], "rubber"))
    if c["gear"] == "spines":
        for index, z in enumerate((550, 630, 710, 790, 870), 1):
            p.append(cone(n(f"dino_spine_{index}"), 90, 110, 0, (0, 115, z), c["trim"], rx=-90))

    # Boots, simple block legs, and a belt establish a readable game-avatar shape.
    for side, x in (("left", -68), ("right", 68)):
        p.append(part(n(f"{side}_sole"), (116, 190, 24), (x, -12, 0), c["sole"], "rubber"))
        p.append(part(n(f"{side}_boot"), (112, 184, 82), (x, -10, 22), c["boots"], "leather"))
        p.append(part(n(f"{side}_leg"), (112, 142, 300), (x, 0, 104), c["pants"], "fabric"))
    p.append(part(n("waist"), (258, 150, 136), (0, 0, 380), c["pants"], "fabric"))
    p.append(part(n("belt"), (270, 162, 30), (0, -3, 432), c["boots"], "leather"))
    p.append(part(n("belt_buckle"), (48, 14, 34), (0, -86, 430), c["accent"], "painted_metal"))

    # A few role-specific chest details keep the shared body from feeling generic.
    p.append(part(n("torso"), (310, 164, 342), (0, 0, 518), c["torso"], "fabric"))
    p.append(part(n("front_placket"), (24, 12, 296), (0, -89, 540), c["trim"]))
    p.append(part(n("chest_badge"), (76, 16, 70), (90, -91, 690), c["accent"], "painted_metal"))
    p.append(sphere(n("badge_center"), 22, (90, -103, 725), c["trim"]))
    for side, sign in (("left", -1), ("right", 1)):
        x = sign * 204
        p.append(part(n(f"{side}_upper_sleeve"), (104, 142, 180), (x, 0, 654), c["sleeve"], "fabric"))
        p.append(part(n(f"{side}_forearm"), (100, 132, 166), (x, -2, 488), c["torso"], "fabric"))
        p.append(part(n(f"{side}_cuff"), (108, 140, 34), (x, -2, 454), c["trim"], "fabric"))
        p.append(part(n(f"{side}_hand"), (86, 108, 95), (x, -3, 359), c["skin"]))
    p.append(part(n("neck"), (76, 92, 56), (0, -1, 852), c["skin"]))

    # Each headgear option changes the outline as well as the color story.
    head = n("head")
    p.append(part(head, (236, 214, 236), (0, 0, 900), c["skin"]))
    h = c["head"]
    if h == "starband":
        p.append(part(n("star_headband"), (250, 222, 26), (0, 0, 1096), c["accent"]))
        p.append(part(n("star_emblem"), (48, 16, 48), (0, -121, 1108), c["trim"], "painted_metal"))
    elif h == "headphones":
        p.append(part(n("headphone_top"), (152, 32, 24), (0, 0, 1130), c["accent"]))
        for side, x in (("left", -126), ("right", 126)):
            p.append(part(n(f"{side}_earcup"), (40, 72, 92), (x, -2, 1036), c["trim"]))
            p.append(part(n(f"{side}_earcup_center"), (18, 42, 54), (x, -42, 1055), c["accent"]))
    elif h == "ranger":
        p.append(cylinder(n("hat_brim"), 320, 26, (0, 0, 1114), c["accent"], "fabric"))
        p.append(cylinder(n("hat_crown"), 152, 92, (0, 0, 1140), c["trim"], "fabric"))
        p.append(cone(n("hat_top"), 172, 48, 118, (0, 0, 1232), c["accent"]))
    elif h == "beanie":
        p.append(sphere(n("beanie"), 226, (0, -2, 1118), c["accent"], "fabric"))
        p.append(part(n("beanie_fold"), (250, 226, 35), (0, -2, 1115), c["trim"], "fabric"))
        p.append(sphere(n("beanie_pom"), 44, (0, 0, 1250), c["trim"], "fabric"))
    elif h == "wizard":
        p.append(cylinder(n("wizard_brim"), 300, 24, (0, 0, 1124), c["torso"], "fabric"))
        p.append(cone(n("wizard_hat"), 205, 255, 0, (0, 0, 1148), c["torso"]))
        p.append(sphere(n("wizard_star"), 48, (0, -102, 1164), c["accent"], "painted_metal"))
    elif h == "dino":
        p.append(part(n("dino_hood"), (274, 236, 94), (0, 0, 1100), c["trim"], "fabric"))
        p.append(part(n("dino_snout"), (156, 76, 58), (0, -133, 1080), c["accent"]))
    elif h == "captain":
        p.append(cylinder(n("captain_brim"), 280, 24, (0, 0, 1118), c["torso"]))
        p.append(part(n("captain_cap"), (218, 192, 112), (0, 0, 1142), c["sleeve"], "fabric"))
        p.append(part(n("captain_band"), (222, 198, 28), (0, -1, 1158), c["accent"]))
    elif h == "goggles":
        p.append(part(n("goggle_frame"), (140, 28, 42), (0, -116, 1040), c["accent"]))
        for side, x in (("left", -42), ("right", 42)):
            p.append(part(n(f"{side}_goggle_lens"), (48, 16, 28), (x, -133, 1045), c["trim"], "glass"))
        p.append(part(n("goggle_strap"), (260, 18, 22), (0, 0, 1040), c["accent"], "fabric"))
    elif h == "racer":
        p.append(part(n("racer_helmet"), (270, 245, 124), (0, 0, 1090), c["accent"]))
        p.append(part(n("racer_visor"), (214, 26, 56), (0, -130, 1060), c["trim"], "glass"))
        p.append(part(n("racer_stripe"), (50, 252, 70), (0, -8, 1144), c["boots"]))
    elif h == "arctic":
        p.append(part(n("hood_top"), (288, 250, 72), (0, 0, 1118), c["trim"], "fabric"))
        for side, x in (("left", -130), ("right", 130)):
            p.append(part(n(f"{side}_earflap"), (52, 234, 166), (x, 0, 1000), c["trim"], "fabric"))
        p.append(part(n("arctic_goggles"), (188, 24, 34), (0, -120, 1050), c["accent"], "glass"))
    elif h == "space":
        p.append(cylinder(n("space_helmet_rim"), 282, 24, (0, 0, 1120), c["trim"]))
        p.append(s3d.dome(n("space_helmet_dome"), 246, 185))
        s3d.transform(p[-1], 0, 0, 1144)
        s3d.material(p[-1], "glass", color=c["trim"], opacity=0.65, roughness=0.18)
        p.append(cylinder(n("antenna"), 16, 74, (80, 30, 1328), c["accent"]))
        p.append(sphere(n("antenna_tip"), 34, (80, 30, 1415), c["accent"]))

    # Standard expressive face; character-specific eye details can layer on top.
    for side, x in (("left", -48), ("right", 48)):
        p.append(sphere(n(f"{side}_eye"), 18, (x, -111, 1032), "#28252A"))
    p.append(part(n("smile"), (52, 10, 8), (0, -112, 979), "#7A3F39"))

    gear = c["gear"]
    if gear == "screen":
        p.append(part(n("arcade_screen"), (126, 20, 112), (0, -99, 620), "#233843"))
        p.append(part(n("screen_glow"), (92, 12, 62), (0, -112, 637), c["accent"], "light"))
    elif gear == "wand_cape":
        p.append(part(n("wand"), (22, 24, 320), (-250, -62, 425), c["accent"], "oak"))
        p.append(sphere(n("wand_crystal"), 58, (-250, -62, 754), c["trim"], "glass"))
    elif gear == "parrot_patch":
        p.append(part(n("eye_patch"), (56, 18, 38), (-48, -120, 1035), "#292932", "leather"))
        p.append(sphere(n("shoulder_parrot_body"), 82, (-186, -4, 790), "#58A76D"))
        p.append(cone(n("shoulder_parrot_beak"), 42, 46, 0, (-186, -56, 794), c["accent"], rx=90))
        p.append(sphere(n("shoulder_parrot_eye"), 12, (-164, -47, 812), "#27252A"))
    elif gear == "float":
        p.append(s3d.torus(n("rescue_float"), 330, 48))
        s3d.transform(p[-1], 0, 0, 436)
        s3d.material(p[-1], "plastic", color=c["accent"])
    elif gear == "spines":
        pass  # back spines were placed before the body so they sit behind it.
    elif gear == "speed_bands":
        for side, x in (("left", -204), ("right", 204)):
            p.append(part(n(f"{side}_speed_stripe"), (112, 150, 28), (x, -4, 577), c["accent"]))
    elif gear == "guitar":
        p.append(part(n("guitar_body"), (142, 44, 188), (192, -71, 462), c["accent"], "oak"))
        p.append(part(n("guitar_pickguard"), (86, 12, 116), (192, -98, 487), c["trim"]))
        p.append(part(n("guitar_neck"), (42, 40, 356), (192, -68, 630), c["boots"], "oak"))
        p.append(part(n("guitar_headstock"), (64, 44, 72), (192, -66, 990), c["accent"], "oak"))
    elif gear == "jetpack":
        for side, x in (("left", -76), ("right", 76)):
            p.append(cylinder(n(f"{side}_jet_tank"), 76, 280, (x, 190, 530), c["trim"]))
            p.append(cone(n(f"{side}_jet_nozzle"), 76, 76, 28, (x, 190, 454), c["accent"]))
    elif gear == "skateboard":
        pass
    elif gear in {"satchel", "pack"}:
        pass
    elif gear == "wings":
        pass

    # Fern gets a broad utility pouch to distinguish the ranger silhouette.
    if gear == "satchel":
        p.append(part(n("trail_pouch"), (110, 76, 110), (184, -64, 540), c["accent"], "leather"))
        p.append(part(n("trail_pouch_flap"), (114, 18, 38), (184, -108, 594), c["trim"], "leather"))

    root = s3d.assembly(prefix, *p).root
    return root


def add_label(text, x, y):
    data = bpy.data.curves.new(f"label_{text}", "FONT")
    data.body = text
    data.size = 112
    data.align_x = "CENTER"
    data.extrude = 0
    ob = bpy.data.objects.new(f"label_{text}", data)
    bpy.context.scene.collection.objects.link(ob)
    ob.location = (x, y, 5)
    ob.rotation_euler = (0, 0, 0)  # faces the overhead camera from above.
    mat = bpy.data.materials.new(f"label_mat_{text}")
    mat.diffuse_color = (0.09, 0.13, 0.17, 1)
    data.materials.append(mat)


def render_roster():
    # Avatars are already in the scene at their export positions.
    scene = bpy.context.scene
    scene.render.engine = "BLENDER_WORKBENCH"
    scene.display.shading.light = "STUDIO"
    scene.display.shading.color_type = "MATERIAL"
    scene.display.shading.show_shadows = True
    scene.display.shading.show_cavity = True
    scene.display.shading.cavity_type = "WORLD"
    scene.display.shading.background_type = "WORLD"
    scene.world.color = (0.82, 0.86, 0.89)

    bpy.ops.mesh.primitive_plane_add(size=40000, location=(0, 0, -5))
    floor = bpy.context.object
    floor.name = "roster_preview_ground_only"
    ground = bpy.data.materials.new("roster_preview_ground_material")
    ground.diffuse_color = (0.65, 0.72, 0.73, 1)
    floor.data.materials.append(ground)

    camera_data = bpy.data.cameras.new("roster_preview_camera")
    camera = bpy.data.objects.new("roster_preview_camera", camera_data)
    scene.collection.objects.link(camera)
    camera.location = (0, -12000, 12000)
    target = Vector((0, 2300, 560))
    camera.rotation_euler = (target - camera.location).to_track_quat("-Z", "Y").to_euler()
    camera_data.type = "ORTHO"
    camera_data.ortho_scale = 10000
    camera_data.clip_end = 30000
    scene.camera = camera
    scene.render.resolution_x = 1800
    scene.render.resolution_y = 1250
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.filepath = str((HERE / "roster_preview.png").resolve())
    bpy.ops.render.render(write_still=True)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    inventory = []
    x_positions = (-3750, -1250, 1250, 3750)
    # Higher Y appears higher in the camera view.
    y_positions = (4600, 2300, 0)

    for index, cfg in enumerate(CAST):
        root = build_avatar(cfg)
        output = OUT / f"{cfg['id']}.glb"
        s3d.export(root, output)
        inventory.append({
            "sequence": index + 2,
            "id": cfg["id"], "name": cfg["name"], "role": cfg["role"],
            "asset": f"roster/{output.name}", "format": "glb",
        })
        row, col = divmod(index, 4)
        root.location = (x_positions[col], y_positions[row], 0)
        add_label(cfg["name"], x_positions[col], y_positions[row] - 260)

    # Preserve the first character in the same small, browsable inventory.
    inventory.insert(0, {
        "sequence": 1,
        "id": "milo_rookie", "name": "Milo the Rookie Builder",
        "role": "first friend and starter builder", "asset": "milo_rookie.glb", "format": "glb",
    })
    (HERE / "roster.json").write_text(json.dumps(inventory, indent=2) + "\n", encoding="utf-8")
    render_roster()
    print(f"Built {len(CAST)} new characters; roster has {len(inventory)} total.")


if __name__ == "__main__":
    main()

