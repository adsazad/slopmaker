"""Build the Sand3D location and prop kit for Late Morning Episode 2."""
from pathlib import Path
import json
from math import atan2, degrees, hypot

import sand3d as s3d

from build_houses import HouseParts
from build_interiors import Model, shelves

OUT = Path(__file__).with_name("late_morning_02")
WHITE, INK, STEEL = "#EBE1C9", "#30383B", "#8A9290"
OAK, RED, GREEN = "#A87C54", "#9C5544", "#45695E"
GLASS, PAVEMENT, ASPHALT = "#7D9AA4", "#AAA89B", "#53595B"
STRIPE = "#E2B85C"


def label(model, value, size, position, color=WHITE, rotation=(90, 0, 0)):
    outline = s3d.text(value, size)
    model.add(s3d.extrude(value, outline, 2), position, color, "plastic", rotation)


def member(model, name, a, b, thickness, color, finish="painted_metal"):
    """A bar with endpoints in the XY plane."""
    dx, dy = b[0] - a[0], b[1] - a[1]
    model.box(name, (hypot(dx, dy), thickness, thickness),
              ((a[0] + b[0]) / 2, (a[1] + b[1]) / 2, a[2]),
              color, finish, (0, 0, degrees(atan2(dy, dx))))


def borrow_house():
    h = HouseParts("borrowed_split_level", "#E4D8BB")
    h.box("Foundation", (9900, 7150, 500), (0, 0, 0), "#A99784", "concrete")
    h.box("Upper house", (9700, 6900, 3950), (0, 0, 500), "#A09C79")
    h.gable(4850, 6900, 4450, 2010, "#A09C79", "#515E5A")
    h.door(-2950, -3450, 500, 1070, "#705C48")
    h.stairs(-2950, -3570, 1760, 3, "#A99784")
    for x in (-900, 2520):
        h.window(x, -3450, 1730, 1700, 1250)
        h.box("Exterior shutters", (2110, 50, 1300), (x, -3470, 1710), "#7A8069")
    for z in range(580, 4450, 255):
        h.box("Siding line", (9700, 40, 25), (0, -3456, z), "#918D6C")
    h.window(0, -3450, 4690, 890, 760)
    h.box("Brick chimney", (745, 820, 2830), (2740, 1020, 3930), "#9C6C60", "concrete")
    return h.assemble()


def cedar_bungalow():
    h = HouseParts("cedar_roadside_bungalow", "#D7C4A2")
    h.box("Concrete skirt", (8290, 5770, 385), (0, 0, 0), "#A09A8A", "concrete")
    h.box("Cedar box", (8050, 5550, 2830), (0, 0, 380), "#80695B")
    h.gable(4025, 5550, 3210, 1660, "#80695B", "#454D4F")
    h.box("Porch deck", (5060, 1560, 385), (180, -3540, 0), OAK)
    h.box("Porch roof", (5610, 1880, 140), (180, -3550, 2690), "#434C4D", "painted_metal")
    for x in (-2190, 2580):
        h.box("Porch post", (163, 163, 2310), (x, -4120, 381), h.trim)
    h.door(350, -2775, 385, 1000, "#53706C")
    for x in (-2040, 2320):
        h.window(x, -2775, 986, 1290, 1070)
    h.stairs(350, -4310, 1860, 2, "#A39B8C")
    return h.assemble()


