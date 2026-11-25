"""Stage the room, westbound road, and Last Stop Fuel for the Godot Reel."""
from pathlib import Path
from math import radians
from random import Random

import bpy

HERE = Path(__file__).resolve().parent
ASSETS = HERE.parents[1] / "assets"
KIT = ASSETS / "late_morning_02"
bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
rng = Random(18)
materials = {}
prototypes = {}


def color(value):
    if value not in materials:
        mat = bpy.data.materials.new(value)
        rgba = tuple(int(value[i:i+2], 16) / 255 for i in (0, 2, 4)) + (1,)
        mat.diffuse_color = rgba
        mat.use_nodes = True
        mat.node_tree.nodes.get("Principled BSDF").inputs["Base Color"].default_value = rgba
        materials[value] = mat
    return materials[value]


def box(name, p, dims, hex_color, rotation=0):
    bpy.ops.mesh.primitive_cube_add(size=1, location=p)
    ob = bpy.context.object
    ob.name = name
    ob.dimensions = dims
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    ob.rotation_euler.z = radians(rotation)
    ob.data.materials.append(color(hex_color))
    return ob


def pivot(name, p=(0, 0, 0), turn=0):
    anchor = bpy.data.objects.new(name, None)
    scene.collection.objects.link(anchor)
    anchor.location = p
    anchor.rotation_euler.z = radians(turn)
    return anchor


def imported(path):
    before = set(scene.objects)
    bpy.ops.import_scene.gltf(filepath=str(path))
    return set(scene.objects) - before


def place(relative, p, turn=0, name=None, base=KIT, scale=1):
    path = base / (relative + ".glb")
    anchor = pivot(name or Path(relative).stem, p, turn)
    if path in prototypes:
        copies = {ob: ob.copy() for ob in prototypes[path]}
        for original, copy in copies.items():
            scene.collection.objects.link(copy)
            copy.parent = copies.get(original.parent, anchor)
            copy.matrix_parent_inverse = original.matrix_parent_inverse.copy()
            copy.matrix_basis = original.matrix_basis.copy()
    else:
        objects = imported(path)
        prototypes[path] = objects
        for ob in objects:
            if ob.parent is None:
                ob.parent = anchor
    anchor.scale = (scale,) * 3
    return anchor


def child_asset(parent, relative, p, turn=0, name=None):
    child = place(relative, p, turn, name)
    child.parent = parent
    return child


# The borrowed house interior is a cutaway set, separate from street geometry.
box("Room floor", (0, 0, -.10), (7.1, 7.35, .2), "987D5B")
for i in range(24):
    box("Floorboard seam", (0, -3.45 + i*.3, .001), (7.08, .007, .003), "6D6453")
box("Bedroom wall", (-3.50, 0, 1.39), (.13, 7.4, 2.78), "B4A990")
box("Bed head wall", (0, -3.58, 1.39), (7.1, .13, 2.78), "9FA892")
box("Window sill wall", (0, 3.56, .47), (7.12, .15, .94), "B8B29C")
box("Window top wall", (0, 3.56, 2.59), (7.12, .15, .40), "B8B29C")
for x in (-2.47, 2.47):
    box("Window side wall", (x, 3.56, 1.75), (2.13,.15,1.63), "B8B29C")
