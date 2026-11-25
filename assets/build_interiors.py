"""Build the Sand3D house interior kit. Source dimensions are millimetres."""
import json
from math import atan2, cos, degrees, hypot, radians, sin
from pathlib import Path

import sand3d as s3d

OUT = Path(__file__).with_name("interiors")
OAK, WALNUT, CREAM = "#A97C53", "#6C4D3B", "#E5D8C3"
INK, METAL, GLASS = "#343D43", "#A7A6A0", "#6B8994"
SAGE, RUST, BLUE = "#66776B", "#A56046", "#557180"
WHITE, CHARCOAL = "#EFE8D9", "#252F32"


class Model:
    def __init__(self, name):
        self.name = name
        self.parts = []

    def add(self, obj, position, color, finish, rotation=(0, 0, 0)):
        s3d.transform(obj, *position, *rotation)
        s3d.material(obj, finish, color=color)
        self.parts.append(obj)

    def box(self, name, size, p, color, finish="pine", rotation=(0, 0, 0)):
        self.add(s3d.box(name, *size), p, color, finish, rotation)

    def round(self, name, diameter, height, p, color, finish="plastic", tip=None):
        shape = (s3d.cylinder(name, diameter, height) if tip is None
                 else s3d.cone(name, diameter, height, tip))
        self.add(shape, p, color, finish)

    def bowl(self, name, diameter, height, p, color, finish="ceramic"):
        r = diameter / 2
        inner_bottom = max(6, r * .55 - 8)
        profile = s3d.poly([(0, 0), (r * .54, 0), (r * .77, height * .28),
                            (r, height), (r - 8, height), (r * .68, height * .28),
                            (inner_bottom, 12), (0, 12)])
        self.add(s3d.revolve(name, profile), p, color, finish)

    def soft(self, name, size, p, color):
        width, depth, height = size
        outline = [(-.40, -.5), (.40, -.5), (.5, -.40), (.5, .40),
                   (.40, .5), (-.40, .5), (-.5, .40), (-.5, -.40)]
        sections = []
        for z, scale in [(0, .81), (height * .22, 1), (height * .77, 1), (height, .83)]:
            profile = s3d.poly([(x * width * scale, y * depth * scale) for x, y in outline])
            sections.append(s3d.at(profile, p[0], p[1], p[2] + z))
        self.add(s3d.loft(name, *sections), (0, 0, 0), color, "fabric")

    def legs(self, width, depth, height, color=OAK, thickness=58):
        for x in (-width / 2, width / 2):
            for y in (-depth / 2, depth / 2):
                self.box("Leg", (thickness, thickness, height), (x, y, 0), color)

    def face(self, name, width, height, x, z, y, color, pull=True):
        self.box(name, (width, 29, height), (x, y, z), color)
        if pull:
            self.box("Pull", (min(120, width / 2), 26, 22),
                     (x, y - 26, z + height * .69), METAL, "brushed_steel")


KIT = []


def asset(room, name, placement="floor"):
    model = Model(name)
    KIT.append((room, model, placement))
    return model