def pickup():
    m = Model("fathers_pickup")
    paint, cabin, bumper = "#697D83", "#455053", "#A0A29B"
    m.box("Chassis", (1530, 4690, 248), (0, 0, 310), INK, "painted_metal")
    m.box("Engine bay", (1850, 1730, 511), (0, -1660, 580), paint, "painted_metal")
    m.box("Hood", (1770, 1590, 105), (0, -1640, 1082), paint, "painted_metal")
    m.box("Cab floor", (1780, 1580, 150), (0, -30, 664), cabin, "painted_metal")
    m.box("Cab roof", (1715, 1530, 126), (0, -37, 1737), paint, "painted_metal")
    for side in (-1, 1):
        x = side * 852
        if side < 0:
            m.box("Driver door shell", (115, 1480, 483), (x, -41, 665), paint, "painted_metal")
            m.box("Driver door handle", (42, 138, 33), (side * 927, 366, 1083), bumper, "brushed_steel")
        for y in (-764, 691):
            m.box("Cab pillar", (112, 116, 659), (x, y, 1080), paint, "painted_metal")
        m.box("Mirror arm", (208, 48, 45), (side * 940, -632, 1315), INK, "painted_metal")
        m.box("Mirror body", (96, 172, 123), (side * 1055, -632, 1275), INK, "plastic")
        m.box("Bucket seat cushion", (519, 585, 140), (side * 444, 123, 808), cabin, "fabric")
        m.box("Bucket seat back", (509, 148, 563), (side * 444, 337, 877), cabin, "fabric")
        m.box("Bed side wall", (143, 1630, 505), (side * 840, 1547, 600), paint, "painted_metal")
        m.box("Headlamp", (386, 43, 209), (side * 647, -2551, 773), "#D8CE9F", "plastic")
        m.box("Tail lamp", (163, 58, 245), (side * 754, 2395, 817), "#A63637", "plastic")
        for front, y in [("Front", -1640), ("Rear", 1636)]:
            prefix = f"{front} {'left' if side < 0 else 'right'}"
            m.add(s3d.cylinder(prefix + " tire", 786, 229),
                  (side * 781, y, 393), "#2C3031", "rubber", (0, side * 90, 0))
            m.add(s3d.cylinder(prefix + " wheel hub", 388, 24),
                  (side * 1006, y, 393), bumper, "brushed_steel", (0, side * 90, 0))
    m.box("Windshield", (1580, 46, 576), (0, -775, 1146), GLASS, "glass", (-8, 0, 0))
    m.box("Rear glass", (1577, 40, 523), (0, 694, 1181), GLASS, "glass")
    m.box("Dashboard", (1610, 310, 190), (0, -644, 1040), cabin, "plastic")
    m.add(s3d.torus("Steering wheel", 325, 36), (-419, -483, 1234),
          INK, "rubber", (58, 0, 0))
    m.box("Open cargo bed floor", (1610, 1640, 133), (0, 1547, 593), "#596F74", "painted_metal")
    for x in range(-660, 661, 220):
        m.box("Cargo bed pressing", (42, 1515, 16), (x, 1547, 725), paint, "painted_metal")
    m.box("Tailgate", (1690, 117, 502), (0, 2342, 609), paint, "painted_metal")
    m.box("Front bumper", (1990, 155, 163), (0, -2535, 517), bumper, "brushed_steel")
    m.box("Rear bumper", (1900, 151, 132), (0, 2431, 487), bumper, "brushed_steel")
    m.box("Radiator grille", (741, 42, 245), (0, -2549, 766), INK, "plastic")
    for z in (792, 855, 918):
        m.box("Grille strip", (696, 22, 17), (0, -2570, z), bumper, "brushed_steel")
    return m


def passenger_door():
    m = Model("pickup_passenger_door")
    m.box("Door skin", (115, 1470, 483), (0, 730, 0), "#697D83", "painted_metal")
    m.box("Handle", (42, 138, 33), (75, 1136, 418), "#A0A29B", "brushed_steel")
    # Origin is on the front hinge. Mount at (852, -771, 665) in pickup space.
    return m


def fuel_gauge():
    m = Model("pickup_low_fuel_gauge")
    m.box("Dash insert", (174, 32, 86), (0, 0, 0), INK, "plastic")
    label(m, "E", 21, (-64, -19, 59))
    label(m, "F", 21, (63, -19, 59))
    m.box("Low fuel needle", (47, 8, 4), (-22, -22, 34), "#D16950", "plastic", (0, 20, 0))
    m.box("Low fuel warning", (22, 7, 11), (49, -22, 18), STRIPE, "plastic")
    return m


