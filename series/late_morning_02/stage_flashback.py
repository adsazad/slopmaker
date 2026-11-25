"""Keep the Episode 1 alarm and Martin's radio consistent in the Day 1 flashback."""
from pathlib import Path
from math import cos, sin, tau
import bpy
from mathutils import Vector

HERE = Path(__file__).resolve().parent
bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
bpy.ops.import_scene.gltf(filepath=str(HERE.parent / "late_morning" / "motion" / "set.glb"))


def anchor(name, location):
    ob = bpy.data.objects.new(name, None)
    scene.collection.objects.link(ob)
    ob.location = location
    bpy.context.view_layer.update()
    return ob


def attach(ob, root):
    transform = ob.matrix_world.copy()
    ob.parent = root
    ob.matrix_world = transform


old_alarm = bpy.data.objects.get("AlarmClock")
if old_alarm is None:
    raise RuntimeError("Episode 1 alarm is missing from the set export")
alarm_set = anchor("DayOneAlarmSet", (0, 0, 0))
for ob in [old_alarm, bpy.data.objects["Rear seat cushion"], bpy.data.objects["Rear seat back"]]:
    attach(ob, alarm_set)
keep = {alarm_set, *alarm_set.children_recursive}

radio_parts = [ob for ob in scene.objects
               if ob.name.startswith(("Playing radio", "Radio speaker grille", "Radio grille line",
                                      "Radio status LED", "Radio dial"))]
if not radio_parts:
    raise RuntimeError("Martin's radio is missing from the Episode 1 set export")
radio = anchor("MartinsRadio", (105.16, 4.52, .759))
for ob in radio_parts:
    attach(ob, radio)
radio.location = (1.76, .79, .77)
keep.update([radio, *radio_parts])

cab_radio = anchor("CabRadio", (0, 0, 0))
for ob in radio_parts:
    replica = ob.copy()
    scene.collection.objects.link(replica)
    replica.parent = cab_radio
    replica.matrix_parent_inverse = ob.matrix_parent_inverse.copy()
    replica.matrix_basis = ob.matrix_basis.copy()
keep.update([cab_radio, *cab_radio.children_recursive])
for ob in list(scene.objects):
    if ob not in keep:
        bpy.data.objects.remove(ob, do_unlink=True)


def box(name, position, size, tint):
    bpy.ops.mesh.primitive_cube_add(size=1, location=position)
    ob = bpy.context.object
    ob.name = name
    ob.dimensions = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    material = bpy.data.materials.new(name)
    material.diffuse_color = (*tint, 1)
    material.use_nodes = True
    shader = material.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*tint, 1)
    shader.inputs["Roughness"].default_value = .62
    ob.data.materials.append(material)
    return ob


clock = anchor("BlackoutClock", (1.85, 2.72, .919))
for ob in [
    box("Clock housing", (1.85, 2.72, .972), (.236,.13,.103), (.35,.13,.098)),
    box("Clock display glass", (1.85, 2.649, .972), (.182,.012,.065), (.026,.031,.036)),
]:
    attach(ob, clock)
font = bpy.data.curves.new("Time display", "FONT")
font.body = "3:17"
font.align_x = "CENTER"
font.align_y = "CENTER"
font.size = .055
digits = bpy.data.objects.new("BlackoutDigits", font)
scene.collection.objects.link(digits)
digits.location = (1.85, 2.640, .972)
digits.rotation_euler.x = 1.570796
mat = bpy.data.materials.new("Amber digits")
mat.use_nodes = True
shader = mat.node_tree.nodes.get("Principled BSDF")
shader.inputs["Base Color"].default_value = (.95,.19,.05,1)
shader.inputs["Emission Color"].default_value = (.95,.19,.05,1)
shader.inputs["Emission Strength"].default_value = .4
digits.data.materials.append(mat)
bpy.context.view_layer.update()
attach(digits, clock)
bpy.ops.object.select_all(action="DESELECT")
digits.select_set(True)
bpy.context.view_layer.objects.active = digits
bpy.ops.object.convert(target="MESH")

wardrobe = HERE.parents[1] / "assets" / "late_morning_02" / "wardrobe"
bedroom_boots = anchor("BedroomWorkBoots", (0, 0, 0))
denim = bpy.data.materials.new("Faded denim")
denim.use_nodes = True
denim_shader = denim.node_tree.nodes.get("Principled BSDF")
denim_shader.inputs["Base Color"].default_value = (.095, .134, .156, 1)
denim_shader.inputs["Roughness"].default_value = .94
for side, x, y, angle in (("left", -1.963, -1.195, 3.11), ("right", -1.773, -1.167, 3.21)):
    before = set(scene.objects)
    bpy.ops.import_scene.gltf(filepath=str(wardrobe / f"daniel_work_boot_{side}.glb"))
    roots = [ob for ob in set(scene.objects) - before if ob.parent is None]
    mounted = anchor(f"Worn {side} boot", (x, y, .551))
    mounted.parent = bedroom_boots
    mounted.rotation_euler.z = angle
    for ob in roots:
        ob.parent = mounted
    rings = ((y - .63, .647, .059, .087), (y - .37, .64, .052, .075),
             (y - .155, .66, .045, .058), (y - .076, .705, .039, .047))
    segments = 12
    vertices = [(x + width * cos(tau * i / segments), along,
                 height + depth * sin(tau * i / segments))
                for along, height, width, depth in rings for i in range(segments)]
    faces = []
    for row in range(len(rings) - 1):
        base = row * segments
        for i in range(segments):
            j = (i + 1) % segments
            faces.append((base + i, base + i + segments, base + j + segments, base + j))
    faces += [tuple(range(segments)), tuple(reversed(range(len(vertices) - segments, len(vertices))))]
    mesh = bpy.data.meshes.new(f"{side} trouser leg")
    mesh.from_pydata(vertices, [], faces)
    mesh.materials.append(denim)
    cloth = bpy.data.objects.new(mesh.name, mesh)
    scene.collection.objects.link(cloth)
    cloth.parent = bedroom_boots
bpy.ops.export_scene.gltf(filepath=str(HERE / "motion" / "flashback.glb"), export_format="GLB")