def living_room():
    for name, width, seats, color in [("three_seat_sofa", 2170, 3, SAGE), ("armchair", 920, 1, RUST)]:
        m = asset("living", name)
        m.legs(width - 220, 630, 130, WALNUT)
        m.soft("Upholstered base", (width, 840, 235), (0, 0, 105), color)
        m.soft("Upholstered back", (width - 100, 235, 540), (0, 293, 290), color)
        for x in (-width / 2 + 102, width / 2 - 102):
            m.soft("Padded arm", (210, 785, 330), (x, -12, 318), color)
        seat_width = (width - 400) / seats
        for i in range(seats):
            x = (i - (seats - 1) / 2) * seat_width
            m.soft("Seat cushion", (seat_width - 12, 620, 116), (x, -86, 311), color)
            m.soft("Back cushion", (seat_width - 18, 153, 340), (x, 177, 421), color)

    m = asset("living", "coffee_table")
    m.legs(1010, 455, 390, WALNUT)
    m.box("Top", (1170, 605, 48), (0, 0, 385), OAK)
    m.box("Lower shelf", (1030, 480, 32), (0, 0, 133), OAK)
    m = asset("living", "side_table")
    m.legs(347, 347, 490, WALNUT, 39)
    m.round("Round tabletop", 515, 42, (0, 0, 482), OAK, "oak")
    m = asset("living", "area_rug")
    rug(m, 2240, 1590)
    m = asset("living", "media_console")
    cupboard(m, 1640, 443, 520, OAK, 3)
    m = asset("living", "television", "surface")
    m.box("Stand", (528, 235, 24), (0, 0, 0), INK, "plastic")
    m.box("Stand neck", (92, 62, 98), (0, 25, 20), INK)
    m.box("Display housing", (1110, 58, 640), (0, 22, 106), CHARCOAL, "plastic")
    m.box("Screen", (1064, 8, 594), (0, -11, 129), "#384955", "plastic")
    m.round("Power light", 8, 3, (526, -10, 114), "#77A382")
    m = asset("living", "bookcase")
    shelves(m, 965, 325, 1765, [125, 450, 800, 1160, 1500])
    m = asset("living", "fireplace")
    m.box("Recess back", (925, 110, 680), (0, 150, 128), CHARCOAL, "concrete")
    m.box("Hearth", (1540, 670, 128), (0, -24, 0), "#967A68", "concrete")
    for x in (-543, 543):
        m.box("Masonry jamb", (320, 470, 845), (x, 57, 125), "#996C58", "concrete")
    m.box("Lintel", (1420, 470, 190), (0, 57, 954), "#996C58", "concrete")
    m.box("Mantel shelf", (1620, 530, 84), (0, 30, 1130), WALNUT)
    for x in (-152, 134):
        m.box("Split log", (375, 103, 90), (x, -22, 145), WALNUT, "bark", (0, 0, x / 5))


def rug(m, width, depth):
    m.box("Woven body", (width, depth, 8), (0, 0, 0), CREAM, "fabric")
    m.box("Inner field", (width - 140, depth - 140, 3), (0, 0, 8), BLUE, "fabric")
    for x in (-width * .36, 0, width * .36):
        m.box("Woven stripe", (32, depth - 192, 1), (x, 0, 11), CREAM, "fabric")


def cupboard(m, w, d, h, color, doors=2):
    m.box("Plinth", (w - 70, d - 42, 85), (0, 18, 0), WALNUT)
    m.box("Case", (w, d, h - 113), (0, 0, 83), color)
    m.box("Top", (w + 30, d + 32, 34), (0, 0, h - 34), color)
    for i in range(doors):
        m.face("Door", w / doors - 14, h - 138, (i - (doors - 1) / 2) * w / doors,
               91, -d / 2 - 10, color)


def shelves(m, w, d, h, levels):
    for x in (-w / 2 + 21, w / 2 - 21):
        m.box("Side", (42, d, h), (x, 0, 0), OAK)
    m.box("Back", (w - 66, 29, h - 60), (0, d / 2 - 17, 30), WALNUT)
    for z in [*levels, h - 37]:
        m.box("Shelf", (w - 75, d - 24, 37), (0, -8, z), OAK)


def drawers(m, w, d, h, rows):
    m.box("Base", (w - 65, d - 65, 82), (0, 0, 0), WALNUT)
    m.box("Cabinet", (w, d, h - 100), (0, 0, 72), OAK)
    m.box("Top", (w + 35, d + 32, 38), (0, 0, h - 38), OAK)
    gap = (h - 120) / rows
    for i in range(rows):
        m.face("Drawer", w - 50, gap - 12, 0, 78 + i * gap, -d / 2 - 12, OAK)