def highway():
    m = Model("two_lane_highway_24m")
    m.box("Asphalt bed", (9100, 24000, 150), (0, 0, 0), ASPHALT, "concrete")
    for x in (-4690, 4690):
        m.box("Gravel shoulder", (1480, 24000, 127), (x, 0, 0), "#9D9886", "concrete")
    for x in (-3440, 3440):
        m.box("White edge line", (100, 24000, 5), (x, 0, 150), WHITE, "plastic")
    for y in (-9000, -3000, 3000, 9000):
        m.box("Yellow center dash", (127, 2900, 5), (0, y, 150), STRIPE, "plastic")
    return m


def guardrail():
    m = Model("highway_guardrail_8m")
    for y in (-3000, -1000, 1000, 3000):
        m.box("Rail post", (110, 118, 821), (0, y, 0), STEEL, "brushed_steel")
        m.box("Rail spacer", (164, 183, 131), (89, y, 632), STEEL, "brushed_steel")
    for z, x in [(571, 159), (663, 211), (756, 159)]:
        m.box("Folded steel rail", (62, 8000, 110), (x, 0, z), STEEL, "brushed_steel")
    return m


def signs():
    m = Model("overhead_west_route_sign")
    for x in (-4780, 4780):
        m.box("Overhead sign upright", (232, 258, 6710), (x, 0, 0), STEEL, "brushed_steel")
    m.box("Crossbeam", (9910, 238, 246), (0, 0, 6320), STEEL, "brushed_steel")
    m.box("Sign trim", (2910, 189, 1250), (1250, -113, 5030), WHITE, "painted_metal")
    m.box("Green sign face", (2850, 37, 1190), (1250, -232, 5060), GREEN, "painted_metal")
    label(m, "WEST", 390, (1250, -255, 5890))
    label(m, "ROUTE 6", 315, (1250, -255, 5405))
    yield m
    m = Model("county_road_signpost")
    m.round("Signpost", 69, 2680, (0, 0, 0), STEEL, "brushed_steel")
    m.box("Directional sign", (1580, 52, 325), (455, 0, 2220), GREEN, "painted_metal")
    label(m, "OLD COUNTY RD", 146, (455, -28, 2378))
    m.box("Cross street plate", (54, 1450, 294), (0, 313, 2520), GREEN, "painted_metal")
    label(m, "MILL ROAD", 137, (28, 313, 2663), rotation=(90, 0, 90))
    yield m
    m = Model("roadside_utility_pole")
    m.round("Pole", 259, 7640, (0, 0, 0), "#765C47", "pine", 176)
    m.box("Crossarm", (2040, 124, 132), (0, 0, 6890), "#765C47")
    for x in (-820, 0, 820):
        m.round("Porcelain insulator", 145, 142, (x, 0, 7015), WHITE, "ceramic")
    yield m
    m = Model("blackout_traffic_signal")
    m.round("Mast upright", 152, 5410, (0, 0, 0), STEEL, "brushed_steel")
    m.box("Mast arm", (3780, 124, 126), (1794, 0, 5188), STEEL, "brushed_steel")
    m.box("Signal case", (295, 230, 862), (3520, -79, 4380), INK, "painted_metal")
    for i, tone in enumerate(("#35483B", "#685E3B", "#653D3A")):
        z = 4490 + i * 260
        m.add(s3d.cylinder("Unlit signal lens", 169, 19), (3520, -204, z),
              tone, "plastic", (90, 0, 0))
        m.box("Sun visor", (212, 176, 36), (3520, -261, z + 90), INK, "painted_metal")
    yield m


def station_shop():
    m = Model("last_stop_shop_shell")
    width, depth = 9100, 6290
    m.box("Concrete slab", (width + 120, depth + 120, 139), (0, 0, 0), PAVEMENT, "concrete")
    for x in (-4485, 4485):
        m.box("Shop side wall", (150, depth, 3090), (x, 0, 138), "#C0AA87", "concrete")
    m.box("Back wall", (width, 150, 3090), (0, 3090, 138), "#C0AA87", "concrete")
    for x in (-4210, -1115, 1115, 4210):
        m.box("Storefront pillar", (560, 261, 2990), (x, -3060, 137), "#C0AA87", "concrete")
    m.box("Storefront header", (width, 322, 888), (0, -3080, 2322), GREEN, "painted_metal")
    m.box("Roof deck", (width + 340, depth + 346, 192), (0, 0, 3200), "#575E5D", "painted_metal")
    for x in (-2662, 2662):
        m.box("Display lower wall", (2580, 173, 835), (x, -3152, 137), "#ACA189", "concrete")
        m.box("Display glass", (2440, 38, 1350), (x, -3130, 969), GLASS, "glass")
        m.box("Center mullion", (75, 100, 1390), (x, -3139, 953), STEEL, "brushed_steel")
        m.box("Window ledge", (2615, 264, 63), (x, -3165, 930), STEEL, "brushed_steel")
    label(m, "LAST STOP FUEL", 460, (0, -3251, 2780))
    return m


