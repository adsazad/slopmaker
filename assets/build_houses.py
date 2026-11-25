"""Build reference-inspired town houses with Sand3D (millimetres)."""
from pathlib import Path
import argparse
import json
from math import atan2, degrees, hypot
import sand3d as s3d

OUT=Path(__file__).with_name("houses")

def part(name,size,at,color,kind="plastic"):
    ob=s3d.box(name,*size); s3d.transform(ob,*at); s3d.material(ob,kind,color=color); return ob

def house(name,body,trim,roof,door,window,style):
    p=[]
    def b(n,sz,at,c,k="plastic"): p.append(part(f"{name}_{n}",sz,at,c,k))
    # lot/foundation, main volume
    b("foundation",(10500,7600,550),(0,0,275),"#77766f","concrete")
    b("body",(10000,7100,3800),(0,0,2450),body,"pine")
    # pitched roof as two planes sloped along X; long eaves overhang both ends
    for side,sign in (("left",-1),("right",1)):
        r=s3d.box(f"{name}_roof_{side}",5900,7900,260)
        s3d.transform(r,sign*1450,0,4580,0,0,sign*0.48)
        s3d.material(r,"painted_metal",color=roof);p.append(r)
    b("ridge_cap",(300,7900,260),(0,0,5950),roof,"painted_metal")
    # centered porch with roof and posts
    b("porch_floor",(4300,2100,250),(1200,0,700),trim,"concrete")
    b("porch_ceiling",(4800,2400,220),(1200,0,3100),roof,"painted_metal")
    for x in (-700,3100):
        b("porch_post",(180,180,2450),(x,930,1900),trim)
    b("front_door",(1050,160,2250),(1800,3520,1575),door,"pine")
    b("door_glass",(620,40,880),(1800,3430,2050),window,"glass")
    # symmetric front windows with layered frames, sills, muntins, shutters
    for x in (-2800,0,4300):
        if x==0 and style==1: continue
        ww=1450 if style!=0 else 1150; hh=1450
        b("window_frame",(ww+220,180,hh+220),(x,3570,2600),trim)
        b("window_pane",(ww,50,hh),(x,3450,2600),window,"glass")
        b("window_mullion_v",(70,35,hh),(x,3410,2600),trim)
        b("window_mullion_h",(ww,35,70),(x,3410,2600),trim)
        b("window_sill",(ww+380,260,180),(x,3370,1770),trim)
    # board-and-batten/siding cues across front, kept subtle and aligned
    for z in range(850,4200,420):
        b("siding_course",(9960,45,26),(0,3550,z),trim)
    if style==1:
        # second story with three tall windows, broad cornice, front dormer accents
        b("upper_story",(9900,7100,2650),(0,0,5675),body,"pine")
        b("upper_cornice",(10200,300,240),(0,0,4370),trim)
        for x in (-3200,0,3200):
            b("upper_window_frame",(1500,180,1770),(x,3570,5600),trim)
            b("upper_window_glass",(1270,50,1540),(x,3450,5600),window,"glass")
            b("upper_mullion_v",(60,40,1540),(x,3410,5600),trim)
            b("upper_mullion_h",(1270,40,60),(x,3410,5600),trim)
            b("upper_sill",(1730,240,180),(x,3370,4700),trim)
        b("entry_roof",(3000,2400,220),(0,0,4450),roof,"painted_metal")
        for x in (-1300,1300): b("entry_pediment_post",(150,160,1800),(x,1050,3400),trim)
    # front steps, path, light fixtures, landscaping clumps
    for i in range(3): b("step",(2300-i*180,520,180),(1200,1100+i*420,500-i*150),"#aaa69d","concrete")
    b("walkway",(1800,6500,100),(1200,5000,-50),"#b6b0a4","concrete")
    for x in (-4300,4300):
        b("foundation_shrub",(1100,750,650),(x,3600,600),"#54764b","leaf")
    return s3d.assembly(name,*p).root