def bedroom():
    for name, width in [("single_bed", 1020), ("double_bed", 1510)]:
        m = asset("bedroom", name)
        m.legs(width - 120, 1850, 198, WALNUT, 73)
        m.box("Bed frame", (width + 45, 2080, 156), (0, 0, 163), OAK)
        m.box("Headboard", (width + 70, 105, 845), (0, 1003, 182), OAK)
        m.soft("Headboard inset", (width - 155, 52, 370), (0, 943, 594), SAGE)
        m.soft("Mattress", (width, 1960, 192), (0, -27, 307), WHITE)
        m.soft("Duvet", (width + 25, 1520, 92), (0, -235, 473), BLUE)
        m.soft("Folded blanket", (width + 30, 306, 40), (0, -711, 542), CREAM)
        for x in ([-width / 4, width / 4] if width > 1100 else [0]):
            m.soft("Pillow", (width * (.42 if width > 1100 else .62), 400, 103), (x, 686, 488), WHITE)
    drawers(asset("bedroom", "nightstand"), 465, 404, 545, 2)
    drawers(asset("bedroom", "dresser"), 1230, 515, 875, 4)
    cupboard(asset("bedroom", "wardrobe"), 1330, 605, 2070, OAK)
    m = asset("bedroom", "laundry_hamper")
    m.round("Woven basket", 364, 530, (0, 0, 0), OAK, "fabric", 450)
    m.round("Lid", 451, 30, (0, 0, 525), WALNUT, "pine")
    m.box("Lid handle", (105, 32, 37), (0, 0, 551), OAK)


def chair(m, color=OAK, office=False):
    if office:
        m.round("Center stem", 65, 345, (0, 0, 95), METAL, "brushed_steel")
        for angle in range(0, 360, 72):
            a = radians(angle)
            m.box("Base spoke", (250, 47, 47), (116 * cos(a), 116 * sin(a), 68),
                  INK, "plastic", (0, 0, angle))
            m.round("Caster", 65, 76, (242 * cos(a), 242 * sin(a), 0), INK)
    else:
        m.legs(365, 365, 424, color, 47)
    m.soft("Seat pad", (460, 453, 66), (0, 0, 413), BLUE if office else CREAM)
    for x in (-166, 166):
        m.box("Back support", (45, 58, 461), (x, 170, 412), color)
    m.soft("Backrest", (456, 88, 296), (0, 190, 600), BLUE if office else color)


def tap(m, p):
    x, y, z = p
    m.round("Faucet stem", 52, 157, (x, y, z), METAL, "brushed_steel")
    m.box("Spout", (46, 139, 38), (x, y - 58, z + 128), METAL, "brushed_steel")
    m.round("Aerator", 42, 38, (x, y - 118, z + 102), METAL, "brushed_steel")
    m.box("Lever", (96, 27, 15), (x + 32, y, z + 151), METAL, "brushed_steel")


def sink_counter(m, width, depth, height, color):
    rim = "#CFCDC1"
    # Four slabs form a genuine opening over a recessed basin.
    hole_w, hole_d = width * .60, depth * .52
    for x in (-1, 1):
        m.box("Counter wing", ((width - hole_w) / 2 + 10, depth, 42),
              (x * (width + hole_w) / 4, 0, height), rim, "concrete")
    for y in (-1, 1):
        m.box("Counter rail", (hole_w + 8, (depth - hole_d) / 2 + 12, 42),
              (0, y * (depth + hole_d) / 4, height), rim, "concrete")
    for x in (-1, 1):
        m.box("Basin side", (29, hole_d, 115), (x * hole_w / 2, 0, height - 97), color, "ceramic")
    for y in (-1, 1):
        m.box("Basin end", (hole_w, 29, 115), (0, y * hole_d / 2, height - 97), color, "ceramic")
    m.box("Basin bottom", (hole_w, hole_d, 29), (0, 0, height - 119), color, "ceramic")
    m.round("Drain", 51, 6, (0, 0, height - 89), METAL, "brushed_steel")
    tap(m, (0, depth * .41, height + 42))


def sink_apron(m, width, depth, height, color):
    for y in (-depth / 2 + 18, depth / 2 - 18):
        m.box("Under-counter rail", (width, 35, 105), (0, y, height - 102), color)
    for x in (-width / 2 + 16, width / 2 - 16):
        m.box("Under-counter side", (32, depth - 68, 105), (x, 0, height - 102), color)


