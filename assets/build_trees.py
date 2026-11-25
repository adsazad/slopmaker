"""Build four stylized tree models in Sand3D. Dimensions are in millimetres."""
import json
import argparse
from math import cos, radians, sin, tau
from pathlib import Path
from random import Random

import sand3d as s3d

OUT = Path(__file__).with_name("trees")


def finish(obj, preset, color):
    s3d.material(obj, preset, color=color, roughness=.84 if preset == "leaf" else .94)
    return obj


def ring(radius, outline, aspect=1):
    return s3d.poly([
        (radius * v * cos(tau * i / len(outline)),
         radius * v * sin(tau * i / len(outline)) * aspect)
        for i, v in enumerate(outline)
    ])


def limb(name, stations, color, follow=True):
    """A continuous taper through (x, y, z, radius) stations."""
    outline = (1, .86, 1.04, .92, 1, .88, 1.07, .95, 1.04)
    sections = [s3d.at(ring(r, outline), x, y, z) for x, y, z, r in stations]
    return finish(s3d.loft(name, *sections, follow=follow), "bark", color)


def foliage(name, center, size, color, rng):
    """Build an uneven crown lobe with broad facets and a flattened underside."""
    x, y, z = center
    width, depth, height = size
    outline = [rng.uniform(.84, 1.13) for _ in range(9)]
    sections = []
    for level, radius in [(-.49, .20), (-.36, .73), (-.05, 1), (.26, .81), (.49, .18)]:
        profile = ring(width * radius / 2, outline, depth / width)
        sections.append(s3d.at(profile, x + level * width * .19, y, z + level * height))
    return finish(s3d.loft(name, *sections), "leaf", color)


def oak():
    rng = Random(47)
    bark = "#624333"
    parts = [limb("Flared trunk", [
        (0, 0, 0, 480), (20, 20, 500, 315), (95, 30, 1960, 235),
        (-20, 80, 3240, 166), (-480, 350, 5140, 46),
    ], bark, follow=False)]
    palette = ("#456333", "#58783A", "#668944", "#79974A")
    for i in range(7):
        a = tau * i / 7 + rng.uniform(-.18, .18)
        dx, dy = cos(a), sin(a)
        spread = rng.randint(1500, 2350)
        z = rng.randint(3600, 4750)
        parts.append(limb(f"Scaffold branch {i+1}", [
            (45, 35, 1740 + i * 185, 148),
            (dx * 820, dy * 820, z - 1100, 98),
            (dx * spread, dy * spread, z, 25),
        ], bark))
        for j in range(2):
            reach = spread * (1 - j * .36)
            parts.append(foliage(
                f"Oak crown {i+1}.{j+1}", (dx * reach, dy * reach, z + 300 + j * 1150),
                (rng.randint(1900, 2550), rng.randint(1800, 2400), rng.randint(1440, 2000)),
                palette[(i + j) % 4], rng,
            ))
    parts.append(foliage("Oak crown top", (-280, 235, 5770), (2900, 2650, 1660), palette[2], rng))
    return s3d.assembly("round_oak", *parts)


def pine():
    rng = Random(21)
    parts = [limb("Pine trunk", [(0, 0, 0, 295), (10, 10, 940, 205),
                                (100, 40, 3670, 129), (-75, 50, 7760, 28)],
                  "#654638", follow=False)]
    colors = ("#244C3A", "#345F43", "#3D6B4B", "#2C583F")
    tiers = [(1520, 1810), (2300, 1740), (3140, 1540), (4000, 1300),
             (4790, 1080), (5540, 860), (6220, 660), (6820, 470)]
    for i, (z, radius) in enumerate(tiers):
        outline = [rng.uniform(.83, 1.1) if k % 2 == 0 else rng.uniform(.58, .73) for k in range(16)]
        yaw = i * 31
        sections = [s3d.at(ring(radius * factor, outline), x, 40, z + height, rz=yaw)
                    for factor, x, height in [(.63, 25, 0), (1, 20, 195),
                                               (.67, 50, 540), (.32, 20, 915), (.04, -100, 1390)]]
        parts.append(finish(s3d.loft(f"Needle whorl {i+1}", *sections), "leaf", colors[i % 4]))
    return s3d.assembly("layered_pine", *parts)