def station_hinged_door():
    m = Model("shop_glass_door")
    for x in (42, 856):
        m.box("Stile", (85, 47, 2164), (x, 0, 0), STEEL, "brushed_steel")
    for z in (0, 1043, 2079):
        m.box("Door rail", (895, 51, 85), (449, 0, z), STEEL, "brushed_steel")
    m.box("Glazing", (742, 24, 1999), (450, 0, 82), GLASS, "glass")
    m.box("Pull", (43, 82, 239), (752, -37, 983), INK, "plastic")
    return m


def canopy():
    m = Model("fuel_canopy")
    for x in (-4590, 4590):
        for y in (-1900, 1900):
            m.box("Concrete post base", (411, 438, 412), (x, y, 0), PAVEMENT, "concrete")
            m.box("Canopy post", (257, 271, 3930), (x, y, 405), "#B2B0A4", "painted_metal")
    m.box("Canopy ceiling", (11230, 6260, 138), (0, 0, 4270), WHITE, "painted_metal")
    m.box("Canopy roof", (11480, 6490, 389), (0, 0, 4420), RED, "painted_metal")
    m.box("Front edging", (11520, 62, 105), (0, -3245, 4440), "#E1C49B", "painted_metal")
    for x in (-3260, 0, 3260):
        m.box("Unlit canopy fixture", (316, 691, 62), (x, 0, 4229), "#C9C8AC", "plastic")
    return m


def dispenser():
    m = Model("dark_fuel_dispenser")
    m.box("Concrete island", (1340, 1500, 153), (0, 0, 0), PAVEMENT, "concrete")
    m.box("Fuel cabinet", (795, 435, 1380), (0, 0, 152), "#A2A496", "painted_metal")
    m.box("Dark control fascia", (697, 62, 532), (0, -242, 874), INK, "plastic")
    m.box("Unpowered display", (485, 16, 161), (0, -280, 1163), "#252D2E", "plastic")
    for i in range(3):
        m.box("Fuel grade button", (106, 20, 73), (-178 + i * 178, -286, 944), STRIPE, "plastic")
    m.box("Pump top", (825, 464, 132), (0, 0, 1452), RED, "painted_metal")
    label(m, "REGULAR", 109, (0, -235, 1511))
    m.box("Nozzle cradle", (157, 110, 232), (405, -73, 875), INK, "plastic")
    m.box("Hose mount", (98, 114, 108), (416, 74, 1310), INK, "plastic")
    return m


def nozzle():
    m = Model("fuel_nozzle")
    m.box("Nozzle grip", (77, 172, 83), (0, 0, 14), "#414748", "rubber")
    for x in (-26, 26):
        m.box("Trigger guard side", (22, 143, 62), (x, 6, -16), INK, "plastic")
    m.box("Trigger", (29, 94, 27), (0, 18, -4), STEEL, "brushed_steel", (10, 0, 0))
    m.add(s3d.cylinder("Spout", 23, 181), (0, -59, 59), STEEL, "brushed_steel", (77, 0, 0))
    return m


def parked_hose():
    m = Model("pump_hose")
    path = [(426, 92, 1340), (567, 104, 1190), (679, 114, 536),
            (666, 20, 300), (563, -105, 301), (487, -160, 487),
            (452, -172, 978)]
    sections = [s3d.at(s3d.circle(34), *position) for position in path]
    m.add(s3d.loft("Hanging rubber hose", *sections, follow=True),
          (0, 0, 0), INK, "rubber")
    return m


