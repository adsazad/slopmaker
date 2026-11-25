"""Stage and render the opening animatic using the existing Sand3D GLBs."""
import argparse
from pathlib import Path
from math import radians

import bpy
from mathutils import Vector

HERE = Path(__file__).resolve().parent
ASSETS = HERE.parents[1] / "assets"
SHOTS = HERE / "reel_shots"
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("shots", nargs="*", help="Render only named shots.")
parser.add_argument("--samples", type=int, default=5)
parser.add_argument("--export-world", action="store_true", help="Export the animated Reel set.")
args = parser.parse_args()

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.world = bpy.data.worlds.new("Morning sky")
scene.world.use_nodes = True
background = scene.world.node_tree.nodes.get("Background")
background.inputs["Color"].default_value = (.56, .71, .91, 1)
background.inputs["Strength"].default_value = .43
scene.render.engine = "CYCLES"
scene.cycles.samples = args.samples
scene.cycles.use_denoising = True
scene.cycles.max_bounces = 4
scene.cycles.diffuse_bounces = 2
scene.cycles.glossy_bounces = 2
scene.render.use_persistent_data = True
scene.render.resolution_x = 450
scene.render.resolution_y = 800
scene.render.resolution_percentage = 100
scene.view_settings.view_transform = "AgX"
scene.render.image_settings.file_format = "PNG"


def mat(name, color, rough=.75, emission=0):
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*color, 1)
    m.use_nodes = True
    node = m.node_tree.nodes.get("Principled BSDF")
    node.inputs["Base Color"].default_value = (*color, 1)
    node.inputs["Roughness"].default_value = rough
    if emission:
        node.inputs["Emission Color"].default_value = (*color, 1)
        node.inputs["Emission Strength"].default_value = emission
    return m


def box(name, p, size, material, bevel=0, angle=0):
    bpy.ops.mesh.primitive_cube_add(size=1, location=p)
    ob = bpy.context.object
    ob.name = name
    ob.dimensions = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    ob.rotation_euler.z = radians(angle)
    ob.data.materials.append(material)
    if bevel:
        edge = ob.modifiers.new("Soft edges", "BEVEL")
        edge.width = bevel
        edge.segments = 2
        ob.modifiers.new("Normals", "WEIGHTED_NORMAL")
    return ob


def cylinder(name, p, r, height, material, angle=(0, 0, 0), vertices=20):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=r, depth=height, location=p)
    ob = bpy.context.object
    ob.name = name
    ob.rotation_euler = tuple(radians(x) for x in angle)
    ob.data.materials.append(material)
    return ob


def glb(path, p, angle=0, scale=1):
    before = set(scene.objects)
    bpy.ops.import_scene.gltf(filepath=str(ASSETS / (path + ".glb")))
    pivot = bpy.data.objects.new(Path(path).stem, None)
    roots = [ob for ob in set(scene.objects) - before if ob.parent is None]
    scene.collection.objects.link(pivot)
    for ob in roots:
        ob.parent = pivot
    pivot.location = p
    pivot.rotation_euler.z = radians(angle)
    pivot.scale = (scale,) * 3


def text(name, value, p, size, material, angle=(0, 0, 0)):
    font = bpy.data.curves.new(name, "FONT")
    font.body = value
    font.align_x = "CENTER"
    font.align_y = "CENTER"
    font.size = size
    ob = bpy.data.objects.new(name, font)
    scene.collection.objects.link(ob)
    ob.location = p
    ob.rotation_euler = tuple(radians(x) for x in angle)
    ob.data.materials.append(material)


def rig(name, origin, names):
    parent = bpy.data.objects.new(name, None)
    scene.collection.objects.link(parent)
    parent.location = origin
    bpy.context.view_layer.update()
    for name in names:
        obj = bpy.data.objects[name]
        matrix = obj.matrix_world.copy()
        obj.parent = parent
        obj.matrix_world = matrix
    return parent


