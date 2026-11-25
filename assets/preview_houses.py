import bpy
from pathlib import Path
from mathutils import Vector
root=Path(__file__).resolve().parent
out=root/'houses'/'houses_preview.png'
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
for i,name in enumerate(['blue_family_bungalow','white_colonial','sage_rental_bungalow']):
    bpy.ops.import_scene.gltf(filepath=str(root/'houses'/f'{name}.glb'))
    # imported roots are grouped; move all newly imported objects into display columns
    for ob in bpy.context.selected_objects: ob.location.x += (i-1)*13.5
scene=bpy.context.scene
scene.render.engine='BLENDER_WORKBENCH'
scene.display.shading.light='STUDIO'; scene.display.shading.color_type='MATERIAL'; scene.display.shading.show_shadows=True; scene.display.shading.show_cavity=True; scene.display.shading.cavity_type='WORLD'; scene.display.shading.background_type='WORLD'; scene.world.color=(0.74,0.79,0.84)
cam_data=bpy.data.cameras.new('preview_camera'); cam=bpy.data.objects.new('preview_camera',cam_data); scene.collection.objects.link(cam); cam.location=(0,37,24); target=Vector((0,0,2.6)); cam.rotation_euler=(target-Vector(cam.location)).to_track_quat('-Z','Y').to_euler(); cam_data.type='ORTHO'; cam_data.ortho_scale=43; cam_data.clip_end=100; scene.camera=cam
scene.render.resolution_x=1800; scene.render.resolution_y=800; scene.render.resolution_percentage=100; scene.render.image_settings.file_format='PNG'; scene.render.filepath=str(out); bpy.ops.render.render(write_still=True); print(out)


