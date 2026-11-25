"""Replace Last Stop Fuel with a detailed, open-layout Sand3D station kit."""
import json
from pathlib import Path

import sand3d as s3d

from build_interiors import Model
from build_late_morning_02 import label, parked_hose, station_hinged_door, nozzle

KIT = Path(__file__).with_name("late_morning_02")
TEAL, DARK, LIGHT = "#496D66", "#2D403E", "#D7DDC3"
CREAM, RED, GRAY = "#E1CFAB", "#AF6547", "#A9A89D"
STEEL, GLASS, INK = "#878C84", "#8AABA9", "#293637"
TIMBER, CONCRETE, YELLOW = "#A68861", "#ADA797", "#C4A05E"


def shop():
    m = Model("last_stop_shop_shell")
    m.box("Shop floor slab", (9290,6420,139),(0,0,0),CONCRETE,"concrete")
    for row in range(12):
        for column in range(17):
            x = (column - 8) * 535
            y = (row - 5.5) * 517
            tint = ("#D3CBB4","#C9C5AE","#D7D0BD")[(row + 2*column)%3]
            m.box("Ceramic floor tile",(531,513,8),(x,y,138),tint,"ceramic")
    m.box("Rear brick", (9050,180,3090),(0,3077,138),CREAM,"concrete")
    for x in (-4475,4475):
        m.box("Masonry side wall",(159,6330,3090),(x,0,138),CREAM,"concrete")
        m.box("Side wall skirting",(43,6090,126),(x*.977,0,148),TIMBER)
        for y in (-2150,-920,310,1540,2770):
            m.box("Exterior pilaster",(89,121,2440),(x*1.028,y,138),CONCRETE,"concrete")
    m.box("Roof deck",(9330,6580,200),(0,0,3180),DARK,"painted_metal")
    m.box("Upper parapet",(9410,193,312),(0,-3240,3240),TEAL,"painted_metal")
    m.box("Parapet crown",(9440,235,74),(0,-3240,3516),LIGHT,"painted_metal")
    m.box("Front fascia",(9310,258,494),(0,-3195,2530),TEAL,"painted_metal")
    m.box("Fascia accent stripe",(9310,22,49),(0,-3332,2530),RED,"painted_metal")
    m.box("Entrance canopy",(9320,940,94),(0,-3425,2440),DARK,"painted_metal")
    label(m,"LAST STOP FUEL",342,(0,-3339,2780))
    for x in (-4370,4370):
        m.box("Front masonry pier",(245,277,2330),(x,-3088,138),CONCRETE,"concrete")
    for center in (-2530,2530):
        # The windows span a real opening. Thin glass highlights leave most of
        # the interior readable even with a compatibility renderer.
        m.box("Knee wall",(3550,211,573),(center,-3135,138),GRAY,"concrete")
        m.box("Window sill",(3590,340,78),(center,-3152,699),DARK,"painted_metal")
        m.box("Window head",(3540,132,79),(center,-3159,2317),DARK,"painted_metal")
        for x in (center-1771,center-590,center+590,center+1771):
            m.box("Window mullion",(60,103,1550),(x,-3159,772),DARK,"painted_metal")
        for x in (center-1180,center,center+1180):
            m.box("Transom rail",(1122,55,46),(x,-3176,2003),DARK,"painted_metal")
            m.box("Glass reflection strip",(34,7,1150),(x-350,-3129,794),"#BED0C2","plastic",(0,-18,0))
        m.box("Fascia return",(3550,214,191),(center,-3128,2346),CREAM,"concrete")
    # Opening edges stay outside the actor's path at the centre of the facade.
    for x in (-748,748):
        m.box("Entrance jamb",(93,113,2310),(x,-3160,138),DARK,"painted_metal")
    m.box("Entrance lintel",(1559,113,102),(0,-3160,2402),DARK,"painted_metal")
    m.box("Threshold strip",(1450,182,22),(0,-3190,138),STEEL,"brushed_steel")
    m.box("Central rubber mat",(1180,808,15),(0,-2580,147),INK,"rubber")
    for y in (-2140,-820,500,1820):
        m.box("Ceiling beam",(8720,140,137),(0,y,3035),GRAY,"painted_metal")
    for y in (-1820,300,2300):
        for x in (-2220,2220):
            m.box("Unpowered fluorescent fixture",(310,1230,54),(x,y,2962),STEEL,"painted_metal")
            m.box("Translucent lens",(244,1120,26),(x,y,2941),LIGHT,"plastic")
    return m