def tumbler(name, pos):
    # Revolve the base, outer wall, rim, and inner wall as one open vessel.
    from math import cos, sin, tau
    profile = [(0.001, 0), (.032, 0), (.037, .009), (.042, .111),
               (.040, .114), (.036, .111), (.031, .016), (.001, .016)]
    sides = 20
    vertices = [(r * cos(tau * i / sides), r * sin(tau * i / sides), z)
                for r, z in profile for i in range(sides)]
    faces = []
    for row in range(len(profile)):
        next_row = (row + 1) % len(profile)
        for i in range(sides):
            j = (i + 1) % sides
            faces.append((row * sides + i, row * sides + j, next_row * sides + j, next_row * sides + i))
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    cup = bpy.data.objects.new(name, mesh)
    scene.collection.objects.link(cup)
    cup.location = pos
    mesh.materials.append(glass)
    for poly in mesh.polygons:
        poly.use_smooth = True
    return cup


wall = mat("Faded sage plaster", (.39, .47, .43))
wood = mat("Old maple", (.29, .18, .105))
wood2 = mat("Lighter maple", (.35, .23, .15))
trim = mat("Ivory trim", (.69, .65, .54))
ink = mat("Charcoal", (.018, .027, .035))
screen = mat("Dim blue phone display", (.031, .083, .12), .38, .43)
white = mat("Pale lit letters", (.76, .88, 1), .4, 1.15)
glass = mat("Pale glazed tumbler", (.27, .53, .57), .17)
water = mat("Water on fabric", (.035, .085, .095), .17)
road = mat("Road gray", (.092, .103, .109))
walk = mat("Pavement", (.44, .43, .38))
earth = mat("Dry grass", (.20, .245, .15))
paint = mat("Crosswalk paint", (.68, .66, .58))
car_white = mat("Off-white car paint", (.81, .80, .74), .26)
car_window = mat("Tinted car windows", (.085, .16, .19), .22)
tire = mat("Rubber", (.028, .031, .031))
silver = mat("Brushed metal", (.43, .48, .51), .34)
signal_green = mat("Lit green lens", (.035, .72, .22), .32, 3)
signal_off = mat("Unlit signal lenses", (.12, .12, .075))
brick = mat("Bakery brick", (.32, .18, .126))
awning = mat("Canvas awning", (.36, .11, .075))


for i in range(18):
    box("Floorboard", (0, -2.80 + i * .31, -.035), (5.55, .306, .07), [wood, wood2][i % 2])
box("Bedroom left wall", (-2.80, -.10, 1.40), (.14, 5.55, 2.80), wall)
box("Bedroom right wall", (2.80, -.10, 1.40), (.14, 5.55, 2.80), wall)
box("Bedroom headboard wall", (0, -2.87, 1.40), (5.7, .13, 2.8), wall)
box("Bedroom ceiling", (0, -.10, 2.84), (5.7, 5.61, .12), trim)
box("Wall below window", (0, 2.62, .43), (5.6, .15, .86), wall)
box("Wall above window", (0, 2.62, 2.57), (5.6, .15, .46), wall)
for side in (-1, 1):
    box("Window surround wall", (side * 1.98, 2.62, 1.60), (1.65, .15, 1.48), wall)
    box("Window side casing", (side * 1.13, 2.54, 1.61), (.085, .15, 1.54), trim)
box("Deep windowsill", (0, 2.50, .88), (2.37, .34, .09), trim, .01)
box("Window top casing", (0, 2.54, 2.33), (2.34, .13, .08), trim)
box("Window mullion", (0, 2.55, 1.63), (.055, .09, 1.42), trim)
box("Baseboard", (-2.72, -.1, .06), (.04, 5.45, .12), trim)
glb("interiors/bedroom/double_bed", (0, -1.45, 0), 180)
glb("interiors/bedroom/nightstand", (-1.09, -2.14, 0), 180)
glb("interiors/lighting/table_lamp", (-1.23, -2.27, .545))
glb("interiors/living/area_rug", (-.36, -.79, .002))
glb("interiors/bedroom/dresser", (1.97, .75, 0), -90)
glb("interiors/decor/curtain_pair", (0, 2.35, .87), 180, 1.34)
glb("interiors/decor/potted_plant", (2.08, 1.69, 0))
glb("interiors/decor/framed_print", (-2.65, -.05, 1.22), 90)

