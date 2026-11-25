"""Build Daniel Ward's left and right worn leather work boots with Sand3D."""
import json
from math import degrees
from pathlib import Path

import sand3d as s3d
from mathutils import Vector

from build_interiors import Model

KIT = Path(__file__).with_name("late_morning_02")
BROWN = "#6F4C36"
TOE = "#76523B"
HEEL = "#563E31"
DARK = "#302722"
RUBBER = "#2D2B29"
EDGE = "#514037"
THREAD = "#BD976F"
LACE = "#D0B798"

SOLE = [(-24, -155), (22, -155), (43, -146), (53, -124), (55, -89),
        (51, -47), (45, -6), (42, 34), (44, 85), (37, 112), (20, 125),
        (-22, 125), (-39, 116), (-46, 94), (-45, 53), (-43, 10),
        (-47, -39), (-56, -83), (-55, -118), (-47, -142)]


def offset(side, y):
    return side * max(0.0, (-y - 35) * .043)


def sole_sheet(boot, name, side, scale, z, depth, tint, finish):
    outline = [(x * scale + offset(side, y), y * scale) for x, y in SOLE]
    boot.add(s3d.extrude(name, s3d.poly(outline), depth), (0, 0, z), tint, finish)


def section(side, y, half_width, height, base=19):
    # The last two rings taper to the rounded heel and toe caps.
    template = [(-.83, 0), (.83, 0), (1, .21), (.96, .48), (.70, .80),
                (.34, .97), (0, 1), (-.46, .94), (-.76, .77),
                (-.96, .47), (-1, .21)]
    profile = s3d.poly([(half_width * x, height * h) for x, h in template])
    return s3d.at(profile, offset(side, y), y, base, rx=90)


def cord(boot, name, start, finish, thickness, tone, texture="fabric"):
    start = Vector(start)
    delta = Vector(finish) - start
    angles = tuple(degrees(r) for r in delta.to_track_quat("Z", "Y").to_euler())
    boot.add(s3d.cylinder(name, thickness, delta.length), tuple(start), tone, texture, angles)


def ankle(boot):
    # The top is capped with a dark lining insert. A trouser cuff can overlap it.
    outline = [(-.88, -.50), (-.58, -.85), (0, -.96), (.59, -.81),
               (.88, -.51), (.96, .20), (.69, .69), (.34, .87),
               (-.28, .90), (-.71, .65), (-.96, .23)]
    stations = []
    for y, z, width, length in [(54, 47, 45, 59), (67, 99, 41, 53),
                                (68, 141, 42, 54), (68, 163, 43, 54)]:
        profile = s3d.poly([(x * width, dy * length) for x, dy in outline])
        stations.append(s3d.at(profile, 0, y, z))
    boot.add(s3d.loft("Shaped leather ankle", *stations), (0, 0, 0), BROWN, "leather")
    collar = s3d.poly([(x * 43.7, y * 54.8) for x, y in outline])
    boot.add(s3d.extrude("Padded collar edge", collar, 8), (0, 68, 158), HEEL, "leather")
    lining = s3d.poly([(x * 34.3, y * 44.4) for x, y in outline])
    boot.add(s3d.extrude("Dark collar lining", lining, 2), (0, 68, 166), DARK, "fabric")
    boot.box("Heel pull tab", (18, 9, 32), (0, 111, 145), HEEL, "leather")


def upper(name, side):
    boot = Model(name)
    sole_sheet(boot, "Continuous rubber outsole", side, 1, 4, 14, RUBBER, "rubber")
    sole_sheet(boot, "Leather welt", side, .994, 17, 5, EDGE, "leather")
    sole_sheet(boot, "Ochre welt seam", side, .982, 21, 2, THREAD, "fabric")
    for y in (-121, -95, -69, -43, -17, 10, 37, 63, 91, 108):
        for x in (-29, 29):
            boot.box("Outsole tread lug", (27, 18, 6), (x + offset(side, y), y, 0),
                     RUBBER, "rubber", (0, 0, -14 if x < 0 else 14))
    shapes = [(-151, 24, 16), (-144, 39, 34), (-126, 48, 44),
              (-95, 50, 50), (-60, 48, 59), (-34, 45, 77), (3, 44, 100),
              (45, 43, 94), (82, 43, 80), (112, 37, 60), (123, 21, 33)]
    boot.add(s3d.loft("Leather toe and vamp", *(section(side, *shape) for shape in shapes)),
             (0, 0, 0), BROWN, "leather")
    cap = [(-152, 23, 15), (-144, 39, 34), (-126, 49, 45), (-107, 51, 50), (-90, 51, 52)]
    boot.add(s3d.loft("Burnished toe cap", *(section(side, *shape, base=20) for shape in cap)),
             (0, 0, 0), TOE, "leather")
    ankle(boot)

    # Each lace lies across the rising tongue, with distinct metal eyelets.
    lace_rows = [(-59, 77, 21), (-42, 86, 22), (-23, 100, 23),
                 (-4, 114, 24), (15, 130, 24), (32, 142, 25)]
    tongue_stations = [
        section(side, y, width + 7, top - base, base=base)
        for (y, top, width), base in zip(lace_rows, (65, 69, 79, 92, 107, 116))
    ]
    boot.add(s3d.loft("Rising leather tongue", *tongue_stations), (0, 0, 0), HEEL, "leather")
    for y, z, x in lace_rows:
        for sign in (-1, 1):
            boot.round("Patinated lace eyelet", 9.2, 3, (sign * x, y, z - 2), "#A38561", "brass")
            boot.round("Eyelet opening", 3.8, 1.5, (sign * x, y, z + 1), DARK, "plastic")
    for (y0, z0, x0), (y1, z1, x1) in zip(lace_rows, lace_rows[1:]):
        for sign in (-1, 1):
            middle = (0, (y0 + y1) / 2, (z0 + z1) / 2 + 1.8 + sign)
            cord(boot, "Crossed cotton lace", (sign*x0,y0,z0 + 3), middle, 3.2, LACE)
            cord(boot, "Crossed cotton lace", middle, (-sign*x1,y1,z1 + 3), 3.2, LACE)
    cord(boot, "Knot", (-9,35,147), (9,39,151), 5, LACE)
    for sign in (-1, 1):
        x = sign * 5
        loop = [(x,37,149),(sign * 17,47,153),(sign * 25,39,151),
                (sign * 21,29,146),(x,37,149)]
        for a,b in zip(loop, loop[1:]):
            cord(boot, "Tied lace loop", a,b,2.8,LACE)
        cord(boot, "Short lace end", (x,37,150), (sign * 28,19,137), 2.5, LACE)
        for y in (-77, -64, -51, -38):
            x = sign * (39 - (y+77)*.06)
            cord(boot, "Quarter seam stitch", (x,y,49), (x-sign*2,y+5,51),
                 1.4, THREAD)
    return boot


def main():
    out = KIT / "wardrobe"
    out.mkdir(parents=True, exist_ok=True)
    path = KIT / "inventory.json"
    inventory = [entry for entry in json.loads(path.read_text(encoding="utf-8"))
                 if entry["category"] != "wardrobe"]
    s3d.empty_scene()
    for name, side in [("daniel_work_boot_left", -1), ("daniel_work_boot_right", 1)]:
        boot = upper(name, side)
        file = out / f"{name}.glb"
        s3d.export(s3d.assembly(name, *boot.parts), file)
        inventory.append({"name": name, "category": "wardrobe",
                          "asset": file.relative_to(KIT).as_posix(), "generator": "Sand3D"})
    path.write_text(json.dumps(inventory, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