box("Window ledge", (0, 3.47, .95), (3.05, .30, .091), "DFD7BD")
box("Window mullion", (0, 3.54, 1.71), (.061, .149, 1.64), "DDD2B7")
box("Hall side wall", (3.52, .59, 1.39), (.13, 5.81, 2.78), "BAB39D")
box("Ceiling", (0,0,2.84), (7.21,7.31,.12), "E0D5BE")
place("interiors/bedroom/double_bed", (-1.79,-2.04,0), 180, base=ASSETS)
place("interiors/bedroom/nightstand", (-.72,-2.64,0), 180, base=ASSETS)
place("interiors/lighting/table_lamp", (-.62,-2.74,.55), base=ASSETS)
place("interiors/living/area_rug", (-1.55,-1.14,.011), base=ASSETS)
place("interiors/kitchen/refrigerator", (2.86,2.77,0), 0, base=ASSETS)
place("interiors/kitchen/kitchen_sink", (1.90,2.81,0), 0, base=ASSETS)
place("interiors/kitchen/base_cabinet", (.94,2.81,0), 0, base=ASSETS)
place("interiors/kitchen/dining_table", (1.73,.90,0), 0, base=ASSETS)
place("interiors/kitchen/dining_chair", (2.17,.17,0), 180, base=ASSETS)
place("interiors/architecture/interior_door", (2.15,-3.46,0), 180, base=ASSETS)
place("interiors/decor/curtain_pair", (0,3.35,.94), 180, base=ASSETS, scale=1.44)
place("props/clock_0712", (-.81,-2.53,.548), 180, "MorningClock")
place("props/clock_1212", (1.85,2.72,.919), 0, "NoonClock")
place("props/open_road_atlas", (1.57,.86,.76), 0, "KitchenAtlas")
place("props/sealed_water_bottle", (1.875,2.76,.79), 0, "FillBottle")
place("props/tin_rations",(2.10,.96,.758),0)
place("props/truck_keys",(1.355,.575,.761),-14,"TruckKeys")
box("WaterStream", (1.876,2.757,1.004), (.016,.014,.163), "AACAD0")
place("background/plant_horizon_silhouette", (-15,154,-2.6), 0, "WindowPlant", scale=.19)
box("Distant hill under plant", (-6,124,-2.75),(85,120,.28),"737E67")
for i in range(6):
    house = "borrowed_split_level" if i%2 else "cedar_roadside_bungalow"
    place("houses/"+house, (-20+8.5*i, 48+i%2*9, -.15), -6, scale=.8)

# Residential departure and highway share a continuous westbound roadway.
box("Road country terrain", (0,211,-.25), (112,256,.5), "818865")
for y in range(104,321,24):
    place("highway/two_lane_highway_24m", (0,y,0))
for y in range(112,265,16):
    place("highway/highway_guardrail_8m", (-4.95,y,.055))
    if y > 141:
        place("roadside/roadside_split_rail_fence", (6.4,y+4,0), scale=1)
for y in range(102,305,23):
    side = -1 if y % 2 == 0 else 1
    place("highway/roadside_utility_pole", (side*6.9,y,0))
for y in (99,111,124,137,153):
    for side in (-1,1):
        if y == 111 and side == 1:
            continue
        house = ["borrowed_split_level","cedar_roadside_bungalow"][int(y%2==0)]
        place("houses/"+house, (side*rng.uniform(12,15),y,0), 90*side, scale=rng.uniform(.82,1.03))
        place("roadside/rural_mailbox_pair", (side*6.5,y-3,0), 90*side)
place("houses/borrowed_split_level", (14.8,109.5,0),90)
place("highway/blackout_traffic_signal", (-4.92,116.8,.13),0,"GridSignal")
place("highway/overhead_west_route_sign", (0,167,.12), 0)
place("highway/county_road_signpost", (5.7,231.1,.12), -11)
for i,y in enumerate((103,116,126,138,149,158,178,190,200,213,229,240,274)):
    style = ["abandoned_tan_sedan","abandoned_olive_wagon","parked_delivery_van","unhitched_utility_trailer"][i%4]
    x = (-1 if i%2 else 1)*rng.uniform(4.50,4.87)
    place("roadside/"+style,(x,y,.155),rng.choice((0,0,180))+rng.uniform(-12,12))
for i in range(33):
    y = 95+i*6.18
    side = 1 if i%3 else -1
    place("roadside/scattered_roadside_grass",(side*rng.uniform(5.5,7.2),y,0),rng.uniform(0,360))
for i in range(19):
    side = -1 if i%2 else 1
    y = 130+i*7.3
    if side > 0 and 238 < y < 282:
        continue
    model = ["round_oak","layered_pine","silver_birch","autumn_maple"][i%4]
    place("trees/"+model,(side*rng.uniform(10.5,21),y,0),rng.uniform(0,360),base=ASSETS,scale=rng.uniform(.62,.96))
for y in (198.0,204.0,210.0):
    place("roadside/weathered_road_barrier", (-3.53,y,.155), 0)
    place("roadside/roadwork_drum", (-2.82,y+1.6,.155))