def kitchen():
    m = asset("kitchen", "dining_table")
    m.legs(1220, 625, 715, WALNUT, 76)
    m.box("Apron", (1390, 670, 115), (0, 0, 620), WALNUT)
    m.box("Tabletop", (1550, 835, 55), (0, 0, 703), OAK)
    chair(asset("kitchen", "dining_chair"))
    m = asset("kitchen", "bar_stool")
    m.legs(313, 313, 721, WALNUT, 42)
    for y in (-153, 153):
        m.box("Footrest", (340, 47, 44), (0, y, 254), WALNUT)
    m.round("Stool seat", 415, 47, (0, 0, 706), OAK, "oak")
    cupboard(asset("kitchen", "base_cabinet"), 900, 610, 904, SAGE)
    cupboard(asset("kitchen", "wall_cabinet", "wall"), 900, 344, 725, SAGE)
    m = asset("kitchen", "kitchen_sink")
    cupboard(m, 900, 610, 773, SAGE)
    sink_apron(m, 900, 610, 875, SAGE)
    sink_counter(m, 930, 650, 875, METAL)
    m = asset("kitchen", "refrigerator")
    m.box("Fridge cabinet", (758, 680, 1780), (0, 0, 0), "#B6BCBA", "brushed_steel")
    for z, height in [(66, 1110), (1193, 578)]:
        m.face("Insulated door", 734, height, 0, z, -355, "#D2D3C7", pull=False)
        m.box("Vertical handle", (53, 51, 268), (-273, -389, z + 138), METAL, "brushed_steel")
    m = asset("kitchen", "range_oven")
    m.box("Range", (630, 620, 861), (0, 0, 0), METAL, "brushed_steel")
    m.face("Oven door", 590, 520, 0, 119, -324, INK)
    m.box("Oven glass", (479, 21, 300), (0, -345, 243), "#445255", "plastic")
    m.box("Control strip", (625, 55, 128), (0, -317, 722), INK, "plastic")
    for x in (-232, -116, 0, 116, 232):
        m.round("Control knob", 39, 8, (x, -346, 790), METAL)
    m.box("Cooktop", (630, 623, 25), (0, 0, 853), CHARCOAL, "ceramic")
    for x in (-147, 147):
        for y in (-144, 144):
            m.round("Burner rim", 172, 12, (x, y, 878), METAL, "brushed_steel")
            m.round("Burner center", 146, 6, (x, y, 890), INK)
    m = asset("kitchen", "microwave", "surface")
    m.box("Microwave body", (522, 370, 309), (0, 0, 0), "#C4C5BC", "brushed_steel")
    m.face("Oven window", 374, 263, -60, 23, -195, INK, pull=False)
    m.box("Tinted glass", (325, 17, 212), (-60, -213, 48), "#48585B", "plastic")
    m.box("Handle", (26, 38, 180), (129, -219, 56), METAL)
    m.box("Display", (73, 17, 35), (207, -194, 204), "#547C70", "plastic")
    for i in range(3):
        m.box("Button", (65, 14, 19), (207, -194, 116 + 25 * i), INK, "plastic")
    m = asset("kitchen", "dishwasher")
    m.box("Dishwasher body", (599, 625, 860), (0, 0, 0), INK, "brushed_steel")
    m.face("Steel wash door", 575, 723, 0, 80, -323, "#C2C4BB")
    m.box("Control strip", (563, 18, 55), (0, -343, 774), CHARCOAL, "plastic")
    m = asset("kitchen", "dish_set", "surface")
    m.bowl("Dinner plate", 260, 28, (-122, 0, 0), WHITE)
    m.bowl("Cereal bowl", 151, 70, (103, 26, 0), BLUE)
    m.bowl("Cup", 87, 89, (115, -110, 0), RUST)
    m = asset("kitchen", "stockpot", "surface")
    m.bowl("Pot body", 280, 175, (0, 0, 0), METAL, "brushed_steel")
    m.round("Lid", 284, 18, (0, 0, 174), METAL, "brushed_steel")
    m.round("Lid knob", 55, 34, (0, 0, 189), INK)
    for x in (-154, 154):
        m.box("Handle", (63, 80, 26), (x, 0, 108), INK, "plastic")
    m = asset("kitchen", "cutting_board", "surface")
    m.box("Board", (345, 232, 22), (0, 0, 0), OAK)
    m.box("Handle", (86, 76, 22), (0, 143, 0), WALNUT)


