# Late Morning downtown

Three blocks of Main Street, with 24 editable buildings, two intersections, rear
alleys, and extra buildings filling out the side streets. The set uses the same
low poly look and vehicle kit as the earlier episodes. No episode timeline is
attached to the set.

## Open the set

Open `project.godot` in Godot 4 and run it. Keys **1–6** jump between the
overview, café footpath, café interior, sporting arms storefront, shop interior,
and intersection. Use **WASD** to move, **Q/E** to descend or climb, and hold the
right mouse button to look around.

`scenes/downtown.scn` is the complete editable set. The other scenes can be used
individually. For a separate Godot project, bring over `scenes/` and `models/`
at the project root so the scene can resolve the reused vehicles and trees.

## Buildings

| Block | Storefronts |
| --- | --- |
| 1 | Daybreak Coffee, Riverside Pharmacy, Miller Hardware, Union Barbers, West End Market, Cedar Books, Hearth Bakery, Main Street Laundry |
| 2 | Briar Sporting Arms, Oak Street Florist, The Rialto, Dale Shoe Repair, Juniper Cafe, Parcel and Post, Main Street Dental, Fox Record Shop |
| 3 | Town Library, Carter Tailoring, Elm Diner, Merchant Apartments, County Savings, Corner News, Bridge Cycle Works, Walnut Antiques |

Both cafés have bistro seating inside and on the footpath, menu boards, counters,
espresso machines, pastry cases, and pendant lights. Briar Sporting Arms has an
exterior sign and window displays, an entry, a sales counter, gear shelves, and
display cabinets with static silhouettes. The other storefronts have dressing
visible through their windows. Upper floors have exterior windows and roof
detail.

The footpaths include curbs, ramps, tactile pads, benches, litter bins, tree
planters, lamps, bicycle racks, and a bus shelter. The roads have painted
crosswalks, signal poles, storm drains, parking marks, and parked vehicles.
Benches, planters, the shelter, litter bins, and lamps also have their own scenes.

## Portable generator

`scenes/portable_generator.scn` is a standalone, carryable generator prop,
about 0.66 × 0.47 × 0.54 m. It has a tubular frame, rubber feet, an engine with
cooling fins, recoil starter, fuel tank, alternator, and outlet panel. Open
`generator_preview.tscn` for the close-up. The frame, engine, tank, and panel
are grouped separately in the scene. Rebuild it from this directory with
`godot --headless --path . --script bake_generator.gd`.

## Standalone episode props

| Scene | Details |
| --- | --- |
| `scenes/binoculars.scn` | Rubber body, coated lenses, focus and diopter rings, and a separate neck strap. |
| `scenes/torch.scn` | Handheld torch with grip, switch, clip, and lens. Enable the hidden `Torch beam` spotlight for lit shots. |
| `scenes/deer.scn` | Whitetail buck with individual hip, knee, neck, head, ear, and tail pivots for posing. |
| `scenes/kerosene_stove.scn` | Enamel single burner cookstove with a brass control and cast iron pot support. |
| `scenes/utensils.scn` | Movable pot, lid, pan, plate, mug, ladle, spoon, and fork. The pot and mug are hollow. |
| `scenes/pistol.scn` and `scenes/short_shotgun.scn` | Static low poly firearm props for shop displays and cinematics. |
| `scenes/pistol_ammunition.scn` and `scenes/shotgun_ammunition.scn` | Closed cartons and a separate spare magazine prop for set dressing. |

Use the corresponding preview scenes or `cooking_preview.tscn` to inspect
these props. Run the corresponding `bake_*.gd` script to regenerate a prop
after editing its source.

Open `sporting_goods_preview.tscn` for all four sporting shop props, or
rebuild them with `godot --headless --path . --script bake_sporting_goods_props.gd`.

Open `grocery_preview.tscn` for the grocery supply kit. The five scenes
in `scenes/` are `water_bottles.scn`, `canned_beans.scn`, `canned_soup.scn`,
`manual_can_opener.scn`, and `dog_food.scn`. Both foods include sealed and
opened cans with separate lids. The dog food bag and filled bowl can be moved
independently. Rebuild this kit with
`godot --headless --path . --script bake_grocery_props.gd`.

`scenes/cold_drinks.scn` contains three soda cans with individual pull tabs.
`scenes/chips.scn` contains four fictional chip brands with individually movable
bags. Open `snacks_preview.tscn` to see both groups together.

Edit the packed scenes in Godot or change the layout and builders in
`downtown.gd` and `storefronts.gd`. After editing the builders, run
`godot --headless --path . --script bake.gd` from this directory to regenerate
the scenes. Baking replaces the generated scenes.