class HouseParts:
    """Assemble architecture oriented toward negative Y."""

    def __init__(self, name, trim):
        self.name = name
        self.trim = trim
        self.parts = []

    def box(self, label, size, position, color, kind="pine"):
        obj = part(label, size, position, color, kind)
        self.parts.append(obj)
        return obj

    def roof(self, half_width, depth, eave, rise, color, center_y=0):
        # The gable closes the space between the roof panels and the walls.
        outline = s3d.poly([(-half_width, 0), (half_width, 0), (0, rise)])
        for side in (-1, 1):
            panel = s3d.box("Sloping roof", hypot(half_width, rise) + 520, depth + 780, 190)
            s3d.transform(panel, side * half_width / 2, center_y, eave + rise / 2,
                          ry=side * degrees(atan2(rise, half_width)))
            s3d.material(panel, "painted_metal", color=color, roughness=.82)
            self.parts.append(panel)
        return [s3d.at(outline, 0, center_y + side * depth / 2, eave, rx=90) for side in (-1, 1)]

    def gable(self, half_width, depth, eave, rise, walls, roof, center_y=0):
        profile = self.roof(half_width, depth, eave, rise, roof, center_y)
        solid = s3d.loft("Gable walls", *profile)
        s3d.material(solid, "pine", color=walls)
        self.parts.append(solid)

    def window(self, x, y, sill, width, height):
        self.box("Window surround", (width + 180, 110, height + 150), (x, y - 40, sill - 75), self.trim)
        self.box("Blue glazing", (width, 42, height), (x, y - 116, sill), "#54747F", "painted_metal")
        self.box("Mullion", (45, 48, height), (x, y - 144, sill), self.trim)
        self.box("Meeting rail", (width, 48, 44), (x, y - 144, sill + height * .47), self.trim)
        self.box("Window sill", (width + 260, 270, 94), (x, y - 110, sill - 105), self.trim)

    def door(self, x, y, base, width, color):
        self.box("Door casing", (width + 195, 120, 2250), (x, y - 46, base), self.trim)
        self.box("Door", (width, 50, 2120), (x, y - 128, base), color)
        self.box("Door light", (width * .58, 32, 550), (x, y - 165, base + 1360), "#597780")
        self.box("Brass handle", (58, 52, 133), (x + width * .35, y - 175, base + 910), "#B8914E", "brass")

    def stairs(self, x, y, width, count, color):
        for i in range(count):
            self.box("Front step", (width, 340, (count - i) * 155),
                     (x, y - (i + .5) * 340, 0), color, "concrete")

    def assemble(self):
        return s3d.assembly(self.name, *self.parts)


def craftsman_cottage():
    h = HouseParts("craftsman_cottage", "#E8D9B8")
    wall = "#768A75"
    roof = "#3E524C"
    h.box("Stone plinth", (8760, 6750, 465), (0, 0, 0), "#7B796A", "concrete")
    h.box("Cottage walls", (8500, 6500, 2890), (0, 0, 460), wall)
    h.gable(4250, 6500, 3350, 2250, wall, roof)
    h.box("Covered porch deck", (6500, 1720, 465), (0, -4080, 0), "#887C63", "concrete")
    for x in (-2810, 2810):
        h.box("Pier", (540, 540, 780), (x, -4740, 460), "#85816D", "concrete")
        post = s3d.cone("Tapered porch post", 385, 1420, d2=235)
        s3d.transform(post, x, -4740, 1200)
        s3d.material(post, "pine", color=h.trim)
        h.parts.append(post)
    h.box("Porch beam", (6590, 240, 225), (0, -4740, 2540), h.trim)
    h.box("Porch canopy", (6940, 2190, 180), (0, -4070, 2860), roof, "painted_metal")
    h.door(0, -3250, 465, 1050, "#A65B40")
    for x in (-2090, 2090):
        h.window(x, -3250, 1140, 1470, 1060)
    h.window(0, -3250, 3570, 1230, 640)
    for z in range(710, 3300, 248):
        h.box("Clapboard lip", (8500, 38, 25), (0, -3260, z), "#697C66")
    h.stairs(0, -4920, 2220, 3, "#887C63")
    h.box("Chimney", (740, 770, 2350), (2580, 850, 2970), "#9B6451", "concrete")
    h.box("Chimney coping", (845, 890, 150), (2580, 850, 5320), "#C1AC97", "concrete")
    return h.assemble()


