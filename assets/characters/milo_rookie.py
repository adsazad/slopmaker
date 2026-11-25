"""Build Milo, a blocky starter adventurer, as a Sand3D GLB asset.

Run from the repository root with:
    .venv/Scripts/python.exe assets/characters/milo_rookie.py

Dimensions are in millimetres. The character faces -Y and stands on Z=0.
"""

from pathlib import Path

import sand3d as s3d


OUT = Path(__file__).with_name("milo_rookie.glb")

COLORS = {
    "skin": "#F2C78B",
    "jacket": "#158DA5",
    "jacket_light": "#46BED0",
    "pants": "#263958",
    "boots": "#342B32",
    "sole": "#E7B252",
    "helmet": "#F2B83F",
    "helmet_dark": "#D9852D",
    "scarf": "#E95B4C",
    "backpack": "#547C55",
    "backpack_light": "#78975E",
    "eyes": "#27252A",
    "mouth": "#7C3B35",
    "buckle": "#F4D26B",
}


def box(name, size, pos, finish="plastic", color=None):
    part = s3d.box(name, *size)
    s3d.transform(part, *pos)
    s3d.material(part, finish, color=color or COLORS[finish])
    return part


def sphere(name, diameter, pos, finish, color=None):
    part = s3d.sphere(name, diameter)
    # Sand3D spheres rest on Z=0, so position their centre at the requested point.
    s3d.transform(part, pos[0], pos[1], pos[2] - diameter / 2)
    s3d.material(part, finish, color=color or COLORS[finish])
    return part


def build():
    parts = []

    # Shoes, sturdy legs and a contrasting waist give the classic block silhouette.
    for side, x in (("left", -68), ("right", 68)):
        parts.append(box(f"{side}_boot_sole", (116, 190, 24), (x, -12, 0), "rubber", COLORS["sole"]))
        parts.append(box(f"{side}_boot", (112, 184, 82), (x, -10, 22), "leather", COLORS["boots"]))
        parts.append(box(f"{side}_trouser_leg", (112, 142, 300), (x, 0, 104), "fabric", COLORS["pants"]))
    parts.append(box("belted_waist", (258, 150, 136), (0, 0, 380), "fabric", COLORS["pants"]))
    parts.append(box("belt", (270, 162, 30), (0, -3, 432), "leather", COLORS["boots"]))
    parts.append(box("belt_buckle", (48, 14, 34), (0, -86, 430), "painted_metal", COLORS["buckle"]))

    # Backpack sits behind the shoulders; front straps and pockets stay separate parts.
    parts.append(box("backpack_body", (190, 105, 270), (0, 116, 570), "fabric", COLORS["backpack"]))
    parts.append(box("backpack_top_flap", (205, 116, 58), (0, 111, 824), "leather", COLORS["backpack_light"]))
    parts.append(box("backpack_bedroll", (206, 205, 52), (0, 175, 839), "fabric", COLORS["scarf"]))

    # Jacket and orange sleeves: distinct pieces keep the avatar easy to rig later.
    parts.append(box("jacket_torso", (310, 164, 342), (0, 0, 518), "plastic", COLORS["jacket"]))
    parts.append(box("jacket_front_placket", (24, 12, 306), (0, -89, 535), "plastic", COLORS["jacket_light"]))
    parts.append(box("left_chest_pocket", (74, 16, 70), (-88, -91, 690), "fabric", COLORS["jacket_light"]))
    parts.append(box("right_chest_pocket", (74, 16, 70), (88, -91, 690), "fabric", COLORS["jacket_light"]))
    for index, z in enumerate((704, 676, 648), start=1):
        parts.append(sphere(f"jacket_button_{index}", 10, (0, -100, z), "plastic", COLORS["buckle"]))

    for side, sign in (("left", -1), ("right", 1)):
        x = sign * 204
        parts.append(box(f"{side}_upper_sleeve", (104, 142, 180), (x, 0, 654), "fabric", COLORS["scarf"]))
        parts.append(box(f"{side}_forearm", (100, 132, 166), (x, -2, 488), "fabric", COLORS["jacket"]))
        parts.append(box(f"{side}_cuff", (108, 140, 34), (x, -2, 454), "fabric", COLORS["jacket_light"]))
        parts.append(box(f"{side}_hand", (86, 108, 95), (x, -3, 359), "plastic", COLORS["skin"]))

    # A small neck and scarf sit between the jacket and square head.
    parts.append(box("neck", (76, 92, 56), (0, -1, 852), "plastic", COLORS["skin"]))
    parts.append(box("scarf_collar", (204, 184, 64), (0, -12, 836), "fabric", COLORS["scarf"]))
    parts.append(box("scarf_tail", (65, 20, 164), (51, -106, 737), "fabric", COLORS["scarf"]))

    # Friendly square face, looking toward -Y.
    parts.append(box("head", (236, 214, 236), (0, 0, 900), "plastic", COLORS["skin"]))
    for side, x in (("left", -48), ("right", 48)):
        parts.append(sphere(f"{side}_eye", 18, (x, -111, 1034), "plastic", COLORS["eyes"]))
    parts.append(box("smile", (54, 10, 8), (0, -112, 979), "plastic", COLORS["mouth"]))
    for side, x in (("left", -132), ("right", 132)):
        parts.append(box(f"{side}_ear", (32, 68, 72), (x, 0, 978), "plastic", COLORS["skin"]))

    # A bright builder's helmet is an instantly readable silhouette detail.
    parts.append(box("helmet_brim", (300, 270, 30), (0, -8, 1114), "plastic", COLORS["helmet_dark"]))
    crown = s3d.cone("helmet_crown", 222, 120, d2=154)
    s3d.transform(crown, 0, 0, 1138)
    s3d.material(crown, "plastic", color=COLORS["helmet"])
    parts.append(crown)
    parts.append(box("helmet_front_badge", (74, 12, 42), (0, -119, 1160), "painted_metal", COLORS["buckle"]))

    return s3d.assembly("milo_rookie", *parts)


if __name__ == "__main__":
    OUT.parent.mkdir(parents=True, exist_ok=True)
    character = build()
    s3d.export(character, OUT)
    print(f"Exported {OUT}")