def bathroom():
    m = asset("bathroom", "bathroom_vanity")
    cupboard(m, 815, 501, 762, OAK)
    sink_apron(m, 815, 501, 856, OAK)
    sink_counter(m, 849, 525, 856, WHITE)
    m = asset("bathroom", "toilet")
    m.round("Foot", 236, 62, (0, -61, 0), WHITE, "ceramic")
    m.round("Pedestal", 207, 281, (0, -61, 51), WHITE, "ceramic", 295)
    m.bowl("Bowl", 394, 149, (0, -102, 285), WHITE)
    m.box("Cistern", (399, 199, 383), (0, 176, 368), WHITE, "ceramic")
    m.box("Tank lid", (426, 226, 32), (0, 177, 742), WHITE, "ceramic")
    m.round("Flush button", 41, 8, (92, 177, 774), METAL, "brushed_steel")
    m = asset("bathroom", "bathtub")
    m.box("Tub floor", (787, 1630, 119), (0, 0, 25), WHITE, "ceramic")
    for x in (-366, 366):
        m.box("Bath side", (89, 1640, 523), (x, 0, 23), WHITE, "ceramic")
        m.box("Long rim", (123, 1680, 54), (x, 0, 538), WHITE, "ceramic")
    for y in (-779, 779):
        m.box("Bath end", (745, 90, 523), (0, y, 23), WHITE, "ceramic")
        m.box("End rim", (780, 110, 54), (0, y, 538), WHITE, "ceramic")
    tap(m, (0, 784, 592))
    m = asset("bathroom", "shower_stall")
    m.box("Shower tray", (930, 930, 88), (0, 0, 0), WHITE, "ceramic")
    m.round("Drain", 123, 6, (0, 0, 88), METAL, "brushed_steel")
    for x in (-446, 446):
        for y in (-446, 446):
            m.box("Frame upright", (42, 42, 2030), (x, y, 75), METAL, "brushed_steel")
        m.box("Side glazing", (18, 850, 1910), (x, 0, 116), "#A5C8C5", "glass")
    m.box("Rear panel", (862, 43, 2009), (0, 446, 91), "#D9D9CD", "ceramic")
    m.box("Sliding glass", (558, 18, 1908), (-162, -448, 113), "#A5C8C5", "glass")
    m.box("Top track", (930, 45, 52), (0, -447, 2020), METAL, "brushed_steel")
    m.box("Pull", (26, 64, 243), (55, -471, 881), METAL, "brushed_steel")
    m.box("Shower arm", (48, 218, 43), (0, 337, 1830), METAL, "brushed_steel")
    m.round("Shower head", 151, 36, (0, 246, 1798), METAL, "brushed_steel")
    m = asset("bathroom", "bath_mat")
    rug(m, 715, 448)
    m = asset("bathroom", "mirror", "wall")
    m.box("Mirror frame", (695, 55, 860), (0, 0, 0), WALNUT)
    m.box("Mirror face", (613, 15, 779), (0, -29, 41), "#B8CDD0", "chrome")
    m = asset("bathroom", "towel_rack", "wall")
    for x in (-240, 240):
        m.box("Wall bracket", (45, 103, 55), (x, 0, 354), METAL, "brushed_steel")
    m.box("Towel bar", (527, 38, 39), (0, -52, 365), METAL, "brushed_steel")
    m.soft("Hanging towel", (325, 61, 403), (0, -74, 0), CREAM)