def brick_rowhouse():
    h = HouseParts("brick_rowhouse", "#E0CFAB")
    brick = "#9E5C4B"
    h.box("Foundation", (5700, 8700, 780), (0, 0, 0), "#86776D", "concrete")
    h.box("Brick shell", (5500, 8500, 6550), (0, 0, 730), brick, "concrete")
    for z in range(925, 7270, 185):
        h.box("Brick bed joint", (5500, 26, 14), (0, -4254, z), "#B17964", "concrete")
    h.box("Stone belt course", (5670, 340, 165), (0, -4190, 3590), h.trim, "concrete")
    h.box("Lower cornice", (5740, 380, 200), (0, -4180, 6640), "#C0AC88", "concrete")
    h.box("Crown cornice", (5880, 520, 160), (0, -4170, 7200), h.trim, "concrete")
    for x in range(-2420, 2500, 440):
        h.box("Cornice bracket", (125, 230, 245), (x, -4400, 6750), h.trim)
    h.door(-1520, -4250, 775, 1010, "#38544E")
    for x in (-155, 1540):
        h.window(x, -4250, 1390, 970, 1450)
    for x in (-1650, 0, 1650):
        h.window(x, -4250, 4330, 1000, 1530)
        h.box("Stone lintel", (1310, 210, 205), (x, -4330, 5950), h.trim, "concrete")
    h.box("Stoop landing", (1600, 580, 775), (-1520, -4555, 0), "#95877A", "concrete")
    h.stairs(-1520, -4840, 1600, 5, "#95877A")
    for x in (-2310, -730):
        h.box("Landing pier", (170, 170, 870), (x, -4680, 680), "#565853", "painted_metal")
        h.box("Stoop pier", (150, 150, 850), (x, -6460, 80), "#565853", "painted_metal")
        rail = s3d.box("Sloping handrail", 72, 1880, 66)
        s3d.transform(rail, x, -5570, 1200, rx=degrees(atan2(620, 1780)))
        s3d.material(rail, "painted_metal", color="#565853")
        h.parts.append(rail)
    return h.assemble()


def alpine_a_frame():
    h = HouseParts("alpine_a_frame", "#D6C2A2")
    h.box("Raised stone base", (6890, 7550, 405), (0, 0, 0), "#74736A", "concrete")
    h.box("Low wall base", (6500, 7200, 340), (0, 0, 405), "#946647")
    h.gable(3250, 7200, 745, 6160, "#A57552", "#394B50")
    h.box("Front deck", (5660, 2050, 405), (0, -4470, 0), "#896B4D")
    h.stairs(0, -5500, 1860, 3, "#896B4D")
    for x in (-2580, 2580):
        h.box("Deck rail", (110, 1760, 110), (x, -4450, 1320), h.trim)
        for y in (-5160, -4500, -3770):
            h.box("Deck baluster", (100, 100, 960), (x, y, 405), h.trim)
    h.door(0, -3600, 405, 1010, "#67544B")
    for x in (-1320, 1320):
        h.window(x, -3600, 1030, 770, 1330)
    h.window(0, -3600, 2900, 1710, 1430)
    h.window(0, -3600, 4520, 715, 790)
    for z in range(850, 6300, 260):
        width = 6500 * (1 - (z - 745) / 6160)
        h.box("Gable siding", (width, 35, 24), (0, -3611, z), "#906244")
    h.box("Stove flue", (395, 395, 2660), (1350, 1180, 3270), "#4B4F4C", "painted_metal")
    h.box("Flue cap", (590, 590, 125), (1350, 1180, 5930), "#353B39", "painted_metal")
    return h.assemble()


NEW_HOUSES = {"craftsman_cottage": craftsman_cottage, "brick_rowhouse": brick_rowhouse,
              "alpine_a_frame": alpine_a_frame}


def town_building(name, width, depth, floors, wall, trim, roof, use):
    h = HouseParts(name, trim)
    front = -depth / 2
    top = 365 + floors * 2470
    h.box("Stone foundation", (width + 180, depth + 180, 380), (0, 0, 0), "#82786E", "concrete")
    h.box("Main building", (width, depth, top - 365), (0, 0, 365), wall, "concrete")
    if use == "house":
        h.gable(width / 2, depth, top, 1700, wall, roof)
        h.window(0, front, top + 210, 980, 680)
        h.box("Chimney", (660, 710, 2150), (width * .24, 500, top), "#805B4C", "concrete")
    else:
        h.box("Flat roof", (width + 230, depth + 230, 180), (0, 0, top - 10), roof, "painted_metal")
        for sign in (-1, 1):
            h.box("Side parapet", (180, depth + 180, 420), (sign * width / 2, 0, top + 155), wall, "concrete")
            h.box("Parapet coping", (242, depth + 210, 85),
                  (sign * width / 2, 0, top + 545), trim, "concrete")
        h.box("Front parapet", (width + 175, 208, 404), (0, front, top + 145), wall, "concrete")
        h.box("Front coping", (width + 220, 290, 100), (0, front, top + 540), trim, "concrete")
    for floor in range(floors):
        z = 365 + floor * 2470
        h.box("Masonry band", (width + 50, 117, 112), (0, front, z + 2280), trim, "concrete")
        if floor > 0 or use == "house":
            columns = (-.30, 0, .30) if floor else (-.30, .30)
            for col in columns:
                h.window(width * col, front, z + 540, 1110, 1190)
        # Side windows are visible from the intersection looking along the block.
        for sign in (-1, 1):
            for y in (-depth * .26, depth * .26):
                mark = len(h.parts)
                h.window(y * sign, -width / 2, z + 580, 920, 1100)
                s3d.transform(h.parts[mark:], 0, 0, 0, rz=sign * 90)
    if use == "house":
        h.door(0, front, 370, 1000, roof)
        h.stairs(0, front - 90, 2400, 2, "#A1907B")
        h.box("Entry canopy", (2290, 1040, 185), (0, front - 390, 2610), roof, "painted_metal")
    else:
        h.door(-width * .32, front, 365, 1110, roof)
        h.stairs(-width * .32, front - 60, 1600, 2, "#887D6D")
        for col in (-.04, .22):
            h.window(width * col, front, 630, width * .215, 1420)
        h.box("Ground floor fascia", (width - 360, 245, 470), (0, front - 98, 2550), roof, "painted_metal")
        h.box("Ground floor canopy", (width - 270, 1050, 145),
              (0, front - 485, 2475), trim, "painted_metal")
    return h.assemble()


