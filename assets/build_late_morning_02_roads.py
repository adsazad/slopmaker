"""Build roadside dressing for the Episode 2 driving shots."""
from pathlib import Path
import json

import sand3d as s3d

from build_interiors import Model

OUT = Path(__file__).with_name("late_morning_02")
INK, STEEL, PAPER = "#30393B", "#A2A8A7", "#DAD2BB"


def wheels(m, positions, side, diameter, depth):
    for y in positions:
        for sign in (-1, 1):
            m.add(s3d.cylinder("Tire", diameter, depth), (side * sign, y, diameter / 2),
                  "#292E2F", "rubber", (0, sign * 90, 0))
            m.add(s3d.cylinder("Hub", diameter * .50, 25),
                  ((side + depth - 2) * sign, y, diameter / 2), STEEL, "brushed_steel",
                  (0, sign * 90, 0))


def sedan(name, color):
    m = Model(name)
    wheels(m, (-1390, 1350), 683, 672, 185)
    m.box("Low body", (1680, 4280, 462), (0, 0, 441), color, "painted_metal")
    m.box("Window band", (1490, 2290, 432), (0, 164, 894), "#405459", "plastic")
    m.box("Roof", (1495, 1870, 76), (0, 210, 1314), color, "painted_metal")
    for x in (-748, 748):
        for y in (-886, 586):
            m.box("Window pillar", (67, 96, 413), (x, y, 905), color, "painted_metal")
        m.box("Headlight", (349, 40, 138), (x * .78, -2155, 661), "#D6C89D", "plastic")
        m.box("Tail light", (258, 42, 125), (x * .84, 2151, 627), "#9B3F3E", "plastic")
    m.box("Grille", (624, 43, 156), (0, -2151, 631), INK, "plastic")
    return m