def office_utility():
    m = asset("office", "writing_desk")
    m.legs(1110, 460, 720, WALNUT, 65)
    m.box("Worktop", (1320, 648, 56), (0, 0, 706), OAK)
    m.box("Drawer block", (458, 476, 172), (360, 0, 541), OAK)
    m.face("Drawer front", 441, 148, 360, 554, -249, OAK)
    chair(asset("office", "desk_chair"), INK, office=True)
    drawers(asset("office", "filing_cabinet"), 486, 550, 1070, 3)
    m = asset("office", "laptop", "surface")
    m.box("Laptop base", (327, 229, 15), (0, 0, 0), METAL, "brushed_steel")
    m.box("Keyboard", (282, 111, 5), (0, 25, 15), CHARCOAL, "plastic")
    m.box("Touchpad", (90, 53, 3), (0, -54, 15), "#777D7D", "plastic")
    m.box("Display lid", (327, 15, 207), (0, 106, 12), INK, "plastic", (-14, 0, 0))
    angle = .2443
    m.box("Display", (301, 5, 175), (0, 101 + 17 * angle, 27), BLUE, "plastic", (-14, 0, 0))
    for name, color in [("washing_machine", "#DADAD0"), ("tumble_dryer", "#C9C5BA")]:
        m = asset("utility", name)
        m.box("Appliance case", (602, 620, 865), (0, 0, 0), color, "painted_metal")
        m.box("Controls", (577, 36, 109), (0, -321, 738), INK, "plastic")
        m.box("Readout", (131, 10, 38), (-146, -344, 774), "#6D9282", "plastic")
        for label, diameter, depth, y, finish, tone in [
                ("Door surround", 457, 43, -313, "brushed_steel", METAL),
                ("Door glass", 354, 15, -356, "plastic", "#526768"),
                ("Dial", 58, 18, -340, "plastic", CREAM)]:
            z = 447 if label != "Dial" else 794
            x = 0 if label != "Dial" else 182
            m.add(s3d.cylinder(label, diameter, depth), (x, y, z), tone, finish, (90, 0, 0))
    shelves(asset("utility", "storage_shelving"), 1120, 460, 1850, [90, 500, 930, 1370])
    m = asset("utility", "storage_box", "surface")
    m.box("Box", (478, 367, 287), (0, 0, 0), "#95795B", "concrete")
    m.box("Lid", (501, 389, 53), (0, 0, 282), "#AD9274", "concrete")
    m.box("Label", (109, 4, 52), (0, -184, 140), CREAM, "plastic")
    m = asset("utility", "wastebasket")
    m.bowl("Open bin", 278, 319, (0, 0, 0), SAGE, "painted_metal")


