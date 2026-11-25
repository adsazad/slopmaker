# How to create and manage characters

This guide describes the Sand3D character workflow used by the first 13
characters. The order below is a suggested introduction route for the story;
it is a planning aid, not fixed story canon.

## Roster order

The `sequence` value in `roster.json` is the source of truth for display and
story order. Character IDs and filenames stay stable if the sequence changes.

| Sequence | Character | Story role |
| ---: | --- | --- |
| 01 | Milo the Rookie Builder | Starter builder and first friend |
| 02 | Rhea Star Scout | Trailblazer who points toward the wild paths |
| 03 | Fern Garden Ranger | Woodland guide |
| 04 | Jax Street Skater | Finds shortcuts around town |
| 05 | Bolt Speed Runner | Leads races and timed challenges |
| 06 | Byte Arcade Runner | Arcade and gadget tinkerer |
| 07 | Coral Captain | Harbor navigator and map-reader |
| 08 | Mira Wave Rider | Shoreline explorer |
| 09 | Tavi Frost Explorer | Mountain guide |
| 10 | Rex Dino Defender | Guardian with a brave streak |
| 11 | Luna Moon Mage | Opens the door to magic |
| 12 | Echo Music Maker | Brings music and rhythm to the group |
| 13 | Atlas Space Mechanic | Fixes machines and introduces the larger frontier |

To change the order, edit `STORY_ORDER` in `build_roster.py` and rebuild. Do not
rename an existing ID just to move a character; IDs are used for filenames and
asset references.

## Workspace files

```text
assets/characters/
  milo_rookie.py              Sand3D source for Milo
  milo_rookie.glb             Milo model
  build_roster.py             Shared builder for the other 12 characters
  roster.json                 Ordered character and asset manifest
  roster_preview.png          Labeled contact sheet
  roster/                     One GLB per character in the second wave
```

The model source is the editable truth. Treat GLBs and the contact sheet as
generated outputs.

## Build the current cast

From the workspace root, run:

```powershell
.\.venv\Scripts\python.exe assets\characters\milo_rookie.py
.\.venv\Scripts\python.exe assets\characters\build_roster.py
```

The first command rebuilds Milo. The second exports the 12 roster characters,
rewrites `roster.json`, and renders `roster_preview.png`.

The pinned dependency is in `requirements.txt`. The current workspace uses
Python 3.13 with sand3d 1.7.0 and its Blender `bpy` dependency.

## Add a character

1. Choose a distinctive role, name, lowercase `snake_case` ID, and story-order
   position. Add the ID to both `CAST` and `STORY_ORDER` in `build_roster.py`.
2. Give it a strong palette in the character record: `skin`, `torso`, `sleeve`,
   `pants`, `boots`, `sole`, `accent`, and `trim` are sRGB hex colors.
3. Select an existing `head` and `gear` style, or add a new branch for a new
   silhouette or accessory in `build_avatar`. Keep new mesh names prefixed by
   the character ID so names remain unique in the scene.
4. Build the model with `part`, `sphere`, `cylinder`, or `cone`. These wrappers
   create Sand3D geometry and assign a material. Use Sand3D material names such
   as `plastic`, `fabric`, `leather`, `rubber`, `glass`, `wood` presets (`oak`,
   `pine`, `walnut`, or `birch`), and `painted_metal`.
5. Export by running the roster build command. It writes the GLB under
   `assets/characters/roster/` and updates the manifest and contact sheet.
6. Inspect the new pose and colors in the contact sheet and adjust the source
   program if anything overlaps or reads poorly at the shared avatar scale.

## Shape and export conventions

- Dimensions use millimetres; Z points up and the avatar faces -Y.
- Put the soles at Z = 0 so characters share a floor height in the world.
- A Sand3D box starts at its local Z = 0 and is centred across X and Y. The
  helper functions in the builder handle primitive placement and materials.
- Build the head and face toward Y = -110. Add gear on the back at positive Y.
- Keep limbs and accessories as named parts so they can be revised and rigged
  later. The current avatars are static assemblies; they do not yet contain a
  skeleton, animation, or Roblox-specific rig.
- Export each character as its own GLB through `s3d.export`. The GLB stores
  metres even though the source program is written in millimetres.
- Keep preview cameras, labels, and ground planes out of the character assembly;
  the roster builder adds those only after exporting the GLBs.

For a single-character source example, see [Milo's builder](milo_rookie.py).
For the shared palette, headgear, accessory, export, and roster logic, see
[the roster builder](build_roster.py).