phone = (-1.02, -2.02, .558)
box("Phone housing", phone, (.098, .174, .018), ink, .009)
box("Phone screen", (phone[0], phone[1], .569), (.087, .162, .004), screen, .007)
text("Time", "10:17", (phone[0], phone[1] - .025, .573), .033, white, (0, 0, 180))
text("Day", "WEDNESDAY", (phone[0], phone[1] + .005, .573), .010, white, (0, 0, 180))
text("Lock line", "—", (phone[0], phone[1] + .063, .573), .027, white, (0, 0, 180))
cylinder("Cup on rug", (-1.22, -1.49, .059), .043, .105, glass, (74, 0, -29))
cylinder("Small spill", (-1.16, -1.56, .017), .061, .004, water, vertices=9)
cylinder("Water drops", (-1.08, -1.62, .016), .018, .003, water, vertices=8)

street_z = -2.60
box("Terrain", (0, 17, street_z - .19), (105, 52, .26), earth)
box("Main street", (0, 12, street_z), (80, 8.1, .12), road)
box("Side street", (6.25, 28.0, street_z - .006), (7.2, 24, .12), road)
box("Near sidewalk", (1.0, 7.45, street_z + .082), (66, 1.08, .17), walk)
box("Far left sidewalk", (-14.175, 16.60, street_z + .082), (33.65, 1.08, .17), walk)
box("Far right sidewalk", (21.8, 16.60, street_z + .082), (23.9, 1.08, .17), walk)
for x in range(-27, 31, 4):
    box("Broken center line", (x, 12, street_z + .066), (1.65, .092, .01), paint)
for y in range(8, 16):
    box("Crosswalk", (2.25, y, street_z + .071), (1.02, .40, .014), paint)
glb("houses/craftsman_cottage", (-11, 22, street_z - .06), 0, .93)
glb("houses/brick_rowhouse", (-4.9, 23, street_z - .06), 0, .83)
glb("houses/alpine_a_frame", (17.0, 22.6, street_z - .06), 0, .91)
glb("houses/craftsman_cottage", (12.6, 31.4, street_z - .06), -90, .91)
glb("trees/round_oak", (-17.5, 18.69, street_z - .06), 24, .75)
glb("trees/autumn_maple", (12.7, 18.77, street_z - .06), 75, .68)
glb("trees/silver_birch", (23.9, 17.56, street_z - .06), 31, .73)

box("Bakery storefront", (-.40, 21.65, street_z + 1.79), (5.05, 6.8, 3.5), brick, .035)
box("Bakery fascia", (-.40, 18.22, street_z + 2.87), (5.18, .25, .48), trim, .025)
box("Canvas canopy", (-.40, 17.89, street_z + 2.51), (5.26, .88, .15), awning, .025)
text("Bakery name", "BAKERY", (-.40, 18.083, street_z + 2.88), .35, ink, (90, 0, 0))
for x in (-1.64, .64, 1.59):
    box("Bakery glazing", (x, 18.19, street_z + 1.23), (.77, .10, 1.65), car_window, .016)
    box("Bakery window sill", (x, 18.10, street_z + .40), (.90, .28, .065), trim)
box("Bakery entrance recess", (-.51, 18.17, street_z + 1.14), (.94, .12, 2.12), ink)
box("Bakery open door", (-.83, 17.84, street_z + 1.16), (.90, .075, 2.14), wood, .02, -60)

line_x, line_y = 2.15, 15.74
cylinder("Traffic pole", (line_x, line_y, street_z + 1.56), .058, 3.12, silver)
box("Traffic signal casing", (line_x, line_y, street_z + 3.14), (.37, .22, .88), ink, .04)
for i, color in enumerate((signal_green, signal_off, signal_off)):
    cylinder("Signal lens", (line_x, line_y - .125, street_z + 2.88 + i * .255),
             .095, .052, color, (90, 0, 0))

cx, cy, cz = 4.53, 10.25, street_z + .07
box("Parked sedan lower body", (cx, cy, cz + .52), (4.10, 1.76, .60), car_white, .16)
box("Car cabin", (cx - .09, cy, cz + .99), (2.35, 1.49, .64), car_window, .19)
box("Car roof", (cx - .10, cy, cz + 1.32), (1.72, 1.38, .107), car_white, .05)
for dx in (-1.38, 1.35):
    for side in (-1, 1):
        cylinder("Tire", (cx + dx, cy + side * .843, cz + .32), .315, .21, tire, (90, 0, 0))
        cylinder("Hub", (cx + dx, cy + side * .953, cz + .32), .169, .024, silver, (90, 0, 0))