def palm():
    parts = [limb("Swept palm trunk", [
        (0, 0, 0, 390), (100, -50, 550, 260), (510, -40, 1900, 217),
        (890, 90, 3720, 184), (1170, 260, 5550, 218), (1200, 280, 5750, 295),
    ], "#9C7351", follow=False)]
    for i, (x, y, z, r) in enumerate([
        (160, -54, 780, 249), (266, -57, 1110, 238), (370, -52, 1450, 230),
        (470, -44, 1770, 224), (553, -25, 2090, 218), (628, -10, 2420, 208),
        (696, 12, 2730, 203), (770, 38, 3090, 196), (830, 67, 3420, 194),
        (897, 91, 3750, 190), (964, 124, 4100, 193), (1031, 160, 4460, 195),
        (1091, 198, 4810, 200), (1143, 233, 5150, 206),
    ]):
        parts.append(limb(f"Leaf scar {i+1}", [(x, y, z, r), (x + 7, y, z + 34, r - 2)],
                          "#795239", follow=False))
    for i in range(11):
        yaw = i * 137.5
        angle = radians(yaw)
        extent = (2860, 3370, 3070)[i % 3]
        lift = (720, 460, 1060)[i % 3]
        drop = (730, 1110, 210)[i % 3]
        sections = []
        for t, dz, width in [(0, 0, 115), (.18, lift * .71, 540),
                             (.39, lift, 780), (.57, lift * .80, 720),
                             (.76, lift * .26 - drop * .34, 570), (1, -drop, 14)]:
            # A V-shaped cross section gives each blade a raised central rib.
            profile = s3d.poly([(-49, 0), (22, width / 2), (39, width / 2),
                                (-24, 0), (39, -width / 2), (22, -width / 2)])
            sections.append(s3d.at(profile, 1200 + cos(angle) * t * extent,
                                    280 + sin(angle) * t * extent, 5700 + dz, ry=90, rz=yaw))
        color = ("#4E7937", "#638D40", "#769F47")[i % 3]
        parts.append(finish(s3d.loft(f"Arched palm frond {i+1}", *sections), "leaf", color))
    return s3d.assembly("tropical_palm", *parts)


def birch():
    rng = Random(72)
    pale = "#E5DAC0"
    parts = [limb("Birch leader", [(0, 0, 0, 219), (60, -40, 950, 173),
                                  (-120, -20, 3050, 130), (-340, 50, 5490, 78),
                                  (-500, 85, 7510, 16)], pale, follow=False)]
    for i, (x, y, z) in enumerate([(1010, 140, 5230), (-950, -390, 5670),
                                    (460, -900, 6120), (800, 680, 6460),
                                    (-730, 470, 6970), (-530, -140, 7740)]):
        base_z = 1790 + i * 585
        parts.append(limb(f"Ascending birch branch {i+1}", [
            (-75 - i * 55, 0, base_z, 101 - i * 9),
            (x * .64, y * .65, z - 1250, 58 - i * 5),
            (x, y, z, 12),
        ], pale))
        for j in range(3):
            parts.append(foliage(f"Birch leaves {i+1}.{j+1}",
                                 (x + rng.randint(-445, 445), y + rng.randint(-370, 370), z + (j-1)*435),
                                 (rng.randint(870, 1350), rng.randint(850, 1200), rng.randint(790, 1280)),
                                 ("#8BA851", "#74974B", "#A1B763")[(i+j) % 3], rng))
    # Painted bark dashes wrap around the irregular trunk at several heights.
    for i in range(25):
        z = 270 + i * 170
        x = 0 if z < 950 else 60 - .086 * (z - 950)
        r = 195 - z * .024
        a = i * 2.39996
        dash = s3d.box(f"Bark dash {i+1}", rng.randint(66, 136), 24, rng.randint(19, 56))
        s3d.transform(dash, x + cos(a) * r, -25 + sin(a) * r, z, rz=i * 137.5 + 90)
        parts.append(finish(dash, "bark", "#4D443A"))
    return s3d.assembly("silver_birch", *parts)


def autumn_maple():
    rng = Random(62)
    bark = "#6D5043"
    parts = [limb("Maple trunk", [(0, 0, 0, 405), (-150, 20, 950, 290),
                                 (-290, -50, 2680, 213), (-500, 80, 5050, 47)],
                  bark, follow=False)]
    colors = ("#A63B2B", "#C45231", "#D76A32", "#DE8B39", "#BD5035")
    for i in range(8):
        a = i * tau / 8
        dx, dy = cos(a), sin(a)
        reach = rng.randint(1250, 2250)
        height = rng.randint(4050, 4950)
        parts.append(limb(f"Maple branch {i + 1}", [
            (-240, 0, 2070 + i * 150, 128),
            (dx * 850 - 170, dy * 850, height - 940, 82),
            (dx * reach - 170, dy * reach, height, 18),
        ], bark))
        for j in range(2):
            radius = reach * (1 - .37 * j)
            center = (dx * radius - 170, dy * radius, height + 220 + j * 1110)
            size = (rng.randint(1600, 2100), rng.randint(1580, 1940), rng.randint(1250, 1550))
            parts.append(foliage(f"Maple leaves {i + 1}.{j + 1}", center, size,
                                 colors[(i + j) % len(colors)], rng))
    return s3d.assembly("autumn_maple", *parts)