place("background/plant_horizon_silhouette", (-55,104,0), 17, "PlantBehindTown", scale=.51)

# Station forecourt and furnished shop shell with a clear approach to the door.
box("Station forecourt", (14.0,254.7,-.055), (27.5,27,.11), "A9A393")
box("Forecourt driveway", (6.7,249.2,.046), (8.4,6.4,.092), "89877D")
place("station/fuel_canopy",(13,253,0))
place("station/last_stop_price_sign",(5.65,244.7,0),0)
place("station/last_stop_shop_shell",(15.6,263,0))
place("station/shop_glass_door",(15.16,259.85,.139),-15,"ShopDoor")
place("station/shop_door_bell",(15.46,260.07,2.224),180)
for x in (11.3,14.2,17.3):
    place("station/dark_fuel_dispenser",(x,253.55,0))
    place("station/pump_hose",(x,253.55,0))
    place("station/fuel_nozzle",(x+.452,253.378,.973),0,"HandNozzle" if x==14.2 else None)
    place("station/yellow_pump_bollard",(x,254.39,0))
place("station/canopy_trash_station",(17.96,252.66,0))
place("station/station_checkout_counter",(17.50,263.85,.139),0)
for x in (13.2,15.03):
    place("station/dead_drink_cooler",(x,265.61,.148))
place("station/station_aisle_shelf",(12.9,262.36,.148),90)
place("station/station_aisle_shelf",(18.17,261.83,.148),-90)
place("station/chest_freezer",(11.88,264.34,.148),90)
place("station/coffee_service_station",(19.46,264.9,.148),-90)
place("station/entry_promo_stand",(14.03,260.34,.148))
place("props/open_road_atlas",(17.29,263.62,1.172),-9,"CounterMap")
place("props/noon_note",(17.31,263.54,1.191),-9,"CounterNote")
for x in (16.78,16.88):
    place("props/sealed_water_bottle",(x,263.76,1.17))
place("roadside/abandoned_olive_wagon",(23.2,251.8,0),-26)
place("roadside/parked_delivery_van",(22.8,260,0),-6)
place("roadside/unhitched_utility_trailer",(20.2,247,0),38)

truck = place("vehicle/fathers_pickup",(0,0,0),0,"WestboundPickup")
for axle, y in (("Front", -1.64), ("Rear", 1.636)):
    for side, x in (("left", -.895), ("right", .895)):
        wheel = pivot("Wheel" + axle[0] + side[0].upper(), (x, y, .393))
        wheel.parent = truck
        bpy.context.view_layer.update()
        for suffix in ("tire", "wheel hub"):
            part = bpy.data.objects[f"{axle} {side} {suffix}"]
            transform = part.matrix_world.copy()
            part.parent = wheel
            part.matrix_world = transform
child_asset(truck,"vehicle/pickup_passenger_door",(.852,-.771,.665),0,"PassengerDoor")
child_asset(truck,"vehicle/pickup_low_fuel_gauge",(.36,-.507,1.207),180,"DashboardGauge")
child_asset(truck,"props/pickup_water_jug",(-.37,1.35,.735),0,"CargoWaterA")
child_asset(truck,"props/pickup_water_jug",(-.12,1.35,.735),0,"CargoWaterB")
child_asset(truck,"props/tin_rations",(-.27,1.71,.735),0)

# Reuse the existing dog's head, body, and tail. Legs are rigged by the Godot scene.
old_set = HERE.parent / "late_morning" / "motion" / "set.glb"
objects = imported(old_set)
source_dog = next(ob for ob in objects if ob.name == "DogRig")
keep = {source_dog, *source_dog.children_recursive}
for ob in objects - keep:
    bpy.data.objects.remove(ob, do_unlink=True)
source_dog.parent = pivot("DanielDog")
source_dog.location = (0,0,0)
for i in range(15):
    place("roadside/loose_leaf", (0,0,0), name=f"WindLeaf{i:02d}")
for i in range(3):
    place("roadside/roadside_lookout_bird", (0,0,0), name=f"RoadBird{i:02d}")
place("roadside/loose_newspaper",(0,0,0),name="WindPaper")
bpy.ops.export_scene.gltf(filepath=str(HERE / "motion" / "set.glb"), export_format="GLB")