def decor_and_architecture():
    for name, h, spread, placement in [
            ("floor_lamp", 1515, 396, "floor"), ("table_lamp", 505, 272, "surface"),
            ("ceiling_pendant", 355, 354, "ceiling")]:
        m = asset("lighting", name, placement)
        if placement == "ceiling":
            m.round("Ceiling canopy", 152, 29, (0, 0, h - 29), INK, "painted_metal")
            m.round("Pendant rod", 24, h - 130, (0, 0, 126), INK, "painted_metal")
            m.round("Pendant shade", spread, 135, (0, 0, 0), RUST, "painted_metal", 98)
            m.round("Lens", spread - 27, 7, (0, 0, 0), CREAM, "light")
        else:
            m.round("Foot", spread * .72, 29, (0, 0, 0), INK, "painted_metal")
            m.round("Stem", 32, h - 185, (0, 0, 26), METAL, "brushed_steel")
            m.round("Linen shade", spread, 221 if h < 600 else 290,
                    (0, 0, h - 179), CREAM, "fabric", spread * .65)
    m = asset("lighting", "wall_sconce", "wall")
    m.box("Wall plate", (102, 24, 164), (0, 0, 0), METAL, "brushed_steel")
    m.box("Lamp arm", (36, 107, 36), (0, -50, 79), METAL, "brushed_steel")
    m.round("Glass shade", 172, 168, (0, -101, 90), CREAM, "ceramic", 132)
    m = asset("decor", "potted_plant")
    m.round("Terracotta pot", 230, 283, (0, 0, 0), RUST, "ceramic", 346)
    m.round("Pot rim", 363, 46, (0, 0, 254), RUST, "ceramic")
    m.round("Soil", 318, 22, (0, 0, 282), WALNUT, "soil")
    for dx, dy, z in [(-129, 20, 454), (104, 48, 555), (30, -138, 597), (-65, 52, 747), (63, 85, 661)]:
        stem = s3d.cylinder("Plant stem", 17, hypot(hypot(dx, dy), z - 290))
        m.add(stem, (0, 0, 290), "#4D653E", "leaf",
              (-degrees(atan2(dy, z - 290)), degrees(atan2(dx, z - 290)), 0))
        m.soft("Leaf", (175, 100, 55), (dx, dy, z - 22), "#68854A")
    m = asset("decor", "book_stack", "surface")
    for i, (color, angle) in enumerate([(RUST, 0), (BLUE, 11), (SAGE, -8)]):
        z = i * 39
        m.box("Book cover", (211, 151, 38), (0, 0, z), color, "fabric", (0, 0, angle))
        m.box("Page block", (198, 143, 26), (0, -8, z + 6), CREAM, "fabric", (0, 0, angle))
    m = asset("decor", "framed_print", "wall")
    m.box("Wooden frame", (525, 40, 673), (0, 0, 0), WALNUT)
    m.box("Paper mat", (465, 10, 612), (0, -21, 30), CREAM)
    m.box("Blue print", (361, 8, 454), (0, -28, 107), BLUE)
    m.add(s3d.cylinder("Printed sun", 103, 3), (89, -34, 437), "#D6AA64", "fabric", (90, 0, 0))
    for i, (x, color) in enumerate([(-91, SAGE), (0, WALNUT), (98, RUST)]):
        m.box("Landscape band", (123, 4, 61 + i * 30), (x, -34, 111), color)
    m = asset("decor", "wall_clock", "wall")
    m.add(s3d.cylinder("Clock housing", 325, 51), (0, 22, 164), OAK, "pine", (90, 0, 0))
    m.add(s3d.cylinder("Clock face", 280, 7), (0, -28, 164), CREAM, "ceramic", (90, 0, 0))
    for x, z in [(0, 284), (-119, 158), (119, 158), (0, 36)]:
        m.box("Hour marker", (13, 4, 13), (x, -38, z), INK)
    m.box("Minute hand", (10, 7, 103), (0, -40, 164), INK, "plastic", (0, 9, 0))
    m.box("Hour hand", (13, 8, 73), (0, -44, 164), INK, "plastic", (0, -56, 0))
    m = asset("decor", "curtain_pair", "wall")
    m.box("Curtain rod", (1820, 52, 48), (0, 0, 1590), WALNUT)
    for side in (-1, 1):
        for i in range(5):
            m.soft("Curtain fold", (79, 102, 1590), (side * (516 + i * 63), -11 - 16 * (i % 2), 0), BLUE)
    m = asset("architecture", "interior_door")
    for x in (-487, 487):
        m.box("Jamb", (79, 165, 2135), (x, 0, 0), CREAM)
    m.box("Header", (1055, 166, 78), (0, 0, 2090), CREAM)
    m.box("Door slab", (887, 43, 2070), (0, 0, 11), OAK)
    for z, h in [(225, 645), (994, 882)]:
        m.box("Raised panel", (656, 13, h), (0, -26, z), "#B28A61")
    m.box("Lever plate", (55, 16, 181), (346, -28, 875), METAL, "brushed_steel")
    m.box("Lever", (112, 32, 25), (300, -47, 957), METAL, "brushed_steel")
    m = asset("architecture", "double_hung_window", "wall")
    for x in (-555, 555):
        m.box("Side jamb", (94, 145, 1210), (x, 0, 30), CREAM)
    for z in (30, 608, 1150):
        m.box("Window rail", (1170, 140, 79), (0, 0, z), CREAM)
    m.box("Sill", (1320, 262, 75), (0, -25, 0), OAK)
    m.box("Central muntin", (48, 114, 1120), (0, -12, 88), CREAM)
    for z in (108, 685):
        m.box("Glazing", (1040, 17, 463), (0, 2, z), GLASS, "glass")
    m = asset("architecture", "power_outlet", "wall")
    m.box("Face plate", (76, 8, 120), (0, 0, 0), WHITE, "plastic")
    for z in (34, 79):
        for x in (-10, 10):
            m.box("Slot", (5, 2, 12), (x, -5, z), INK, "plastic")
        m.round("Ground marking", 6, 1, (0, -5, z - 7), INK)
    m = asset("architecture", "light_switch", "wall")
    m.box("Face plate", (76, 8, 120), (0, 0, 0), WHITE, "plastic")
    m.box("Rocker", (34, 10, 63), (0, -8, 27), CREAM, "plastic")
    m = asset("architecture", "baseboard", "wall")
    m.box("Skirting", (2000, 21, 118), (0, 0, 0), CREAM)
    m.box("Top bead", (2000, 29, 22), (0, -2, 109), CREAM)
    m = asset("architecture", "wall_panel")
    m.box("Painted wall", (2000, 120, 2700), (0, 0, 0), "#D8D1BC", "concrete")
    m = asset("architecture", "plank_floor_tile")
    for row in range(10):
        cuts = (-1000, -320, 340, 1000) if row % 2 else (-1000, -660, 10, 680, 1000)
        for i, (left, right) in enumerate(zip(cuts, cuts[1:])):
            color = ("#A58463", "#B38F6B", "#AD8762", "#B69976")[(row * 3 + i) % 4]
            m.box("Floorboard", (right - left - 3, 197, 32),
                  ((left + right) / 2, -900 + row * 200, 0), color, "oak")
    m = asset("architecture", "ceiling_panel", "ceiling")
    m.box("Painted ceiling", (2000, 2000, 110), (0, 0, 0), WHITE, "concrete")


