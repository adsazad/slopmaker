"""Build Eli Mercer, the night-grid technician, with Sand3D."""

from pathlib import Path

import sand3d as s3d


OUT = Path(__file__).with_name("eli_mercer.glb")
P = {
    "skin": "#C58B65", "hair": "#332A2B", "beard": "#493539",
    "jacket": "#233447", "vest": "#EF9C35", "reflective": "#E8E6C9",
    "pants": "#263346", "boots": "#463A33", "rubber": "#27272B",
    "helmet": "#F4C744", "helmet_shadow": "#D59427", "radio": "#35424A",
    "screen": "#7DE3D4", "eyes": "#24252A", "metal": "#B9C6C9",
}


def box(name, size, at, color, kind="plastic"):
    ob = s3d.box(name, *size)
    s3d.transform(ob, *at)
    s3d.material(ob, kind, color=color)
    return ob


def sphere(name, diameter, at, color, kind="plastic"):
    ob = s3d.sphere(name, diameter)
    s3d.transform(ob, at[0], at[1], at[2] - diameter / 2)
    s3d.material(ob, kind, color=color)
    return ob


def cylinder(name, diameter, height, at, color, kind="plastic"):
    ob = s3d.cylinder(name, diameter, height)
    s3d.transform(ob, *at)
    s3d.material(ob, kind, color=color)
    return ob


def build():
    p = []

    for side, x in (("left", -68), ("right", 68)):
        p.append(box(f"eli_{side}_boot_sole", (118, 190, 25), (x, -10, 0), P["rubber"], "rubber"))
        p.append(box(f"eli_{side}_boot", (112, 182, 85), (x, -9, 23), P["boots"], "leather"))
        p.append(box(f"eli_{side}_trouser", (112, 142, 296), (x, 0, 106), P["pants"], "fabric"))

    p.append(box("eli_waist", (258, 152, 132), (0, 0, 378), P["pants"], "fabric"))
    p.append(box("eli_tool_belt", (274, 164, 34), (0, -2, 429), P["boots"], "leather"))
    p.append(box("eli_buckle", (48, 16, 35), (0, -91, 428), P["metal"], "steel"))
    p.append(box("eli_left_tool_pouch", (72, 82, 94), (-154, -56, 414), P["jacket"], "leather"))
    p.append(box("eli_right_tool_pouch", (82, 82, 112), (152, -54, 405), P["jacket"], "leather"))
    p.append(box("eli_tool_handle", (22, 22, 114), (152, -58, 496), P["metal"], "steel"))

    p.append(box("eli_jacket_torso", (312, 164, 344), (0, 0, 516), P["jacket"], "fabric"))
    p.append(box("eli_hi_vis_front", (222, 18, 234), (0, -91, 565), P["vest"], "fabric"))
    p.append(box("eli_reflective_front_top", (230, 20, 20), (0, -103, 735), P["reflective"], "plastic"))
    p.append(box("eli_reflective_front_bottom", (230, 20, 20), (0, -103, 586), P["reflective"], "plastic"))
    p.append(box("eli_vest_zipper", (12, 14, 203), (0, -105, 580), P["metal"], "steel"))

    for side, sign in (("left", -1), ("right", 1)):
        x = sign * 205
        p.append(box(f"eli_{side}_upper_arm", (106, 142, 178), (x, 0, 653), P["jacket"], "fabric"))
        p.append(box(f"eli_{side}_arm_band", (110, 150, 22), (x, -3, 704), P["reflective"], "plastic"))
        p.append(box(f"eli_{side}_forearm", (100, 132, 166), (x, -2, 487), P["jacket"], "fabric"))
        p.append(box(f"eli_{side}_cuff", (108, 140, 34), (x, -2, 453), P["reflective"], "plastic"))
        p.append(box(f"eli_{side}_glove", (88, 108, 92), (x, -4, 361), P["boots"], "leather"))

    p.append(box("eli_neck", (77, 92, 58), (0, -1, 850), P["skin"]))
    p.append(box("eli_head", (236, 214, 236), (0, 0, 900), P["skin"]))
    p.append(box("eli_hair", (225, 205, 55), (0, 0, 1102), P["hair"], "fabric"))
    p.append(box("eli_beard", (154, 18, 46), (0, -110, 914), P["beard"], "fabric"))
    for side, x in (("left", -48), ("right", 48)):
        p.append(sphere(f"eli_{side}_eye", 18, (x, -111, 1034), P["eyes"]))
    p.append(box("eli_mouth", (28, 10, 6), (0, -112, 977), P["beard"]))

    p.append(box("eli_helmet_brim", (304, 270, 30), (0, -8, 1112), P["helmet_shadow"]))
    crown = s3d.cone("eli_helmet_crown", 220, 118, d2=158)
    s3d.transform(crown, 0, 0, 1138)
    s3d.material(crown, "plastic", color=P["helmet"])
    p.append(crown)
    p.append(box("eli_headlamp_mount", (78, 24, 42), (0, -123, 1177), P["metal"], "steel"))
    p.append(sphere("eli_headlamp", 34, (0, -141, 1199), "#FFF0B0", "light"))

    # Radio, antenna, and two square chest pockets make his job readable in a close-up.
    p.append(box("eli_left_chest_pocket", (70, 14, 66), (-88, -101, 702), P["jacket"], "fabric"))
    p.append(box("eli_right_chest_pocket", (70, 14, 66), (88, -101, 702), P["jacket"], "fabric"))
    p.append(box("eli_radio", (62, 38, 92), (-114, -108, 753), P["radio"]))
    p.append(box("eli_radio_screen", (36, 8, 28), (-114, -131, 785), P["screen"], "light"))
    p.append(cylinder("eli_radio_antenna", 10, 55, (-130, -108, 845), P["metal"], "steel"))
    p.append(sphere("eli_radio_button", 13, (-114, -132, 740), P["vest"]))

    return s3d.assembly("eli_mercer_night_technician", *p)


if __name__ == "__main__":
    s3d.export(build(), OUT)
    print(f"Exported {OUT}")