def props():
    yield sedan("abandoned_tan_sedan", "#A28364")
    yield sedan("abandoned_olive_wagon", "#69745C")
    m = Model("parked_delivery_van")
    wheels(m, (-1450, 1660), 774, 728, 190)
    m.box("Van floor", (1750, 4780, 565), (0, 0, 443), "#B9B7A3", "painted_metal")
    m.box("Cargo shell", (1780, 2790, 1490), (0, 665, 908), "#D0C9B2", "painted_metal")
    m.box("Cab windows", (1550, 1140, 486), (0, -1240, 1062), "#5C747B", "plastic")
    m.box("Cab roof", (1700, 1264, 135), (0, -1190, 1545), "#D0C9B2", "painted_metal")
    for x in (-725, 725):
        m.box("Headlamp", (270, 48, 142), (x, -2409, 735), "#DDCCA4", "plastic")
        m.box("Rear door", (753, 61, 1320), (x * .53, 2070, 947), "#C4BCA4", "painted_metal")
    yield m
    m = Model("unhitched_utility_trailer")
    wheels(m, (190,), 741, 588, 159)
    m.box("Trailer floor", (1500, 2670, 105), (0, 0, 432), "#88765D")
    for x in (-722, 722):
        m.box("Cargo rail", (65, 2670, 326), (x, 0, 529), "#656D63", "painted_metal")
    for y in (-1300, 1300):
        m.box("End panel", (1450, 69, 311), (0, y, 529), "#656D63", "painted_metal")
    m.box("Towing tongue", (153, 1180, 132), (0, -1641, 443), STEEL, "brushed_steel")
    m.box("Dropped jack", (62, 64, 437), (66, -1865, 0), STEEL, "brushed_steel")
    yield m
    m = Model("weathered_road_barrier")
    m.box("Barrier foot", (341, 2200, 145), (0, 0, 0), "#9B978A", "concrete")
    m.box("Barrier body", (205, 2170, 611), (0, 0, 144), "#AFAB9D", "concrete")
    for y in (-703, 0, 703):
        m.box("Reflector", (11, 152, 69), (107, y, 572), "#D19C4D", "plastic")
    yield m
    m = Model("roadwork_drum")
    m.round("Weighted base", 518, 81, (0, 0, 0), INK, "rubber")
    m.round("Orange barrel", 419, 762, (0, 0, 68), "#AE6843", "plastic", 312)
    for z, d in [(267, 395), (557, 357)]:
        m.round("Reflector band", d, 118, (0, 0, z), "#E5DBC0", "plastic", d-15)
    yield m
    m = Model("rural_mailbox_pair")
    for x, color in [(-170, "#56645E"), (170, "#857768")]:
        m.box("Post", (93, 98, 1080), (x, 0, 0), "#79614D")
        m.box("Mailbox", (273, 479, 253), (x, -18, 1080), color, "painted_metal")
        m.box("Front door", (250, 21, 221), (x, -263, 1097), color, "painted_metal")
        m.box("Mail flag", (24, 142, 43), (x + 146, -48, 1258), "#A95043", "painted_metal")
    yield m
    m = Model("roadside_split_rail_fence")
    for y in (-2500, 0, 2500):
        m.box("Cedar post", (178, 173, 1230), (0, y, 0), "#78614D")
    for z in (383, 802):
        m.box("Long fence rail", (103, 5230, 151), (0, 0, z), "#9A805E")
    yield m
    m = Model("scattered_roadside_grass")
    for i, (x, y) in enumerate([(-520, -258), (-271, 101), (78, 367), (299, -171), (615, 145)]):
        for j in (-1, 0, 1):
            m.box("Dry grass blade", (42, 18, 205 + i * 21), (x + 40*j, y, 0),
                  ("#A49263", "#84905A", "#B29A68")[j+1], "leaf", (j * 10, j * 21, i * 24))
    yield m
    m = Model("loose_newspaper")
    m.box("Folded newspaper", (311, 225, 15), (0, 0, 0), PAPER, "plastic")
    for y in (-68, -42, -17, 8, 34, 61):
        m.box("Print", (191, 2, 2), (-20, y, 15), "#797563", "plastic")
    m.box("Front fold", (49, 225, 14), (146, 0, 9), "#BAB39B", "plastic", (0, 22, 0))
    yield m
    m = Model("loose_leaf")
    leaf = s3d.poly([(-60, 0), (-28, -45), (28, -41), (74, 4), (24, 45), (-34, 33)])
    m.add(s3d.extrude("Dry leaf", leaf, 4), (0, 0, 0), "#A87944", "leaf")
    m.box("Stem", (45, 4, 4), (-68, 0, 1), "#64503B", "pine")
    yield m
    m = Model("roadside_lookout_bird")
    m.box("Body", (130, 255, 112), (0, 0, 0), "#3F4543", "plastic")
    m.box("Head", (90, 110, 91), (0, -110, 65), INK, "plastic")
    m.box("Beak", (44, 78, 37), (0, -178, 88), "#8F7653", "plastic")
    for side in (-1, 1):
        m.box("Wing", (325, 139, 34), (side * 193, 2, 55), "#484F4C", "plastic", (0, side*9, 0))
    yield m


def main():
    category = OUT / "roadside"
    category.mkdir(parents=True, exist_ok=True)
    manifest_path = OUT / "inventory.json"
    inventory = [entry for entry in json.loads(manifest_path.read_text(encoding="utf-8"))
                 if entry["category"] != "roadside"]
    s3d.empty_scene()
    for prop in props():
        path = category / (prop.name + ".glb")
        s3d.export(s3d.assembly(prop.name, *prop.parts), path)
        inventory.append({"name": prop.name, "category": "roadside", "asset": path.relative_to(OUT).as_posix(),
                          "generator": "Sand3D"})
    manifest_path.write_text(json.dumps(inventory, indent=2) + "\n", encoding="utf-8")
    print(f"{len(inventory)} models in the Episode 2 kit")


if __name__ == "__main__":
    main()