def canopy():
    m = Model("fuel_canopy")
    for x in (-4590,4590):
        for y in (-1900,1900):
            m.box("Concrete column base",(498,492,281),(x,y,0),CONCRETE,"concrete")
            m.box("Steel canopy upright",(242,228,4020),(x,y,280),CREAM,"painted_metal")
            m.box("Lower protective boot",(298,299,886),(x,y,281),DARK,"painted_metal")
            m.box("Rubber corner bumper",(331,333,79),(x,y,731),YELLOW,"rubber")
            m.box("Column crosshead",(571,409,174),(x,y,4100),DARK,"painted_metal")
    m.box("Ribbed soffit panel",(11230,6260,140),(0,0,4270),LIGHT,"painted_metal")
    m.box("Parapet canopy roof",(11620,6510,413),(0,0,4404),TEAL,"painted_metal")
    for y in (-3258,3258):
        m.box("Cream fascia stripe",(11600,55,116),(0,y,4480),CREAM,"painted_metal")
        m.box("Terracotta fascia stripe",(11600,57,51),(0,y,4434),RED,"painted_metal")
    label(m,"LAST STOP",215,(0,-3290,4670))
    for x in (-3520,0,3520):
        for y in (-1370,1370):
            m.box("Canopy fixture base",(352,703,54),(x,y,4222),STEEL,"painted_metal")
            m.box("Dead tube lens",(263,612,38),(x,y,4190),LIGHT,"plastic")
    return m


def pump():
    m = Model("dark_fuel_dispenser")
    m.box("Concrete island",(1230,1490,153),(0,0,0),CONCRETE,"concrete")
    for x in (-543,543):
        m.box("Island curb stripe",(77,1409,34),(x,0,119),YELLOW,"painted_metal")
    m.box("Gray pump body",(762,464,1390),(0,0,151),GRAY,"painted_metal")
    m.box("Painted lower panel",(715,27,558),(0,-241,277),TEAL,"painted_metal")
    m.box("Black upper fascia",(715,64,591),(0,-233,847),INK,"plastic")
    m.box("Dead LCD",(433,12,145),(0,-271,1168),"#343D3C","plastic")
    m.box("Card reader slot",(99,25,48),(230,-271,1083),STEEL,"brushed_steel")
    for x in (-152,0,152):
        m.box("Grade button surround",(112,24,83),(x,-272,942),GRAY,"brushed_steel")
        m.box("Grade button",(80,18,60),(x,-285,955),YELLOW,"plastic")
    label(m,"87",35,(-152,-297,987),INK)
    label(m,"89",35,(0,-297,987),INK)
    label(m,"91",35,(152,-297,987),INK)
    m.box("Cap band",(829,497,176),(0,0,1385),RED,"painted_metal")
    label(m,"REGULAR",109,(0,-251,1477))
    m.box("Nozzle cradle",(131,88,211),(405,-83,876),INK,"plastic")
    m.box("Hose coupler",(94,105,103),(408,74,1305),STEEL,"brushed_steel")
    return m


def price_sign():
    m = Model("last_stop_price_sign")
    m.box("Sign footing",(1080,843,243),(0,0,0),CONCRETE,"concrete")
    for x in (-719,719):
        m.box("Sign post",(188,216,5080),(x,0,241),DARK,"painted_metal")
    m.box("Main sign cabinet",(2940,304,1490),(0,0,3460),TEAL,"painted_metal")
    m.box("Price display board",(2630,29,627),(0,-165,3605),INK,"painted_metal")
    m.box("Sign border strip",(2950,43,81),(0,-165,4854),RED,"painted_metal")
    label(m,"LAST STOP FUEL",273,(0,-169,4535))
    label(m,"REGULAR  3.49",239,(0,-189,3913),"#E3CBA8")
    return m


