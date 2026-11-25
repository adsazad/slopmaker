# Sand3D interior kit

Each piece is a separate GLB. The kit uses metric scale and faces forward along negative Y in the Sand3D source. In Godot, the exported models are Y-up. Floor and tabletop pieces rest on their base. Use the placement field in the inventory to find pieces intended for a wall or ceiling. The ceiling pendant's base is at the bottom of the shade, so move it down 0.355 metres from the ceiling to place its canopy.

| Category | Pieces |
| --- | --- |
| Living room | Sofa, armchair, coffee table, side table, rug, media console, TV, bookcase, fireplace |
| Bedroom | Single bed, double bed, nightstand, dresser, wardrobe, laundry hamper |
| Kitchen and dining | Dining table, chair, stool, base and wall cabinets, sink, refrigerator, range, microwave, dishwasher, dishes, stockpot, cutting board |
| Bathroom | Vanity, toilet, tub, shower, mat, mirror, towel rack |
| Office | Desk, desk chair, filing cabinet, laptop |
| Utility | Washer, dryer, shelves, storage box, wastebasket |
| Lighting | Floor lamp, table lamp, ceiling pendant, wall sconce |
| Decor | Potted plant, books, framed print, clock, curtains, floating shelf |
| Architecture | Door, window, outlet, switch, baseboard, wall, floor, ceiling |
| Entryway | Shoe bench, coat hooks, entry mat |

`inventory.json` lists every GLB and its placement type. The files contain visual geometry and materials. Doors, appliances, and other elements are static models. Add collision shapes, light nodes, and interactions in the scene where needed.

From the repository root, rebuild the models and render the preview with:

```powershell
.venv\Scripts\python.exe assets\build_interiors.py
.venv\Scripts\python.exe assets\preview_interiors.py
```