def entryway():
    m = asset("entryway", "shoe_bench")
    m.legs(854, 320, 459, WALNUT)
    m.box("Bench seat", (994, 426, 57), (0, 0, 420), OAK)
    for y in (-114, -38, 38, 114):
        m.box("Shoe shelf slat", (844, 57, 24), (0, y, 137), WALNUT)
    m.soft("Seat cushion", (840, 372, 56), (0, 0, 477), SAGE)
    m = asset("entryway", "coat_hooks", "wall")
    m.box("Mounting rail", (670, 35, 143), (0, 0, 0), OAK)
    for x in (-240, -80, 80, 240):
        m.box("Hook arm", (27, 70, 27), (x, -42, 56), METAL, "brushed_steel")
        m.box("Hook tip", (26, 23, 52), (x, -69, 58), METAL, "brushed_steel")
    m = asset("entryway", "entry_mat")
    m.box("Coir mat", (920, 542, 19), (0, 0, 0), "#907051", "fabric")
    for x in (-358, -304, 304, 358):
        m.box("Woven stripe", (24, 493, 2), (x, 0, 19), "#5A4A42", "fabric")
    m = asset("decor", "floating_shelf", "wall")
    m.box("Shelf board", (840, 249, 48), (0, -108, 142), OAK)
    for x in (-305, 305):
        m.box("Wall support", (45, 30, 155), (x, 0, 0), INK, "painted_metal")
        m.box("Horizontal support", (45, 210, 25), (x, -88, 130), INK, "painted_metal")


def main():
    OUT.mkdir(exist_ok=True)
    inventory = []
    for build in (living_room, bedroom, kitchen, bathroom, office_utility, decor_and_architecture, entryway):
        s3d.empty_scene()
        KIT.clear()
        build()
        for room, model, placement in KIT:
            folder = OUT / room
            folder.mkdir(exist_ok=True)
            path = folder / f"{model.name}.glb"
            s3d.export(s3d.assembly(model.name, *model.parts), path)
            inventory.append({"name": model.name, "category": room, "placement": placement,
                              "asset": path.relative_to(OUT).as_posix(), "generator": "Sand3D"})
    (OUT / "inventory.json").write_text(json.dumps(inventory, indent=2) + "\n", encoding="utf-8")
    print(f"Exported {len(inventory)} interior models to {OUT}")


if __name__ == "__main__":
    main()