def drink(m, x, y, z, tint, index):
    if index%3 == 0:
        m.round("Soda can",52,89,(x,y,z),tint,"painted_metal")
        m.round("Aluminum lid",53,6,(x,y,z+86),STEEL,"brushed_steel")
    else:
        m.round("Bottle body",51,103,(x,y,z),tint,"plastic")
        m.round("Bottle shoulder",51,23,(x,y,z+101),tint,"plastic",26)
        m.round("Sealed cap",28,11,(x,y,z+123),CREAM,"plastic")
        m.round("Wrap label",52,26,(x,y,z+38),LIGHT,"plastic")


def cooler():
    m = Model("dead_drink_cooler")
    m.box("Louvered kick plate",(1730,691,198),(0,0,0),DARK,"painted_metal")
    for x in range(-715,716,112):
        m.box("Kick plate vent",(61,8,27),(x,-351,81),GRAY,"painted_metal")
    m.box("Back of cooler cabinet",(1710,70,1830),(0,300,183),DARK,"painted_metal")
    m.box("Upper cooler canopy",(1749,700,258),(0,0,1945),TEAL,"painted_metal")
    label(m,"COLD DRINKS",127,(0,-354,2086))
    for x in (-813,0,813):
        m.box("Door stile",(89,671,1776),(x,0,179),STEEL,"brushed_steel")
        m.box("Gasket",(22,49,1702),(x,-352,209),INK,"rubber")
    for z in (199,586,974,1362,1750,1935):
        m.box("Shelf deck",(1530,542,37),(0,-15,z),GRAY,"painted_metal")
        m.box("Shelf rail",(1525,50,44),(0,-291,z),STEEL,"brushed_steel")
    for row,z in enumerate((626,1014,1402)):
        for i,x in enumerate((-694,-569,-439,-309,88,216,344,475,603,721)):
            if (i+row)%4 != 0:
                drink(m,x,-218+((i+row)%3)*101,z,(RED,TEAL,"#BE9C5B","#6F9097")[i%4],i+row)
    for x in (-399,398):
        m.box("Door top rail",(762,39,57),(x,-359,1880),STEEL,"brushed_steel")
        m.box("Door lower rail",(762,39,48),(x,-359,216),STEEL,"brushed_steel")
        m.box("Door pull",(36,85,317),(x+(304 if x<0 else -305),-396,873),INK,"rubber")
        m.box("Subtle glass glint",(22,4,821),(x-220,-359,1030),"#82959A","plastic",(0,-13,0))
    return m


def freezer():
    m = Model("chest_freezer")
    m.box("Commercial freezer body",(1520,696,829),(0,0,0),LIGHT,"painted_metal")
    m.box("Front bumper kick plate",(1542,700,114),(0,0,0),DARK,"rubber")
    m.box("Top aluminum ledge",(1568,736,77),(0,0,811),STEEL,"brushed_steel")
    for x in (-381,381):
        m.box("Sliding top panel",(732,643,17),(x,0,884),GLASS,"plastic")
        m.box("Lid pull",(126,46,27),(x,-202,900),INK,"plastic")
    m.box("Old freezer sign",(713,17,259),(0,-355,368),TEAL,"painted_metal")
    label(m,"ICE",158,(0,-365,499),CREAM)
    return m


def shelf():
    m = Model("station_aisle_shelf")
    m.box("Steel shelving back",(1548,69,1533),(0,169,78),DARK,"painted_metal")
    for x in (-755,755):
        m.box("Steel corner upright",(54,438,1631),(x,0,0),TEAL,"painted_metal")
    for z in (106,438,759,1081,1433):
        m.box("Powder coated shelf",(1454,419,36),(0,-18,z),GRAY,"painted_metal")
        m.box("Ticket strip",(1450,21,42),(0,-231,z),CREAM,"plastic")
    for row,z in enumerate((477,798,1120)):
        for i,x in enumerate((-653,-505,-355,-203,-53,99,251,401,550,665)):
            if (i+row*2)%5 in (0,3):
                continue
            tint=(TEAL,RED,"#BEA46C",LIGHT)[(i+row)%4]
            if row==0 or i%3==0:
                drink(m,x,-95,z,tint,i+row)
            else:
                m.box("Pantry carton",(104,116,168+(i%4)*12),(x,-95,z),tint,"plastic")
                m.box("Printed product stripe",(90,2,32),(x,-154,z+94),CREAM,"plastic")
    m.box("Shelf category header",(1545,35,185),(0,-234,1446),TEAL,"painted_metal")
    label(m,"PANTRY",109,(0,-255,1534))
    return m