def price_pylon():
    m = Model("last_stop_price_sign")
    m.box("Pylon footing", (800, 760, 252), (0, 0, 0), PAVEMENT, "concrete")
    m.box("Pylon post", (281, 290, 5000), (0, 0, 242), STEEL, "painted_metal")
    m.box("Sign cabinet", (2890, 309, 1513), (0, 0, 3480), RED, "painted_metal")
    m.box("Price panel", (2550, 25, 590), (0, -181, 3625), INK, "painted_metal")
    label(m, "LAST STOP FUEL", 261, (0, -158, 4604))
    label(m, "REGULAR  3.49", 270, (0, -198, 3919), "#D8C192")
    return m


def shop_fixtures():
    m = Model("station_checkout_counter")
    m.box("Checkout cabinet", (2050, 760, 965), (0, 0, 0), "#7C6B56")
    m.box("Laminate top", (2150, 810, 65), (0, 0, 963), "#C5B390", "plastic")
    m.box("Register base", (461, 324, 152), (635, 38, 1028), INK, "plastic")
    m.box("Dead register screen", (318, 85, 164), (635, 111, 1173), INK, "plastic")
    yield m
    m = Model("station_aisle_shelf")
    shelves(m, 1530, 430, 1540, [90, 450, 846, 1160])
    for x, y, z in [(-463, -41, 485), (-315, -40, 485), (402, 3, 880), (551, 3, 880)]:
        m.round("Abandoned tin", 99, 144, (x, y, z), "#A46B4C", "painted_metal")
        m.round("Tin lid", 101, 9, (x, y, z + 140), STEEL, "brushed_steel")
    yield m
    m = Model("dead_drink_cooler")
    m.box("Cooler cabinet", (1680, 635, 2130), (0, 0, 0), "#B9BAB0", "painted_metal")
    m.box("Dark inside", (1530, 30, 1770), (0, -322, 181), INK, "plastic")
    for x in (-783, 0, 783):
        m.box("Cooler door stile", (46, 93, 1930), (x, -345, 143), STEEL, "brushed_steel")
    for z in (173, 610, 1050, 1480, 1994):
        m.box("Shelf or sill", (1495, 92, 30), (0, -340, z), "#64706F", "painted_metal")
    for x in (-387, 387):
        m.box("Dark glazing", (720, 19, 1730), (x, -397, 248), "#54717A", "glass")
    yield m
    m = Model("shop_door_bell")
    m.box("Mounting bracket", (68, 44, 46), (0, 0, 83), STEEL, "brushed_steel")
    m.round("Bell shell", 74, 61, (0, -41, 32), "#A68755", "brass", 39)
    m.round("Clapper", 16, 24, (0, -41, 11), STEEL, "brushed_steel")
    yield m