def weeping_willow():
    rng = Random(93)
    bark = "#6D5540"
    colors = ("#637744", "#7B8C4C", "#8F9D55", "#526C40")
    parts = [limb("Willow trunk", [(0, 0, 0, 520), (70, 25, 800, 342),
                                  (290, 60, 2550, 220), (150, 110, 4530, 85)],
                  bark, follow=False)]
    outline = (1, .82, 1.07, .86, 1.03, .91, 1.06)
    for i in range(8):
        a = i * tau / 8
        dx, dy = cos(a), sin(a)
        reach = rng.randint(1990, 2510)
        top = rng.randint(4550, 5280)
        parts.append(limb(f"Arching branch {i + 1}", [
            (220, 60, 2050 + 130 * i, 155),
            (dx * 1090, dy * 1090, top - 390, 103),
            (dx * reach, dy * reach, top, 49),
            (dx * (reach + 480), dy * (reach + 480), top - 450, 15),
        ], bark))
        parts.append(foliage(f"Willow crown {i + 1}", (dx * 1410, dy * 1410, top),
                             (2050, 1880, 1200), colors[i % 4], rng))
        for j in range(3):
            angle = a + (j - 1) * .21
            end = rng.randint(1260, 2550)
            sections = []
            for dist, z, radius in [(reach + 440, end, 22), (reach + 560, end + 460, 235),
                                    (reach + 510, top - 1150, 345), (reach + 240, top - 400, 395),
                                    (reach - 240, top + 140, 210)]:
                sections.append(s3d.at(ring(radius, outline, .82), cos(angle) * dist,
                                        sin(angle) * dist, z, rz=angle * 180 / 3.14159))
            frond = s3d.loft(f"Drooping foliage {i + 1}.{j + 1}", *sections)
            parts.append(finish(frond, "leaf", colors[(i + j) % 4]))
    parts.append(foliage("Willow crown center", (120, 30, 5150), (2900, 2800, 1120), colors[1], rng))
    return s3d.assembly("weeping_willow", *parts)


def italian_cypress():
    rng = Random(31)
    parts = [limb("Cypress trunk", [(0, 0, 0, 220), (10, 15, 830, 155),
                                   (-40, 0, 4750, 83), (70, 35, 7630, 17)],
                  "#674D3D", follow=False)]
    outline = (1, .82, 1.05, .88, 1, .86, 1.06, .89, 1)
    core = [(0, 1080, 470), (-100, 2200, 874), (-50, 4480, 720),
            (100, 6300, 430), (130, 7920, 105), (175, 8380, 12)]
    parts.append(finish(s3d.loft("Columnar crown", *[
        s3d.at(ring(radius, outline), x, 0, z) for x, z, radius in core
    ]), "leaf", "#345B40"))
    for i in range(15):
        a = i * radians(137.5)
        z = 1960 + i * 359
        offset = 730 - i * 35
        height = rng.randint(1600, 2250)
        width = 850 - i * 35
        parts.append(foliage(f"Ascending foliage {i + 1}",
                             (cos(a) * offset, sin(a) * offset, z),
                             (width, width * .89, height),
                             ("#355E40", "#436B48", "#385E44")[i % 3], rng))
    return s3d.assembly("italian_cypress", *parts)


ORIGINAL_TREES = {"round_oak": oak, "layered_pine": pine, "tropical_palm": palm, "silver_birch": birch}
NEW_TREES = {"autumn_maple": autumn_maple, "weeping_willow": weeping_willow, "italian_cypress": italian_cypress}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--new", action="store_true", help="Export only the three newer models.")
    args = parser.parse_args()
    OUT.mkdir(exist_ok=True)
    builders = ORIGINAL_TREES | NEW_TREES
    for name, builder in (NEW_TREES if args.new else builders).items():
        s3d.empty_scene()
        s3d.export(builder(), OUT / f"{name}.glb")
    inventory = [{"name": name.replace("_", " ").title(), "asset": f"{name}.glb",
                  "format": "glb", "generator": "Sand3D"}
                 for name in builders if (OUT / f"{name}.glb").exists()]
    (OUT / "inventory.json").write_text(json.dumps(inventory, indent=2) + "\n", encoding="utf-8")