for side in (-1, 1):
    box("Headlamp", (cx - 2.03, cy + side * .60, cz + .60), (.087, .35, .14), trim, .026)
box("Driver's open door", (cx - .99, cy - 1.37, cz + .66), (1.03, .10, .54), car_white, .033, -62)
box("Open door window", (cx - .99, cy - 1.37, cz + 1.11), (1.03, .073, .40), car_window, .037, -62)

if args.export_world:
    for name, x, y, heading in [
        ("bay_window_house", -19, 22.3, 0), ("ochre_townhouse", -26, 22, 0),
        ("red_gable_house", 25.0, 22.0, 0), ("bay_window_house", 33.0, 21.9, 0),
        ("corner_grocery", 13.5, 23.1, -90), ("brick_walkup", -2.4, 31.0, 90),
        ("ochre_townhouse", -2.4, 39.0, 90), ("red_gable_house", 14.0, 40.5, -90),
        ("brick_walkup", 7.0, 46.6, 0), ("bay_window_house", 23, 7.0, 180),
        ("red_gable_house", 32, 7.0, 180), ("ochre_townhouse", -19, 5.8, 180),
    ]:
        glb("houses/" + name, (x, y, street_z - .06), heading)
    for x, y in [(10.4, 23), (2.0, 30), (10.5, 35), (2.1, 43), (26, 18.4), (-13, 17.8)]:
        glb("trees/round_oak", (x, y, street_z - .06), 43, .53)
    for x, y in [(2.45, 24.0), (10.12, 31), (-7, 16.85), (20, 16.85)]:
        cylinder("Streetlamp pole", (x, y, street_z + 2.22), .048, 4.18, silver)
        box("Streetlamp head", (x, y - .19, street_z + 4.28), (.25, .54, .125), ink, .03)
    # The landing and Martin's kitchen sit on a separate set for clean camera cuts.
    hx = 105
    hall = mat("Hallway plaster", (.44, .42, .35))
    hall_floor = mat("Hallway linoleum", (.24, .225, .17))
    box("Landing floor", (hx, 1.7, -.065), (6.4, 9.0, .13), hall_floor)
    box("Landing ceiling", (hx, 1.8, 2.76), (6.3, 9.1, .16), trim)
    box("Left corridor wall", (hx - 1.35, -.48, 1.37), (.15, 4.5, 2.74), hall)
    box("Right corridor wall", (hx + 1.35, -.48, 1.37), (.15, 4.5, 2.74), hall)
    for side in (-1, 1):
        box("Doorway infill", (hx + side * 1.36, 1.80, 1.40), (1.48, .14, 2.8), hall)
        box("Doorjamb", (hx + side * .62, 1.71, 1.14), (.079, .19, 2.29), trim)
    box("Door header", (hx, 1.72, 2.49), (1.31, .16, .48), hall)
    box("Door casing header", (hx, 1.71, 2.24), (1.32, .18, .075), trim)
    box("Martin's door", (hx - .58, 2.34, 1.06), (1.16, .081, 2.12), wood, .015, 87)
    box("Apartment rear wall", (hx, 6.05, 1.37), (6.25, .17, 2.74), hall)
    box("Apartment side wall", (hx + 3.02, 4.00, 1.37), (.15, 4.0, 2.74), hall)
    glb("interiors/kitchen/dining_table", (hx + .56, 4.7, 0), 11)
    glb("interiors/kitchen/dining_chair", (hx + .67, 3.93, 0), 170)
    glb("interiors/kitchen/base_cabinet", (hx - 1.56, 5.49, 0))
    glb("interiors/kitchen/base_cabinet", (hx - .64, 5.49, 0))
    glb("interiors/kitchen/dish_set", (hx + .91, 4.74, .76))
    box("Playing radio", (hx + .16, 4.52, .869), (.305, .133, .221), wood, .018)
    box("Radio speaker grille", (hx + .105, 4.45, .87), (.159, .015, .163), ink, .009)
    for i in range(6):
        box("Radio grille line", (hx + .101, 4.441, .810 + .021 * i),
            (.125, .004, .003), silver)
    led = mat("Radio playing diode", (.85, .24, .055), .4, 2)
    box("Radio status LED", (hx + .259, 4.447, .922), (.03, .011, .013), led)
    cylinder("Radio dial", (hx + .258, 4.441, .86), .029, .021, silver, (90, 0, 0))
    # The dog is framed below the doorway in the last point-of-view shot.
    dog_x, dog_y, dog_floor = .88, 17.54, street_z + .11
    fur = mat("Dog warm tan fur", (.47, .30, .16))
    dark_fur = mat("Dog ears", (.23, .13, .076))
    cream_fur = mat("Dog muzzle", (.65, .49, .31))
    box("Dog body", (dog_x, dog_y, dog_floor + .34), (.29, .46, .44), fur, .12)
    box("Dog head", (dog_x, dog_y - .162, dog_floor + .603), (.293, .262, .28), fur, .092)
    box("Dog muzzle", (dog_x, dog_y - .292, dog_floor + .553), (.188, .151, .13), cream_fur, .048)
    box("Dog nose", (dog_x, dog_y - .364, dog_floor + .572), (.091, .043, .049), ink, .020)
    for sign in (-1, 1):
        box("Dog ear " + str(sign), (dog_x + sign * .139, dog_y - .113, dog_floor + .611),
            (.078, .155, .211), dark_fur, .035, sign * 12)
        box("Dog eye " + str(sign), (dog_x + sign * .068, dog_y - .281, dog_floor + .642),
            (.043, .026, .041), ink, .013)
    box("Dog collar", (dog_x, dog_y - .107, dog_floor + .477), (.254, .228, .053), awning, .019)
    box("Dog tail", (dog_x + .12, dog_y + .27, dog_floor + .236), (.098, .271, .086), fur, .035, 24)
    rig("DogHeadRig", (dog_x, dog_y - .10, dog_floor + .51),
        ["Dog head", "Dog muzzle", "Dog nose", "Dog ear -1", "Dog ear 1", "Dog eye -1", "Dog eye 1"])
    rig("DogTailRig", (dog_x + .05, dog_y + .165, dog_floor + .253), ["Dog tail"])
    rig("DogRig", (dog_x, dog_y, dog_floor),
        [ob.name for ob in scene.objects if ob.name.startswith(("Dog ", "DogHeadRig", "DogTailRig"))
         and ob.parent is None])
    bpy.data.objects.remove(bpy.data.objects["Car cabin"], do_unlink=True)
    box("Windshield", (cx - 1.04, cy, cz + 1.07), (.16, 1.40, .48), car_window, .038)
    box("Rear windscreen", (cx + 1.05, cy, cz + 1.07), (.13, 1.40, .48), car_window, .035)
    box("Far side windows", (cx + .02, cy + .69, cz + 1.07), (1.97, .074, .48), car_window, .041)
    box("Rear passenger window", (cx + .68, cy - .69, cz + 1.09), (.70, .070, .40), car_window, .032)
    box("Pillar between doors", (cx + .30, cy - .71, cz + 1.06), (.10, .10, .47), car_white, .02)
    box("Rear seat cushion", (cx + .69, cy, cz + .78), (.45, 1.24, .115), ink, .048)
    box("Rear seat back", (cx + .91, cy, cz + .958), (.20, 1.24, .38), ink, .048)
    clock_x, clock_y, clock_base = cx + .64, cy - .34, cz + .838
    clock_case = mat("Burgundy alarm clock", (.30, .071, .058), .53)
    clock_digits = mat("Red LED digits", (.90, .15, .043), .45, .55)
    box("Alarm clock case", (clock_x, clock_y, clock_base + .076), (.237, .139, .152), clock_case, .018)
    box("AlarmClockFace", (clock_x, clock_y - .071, clock_base + .079), (.201, .009, .096), ink, .008)
    text("AlarmClockDigits", "10:17", (clock_x, clock_y - .079, clock_base + .080), .044,
         clock_digits, (90, 0, 0))
    box("Alarm snooze button", (clock_x, clock_y + .004, clock_base + .155), (.119, .053, .021), silver, .006)
    clock = rig("AlarmClock", (clock_x, clock_y, clock_base),
                ["Alarm clock case", "AlarmClockFace", "AlarmClockDigits", "Alarm snooze button"])
    clock.rotation_euler.z = radians(-48)
    room_glass = bpy.data.objects["Cup on rug"]
    bpy.data.objects.remove(room_glass, do_unlink=True)
    tumbler("ReelCup", (-1.245, -1.955, .547))
    rig("PhoneRig", phone, ["Phone housing", "Phone screen", "Time", "Day", "Lock line"])
    rig("DoorRig", (cx - 1.23, cy - .89, cz + .67), ["Driver's open door", "Open door window"])
    rig("SpillRig", (-1.16, -1.56, .017), ["Small spill", "Water drops"])
    for original, renamed in [("Signal lens", "SignalGreen"), ("Signal lens.002", "SignalRed"),
                              ("Phone screen", "PhoneScreen"), ("Time", "PhoneTime"),
                              ("Day", "PhoneDay"), ("Lock line", "PhoneLock")]:
        bpy.data.objects[original].name = renamed
    # A free, dark seat is visible through the side opening.
    seat = mat("Driver seat fabric", (.048, .055, .058))
    box("Driver seat base", (cx - .23, cy - .45, cz + .77), (.48, .40, .17), seat, .045)
    box("Driver seat back", (cx + .02, cy - .45, cz + .99), (.16, .40, .48), seat, .045)
    # Break up the near bedroom wall with an interior passage.
    bpy.data.objects["Bedroom right wall"].name = "Bedroom side wall"
    output = HERE / "motion" / "set.glb"
    output.parent.mkdir(exist_ok=True)
    # Explicit mesh conversion keeps the small phone text and bakery sign.
    bpy.ops.object.select_all(action="DESELECT")
    for obj in list(scene.objects):
        if obj.type == "FONT":
            obj.select_set(True)
            bpy.context.view_layer.objects.active = obj
            bpy.ops.object.convert(target="MESH")
            bpy.ops.object.select_all(action="DESELECT")
    bpy.ops.export_scene.gltf(filepath=str(output), export_format="GLB", export_apply=True)
    print(output)
    raise SystemExit