def counter():
    m = Model("station_checkout_counter")
    m.box("Setback toe kick",(1975,711,95),(0,0,0),DARK,"painted_metal")
    m.box("Checkout cabinet",(2030,760,871),(0,0,93),TIMBER)
    for x in range(-900,901,120):
        m.box("Fluted front",(49,25,704),(x,-387,142),"#8D7559")
    m.box("Uncluttered laminate top",(2150,810,65),(0,0,963),"#D1B485","plastic")
    m.box("Steel counter edge",(2150,28,66),(0,-410,963),STEEL,"brushed_steel")
    m.box("Register cash drawer",(411,328,137),(635,55,1028),INK,"plastic")
    m.box("Register screen",(319,61,185),(635,155,1163),DARK,"plastic")
    m.box("Dark display inset",(279,9,143),(635,121,1182),"#455559","plastic")
    for i in range(5):
        m.box("Keyboard key",(29,34,7),(554+i*40,-25,1167),GRAY,"plastic")
    return m


def accessories():
    m=Model("coffee_service_station")
    m.box("Coffee workbench",(1410,560,851),(0,0,0),TIMBER)
    m.box("Countertop",(1490,602,65),(0,0,845),DARK,"plastic")
    m.box("Coffee maker",(340,284,544),(-406,32,910),INK,"painted_metal")
    m.round("Glass coffee pot",181,164,(-406,-56,941),GLASS,"plastic")
    for i in range(4):
        m.round("Paper cup",78,112,(120+i*90,-30,908),CREAM,"plastic",92)
    yield m
    m=Model("entry_promo_stand")
    m.box("Sign base",(436,284,82),(0,0,0),DARK,"painted_metal")
    for x in (-158,158):
        m.box("Sign support",(26,43,994),(x,0,0),STEEL,"brushed_steel")
    m.box("Promotion board",(451,47,440),(0,0,699),RED,"painted_metal")
    label(m,"TRAVEL",96,(0,-27,963))
    label(m,"SUPPLIES",79,(0,-28,835))
    yield m
    m=Model("yellow_pump_bollard")
    m.round("Embedded steel post",157,980,(0,0,0),YELLOW,"painted_metal",119)
    m.round("Reflective warning band",151,83,(0,0,757),CREAM,"painted_metal")
    yield m
    m=Model("canopy_trash_station")
    m.box("Waste bin plinth",(378,379,54),(0,0,0),DARK,"plastic")
    m.box("Waste bin shell",(351,351,587),(0,0,51),TEAL,"plastic")
    m.box("Waste lid",(385,385,59),(0,0,627),DARK,"plastic")
    m.box("Waste opening",(173,4,71),(0,-195,516),INK,"plastic")
    yield m


def main():
    station = KIT / "station"
    s3d.empty_scene()
    models = [shop(),station_hinged_door(),canopy(),pump(),nozzle(),parked_hose(),price_sign(),
              counter(),shelf(),cooler(),freezer(),*accessories()]
    path = KIT / "inventory.json"
    old = json.loads(path.read_text(encoding="utf-8"))
    names = {m.name for m in models}
    inventory = [entry for entry in old if entry["name"] not in names]
    for model in models:
        file = station / f"{model.name}.glb"
        s3d.export(s3d.assembly(model.name,*model.parts),file)
        inventory.append({"name":model.name,"category":"station",
                          "asset":file.relative_to(KIT).as_posix(),"generator":"Sand3D"})
    path.write_text(json.dumps(inventory,indent=2)+"\n",encoding="utf-8")
    print(f"Rebuilt {len(models)} station modules. {len(inventory)} total models in the episode kit.")


if __name__=="__main__":
    main()