def bay_house():
    home = HouseParts("bay_window_house", "#EAD9B8")
    wall, roof = "#758C88", "#4A5455"
    home.box("Foundation", (5920, 6920, 432), (0, 0, 0), "#8B857A", "concrete")
    home.box("Clapboard house", (5730, 6690, 4710), (0, 0, 425), wall)
    home.gable(2865, 6690, 5135, 2130, wall, roof)
    home.box("Bay projection", (2160, 755, 4140), (1020, -3590, 425), "#829894")
    home.box("Bay cap", (2310, 877, 175), (1020, -3680, 4563), roof, "painted_metal")
    for z in (1035, 3250):
        for x in (395, 1020, 1645):
            home.window(x, -3970, z, 390, 1120)
        home.box("Bay band", (2240, 842, 100), (1020, -3665, z - 135), home.trim)
    home.door(-1710, -3345, 425, 990, "#624833")
    home.window(-1710, -3345, 3260, 955, 1130)
    home.window(0, -3345, 5420, 890, 752)
    home.stairs(-1710, -3410, 1550, 3, "#AA9C87")
    return home.assemble()


STREET_BUILDINGS = {
    "bay_window_house": bay_house,
    "ochre_townhouse": lambda: town_building("ochre_townhouse", 6110, 7040, 2, "#AD8964",
                                            "#E5CFAC", "#5A5754", "house"),
    "red_gable_house": lambda: town_building("red_gable_house", 6840, 7540, 2, "#9E6353",
                                             "#E3C9A3", "#4A4F4F", "house"),
    "corner_grocery": lambda: town_building("corner_grocery", 7020, 8630, 2, "#7F8F7C",
                                            "#CFBD97", "#3F5C54", "storefront"),
    "brick_walkup": lambda: town_building("brick_walkup", 7670, 8510, 3, "#865E51",
                                          "#BFA988", "#53504A", "storefront"),
}


if __name__=="__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--new", action="store_true", help="Export the cottage, rowhouse and A-frame.")
    group.add_argument("--street", action="store_true", help="Export the street expansion.")
    args = parser.parse_args()
    OUT.mkdir(exist_ok=True)
    styles=[
      ("blue_family_bungalow","#d7e8ef","#f8f3e7","#ad4930","#d7a666","#387ba4",0),
      ("white_colonial","#e8e5dc","#fffaf0","#303844","#7a5140","#6d9eae",1),
      ("sage_rental_bungalow","#8b9b82","#e9e3d4","#414a4c","#6a4937","#557f93",2),
    ]
    inv=[]
    for name,body,trim,roof,door,window,style in styles:
        if not args.new and not args.street:
            s3d.empty_scene()
            s3d.export(house(name,body,trim,roof,door,window,style), OUT / f"{name}.glb")
    builders = STREET_BUILDINGS if args.street else NEW_HOUSES if args.new else NEW_HOUSES | STREET_BUILDINGS
    for name, builder in builders.items():
        s3d.empty_scene()
        s3d.export(builder(), OUT / f"{name}.glb")
    for name in [style[0] for style in styles] + list(NEW_HOUSES) + list(STREET_BUILDINGS):
        path = OUT / f"{name}.glb"
        if path.exists():
            inv.append({"name":name,"asset":path.name,"format":"glb","generator":"Sand3D"})
    (OUT/"inventory.json").write_text(json.dumps(inv,indent=2)+"\n",encoding="utf-8")
    print("Sand3D houses are in", OUT)