sun_data = bpy.data.lights.new("Late morning sun", "SUN")
sun_data.energy = 3.2
sun_data.angle = radians(4)
sun = bpy.data.objects.new("Late morning sun", sun_data)
scene.collection.objects.link(sun)
sun.rotation_euler = Vector((-.23, -1, -.32)).to_track_quat("-Z", "Y").to_euler()
bounce = bpy.data.lights.new("Soft bedroom bounce", "AREA")
bounce.energy = 70
bounce.size = 4
light = bpy.data.objects.new("Soft bedroom bounce", bounce)
scene.collection.objects.link(light)
light.location = (0, -1.35, 2.65)
light.rotation_euler = (Vector((0, .1, .4)) - light.location).to_track_quat("-Z", "Y").to_euler()

camera_data = bpy.data.cameras.new("Point of view")
camera = bpy.data.objects.new("Point of view", camera_data)
scene.collection.objects.link(camera)
scene.camera = camera
camera_data.clip_start = .015
SHOTS.mkdir(exist_ok=True)
frames = [
    ("01_waking", (.05, -2.20, .90), (.03, 2.50, 1.37), 31),
    ("02_late_morning", (.13, -1.89, 1.37), (-.08, .80, .82), 33),
    ("03_phone", (-.78, -1.54, 1.13), (-1.018, -2.02, .565), 91),
    ("04_spill", (-1.55, -1.84, .44), (-1.18, -1.53, .040), 42),
    ("05_window", (.37, 2.07, 1.64), (3.35, 13.4, street_z + 1.17), 28),
    ("06_open_door", (-2.81, 6.87, .69), (4.40, 10.26, street_z + .86), 42),
]
for name, p, focus, lens in frames:
    if args.shots and name not in args.shots:
        continue
    camera.location = p
    camera.rotation_euler = (Vector(focus) - camera.location).to_track_quat("-Z", "Y").to_euler()
    camera_data.lens = lens
    scene.render.filepath = str(SHOTS / (name + ".png"))
    bpy.ops.render.render(write_still=True)