def props():
    m = Model("pickup_water_jug")
    m.box("Jug body", (158, 302, 343), (0, 0, 0), "#B6CED0", "plastic")
    m.round("Screw top", 62, 24, (0, -76, 343), RED, "plastic")
    for y in (25, 104):
        m.box("Handle support", (34, 38, 63), (0, y, 337), "#AEC5C4", "plastic")
    m.box("Carry handle", (37, 118, 33), (0, 65, 390), "#AEC5C4", "plastic")
    yield m
    m = Model("sealed_water_bottle")
    m.round("Bottle body", 64, 157, (0, 0, 0), "#9BBCC2", "plastic", 58)
    m.round("Bottle shoulder", 58, 31, (0, 0, 155), "#9BBCC2", "plastic", 26)
    m.round("Bottle cap", 30, 17, (0, 0, 183), GREEN, "plastic")
    m.round("Paper wrap", 65, 42, (0, 0, 63), WHITE, "plastic")
    yield m
    m = Model("tin_rations")
    for x, y in [(-48, -51), (55, -51), (-48, 51), (55, 51)]:
        m.round("Food can", 84, 106, (x, y, 0), "#AB7150", "painted_metal")
        m.round("Metal lid", 85, 8, (x, y, 102), STEEL, "brushed_steel")
    yield m
    m = Model("truck_keys")
    m.add(s3d.torus("Ring", 33, 4), (0, 0, 4), STEEL, "brushed_steel")
    m.box("Pickup key head", (32, 27, 10), (18, 13, 0), INK, "plastic", (0, 0, 26))
    m.box("Key blade", (12, 37, 6), (34, 34, 1), STEEL, "brushed_steel", (0, 0, -32))
    yield m
    m = Model("open_road_atlas")
    m.box("Back cover", (341, 267, 7), (0, 0, 0), RED)
    for x in (-82, 82):
        m.box("Atlas pages", (160, 251, 7), (x, 0, 7), "#DDD2AB", "plastic")
    for i, (a, b) in enumerate([((-142,-91,15),(-33,-25,15)),((-33,-25,15),(49,-25,15)),
                                 ((49,-25,15),(134,67,15)),((-74,102,15),(49,-25,15)),
                                 ((49,-25,15),(89,-105,15)),((-148,37,15),(-33,-25,15))]):
        member(m, "Map road", a, b, 2.4, RED if i < 3 else "#999681", "plastic")
    yield m
    m = Model("noon_note")
    m.box("Folded paper", (237, 121, 2), (0, 0, 0), "#E6D7A6", "plastic")
    label(m, "IF YOU'RE GOING WEST,", 14, (0, 30, 2.4), INK, (0, 0, 0))
    label(m, "USE THE OLD COUNTY ROAD", 14, (0, 7, 2.4), INK, (0, 0, 0))
    label(m, "I LEFT THIS AT NOON.", 15, (0, -25, 2.4), INK, (0, 0, 0))
    yield m
    for name, digits in [("clock_0712", "7:12"), ("clock_1212", "12:12")]:
        m = Model(name)
        m.box("Clock body", (236, 130, 103), (0, 0, 0), RED, "plastic")
        m.box("Screen", (182, 10, 65), (0, -68, 19), INK, "plastic")
        label(m, digits, 57, (0, -75, 53), "#E16C4B")
        yield m


def plant_silhouette():
    m = Model("plant_horizon_silhouette")
    for x in (-33000, 33000):
        outline = s3d.poly([(0, 0), (23500, 0), (18900, 22500), (14900, 60500),
                            (16400, 86000), (17600, 86000), (16200, 60500),
                            (20100, 22500), (24700, 0)])
        m.add(s3d.revolve("Cooling tower exterior", outline), (x, 18000, 0),
              "#969B94", "concrete")
    m.box("Industrial block", (46500, 21400, 14200), (0, -21000, 0), "#828E8A", "concrete")
    m.box("Industrial annex", (20700, 18400, 8950), (32800, -18850, 0), "#A2A499", "concrete")
    m.round("Roofline column", 3200, 39100, (11500, -18300, 0), "#A4A49A", "concrete", 2450)
    return m


def export_group(category, models, inventory):
    folder = OUT / category
    folder.mkdir(parents=True, exist_ok=True)
    for item in models:
        if isinstance(item, Model):
            name = item.name
            asset = s3d.assembly(name, *item.parts)
        else:
            asset = item
            name = item.root.name
        path = folder / (name + ".glb")
        s3d.export(asset, path)
        inventory.append({"name": name, "category": category,
                          "asset": path.relative_to(OUT).as_posix(), "generator": "Sand3D"})


def main():
    groups = [
        ("houses", lambda: (borrow_house(), cedar_bungalow())),
        ("vehicle", lambda: (pickup(), passenger_door(), fuel_gauge())),
        ("highway", lambda: (highway(), guardrail(), *signs())),
        ("station", lambda: (station_shop(), station_hinged_door(), canopy(),
                             dispenser(), nozzle(), parked_hose(), price_pylon(), *shop_fixtures())),
        ("props", props),
        ("background", lambda: (plant_silhouette(),)),
    ]
    inventory = []
    for category, models in groups:
        s3d.empty_scene()
        export_group(category, models(), inventory)
    (OUT / "inventory.json").write_text(json.dumps(inventory, indent=2) + "\n", encoding="utf-8")
    print(f"Exported {len(inventory)} models to {OUT}")


if __name__ == "__main__":
    main()
