# Late Morning Episode 2 asset kit

The kit contains 50 Sand3D GLBs. The models use metres after import. The generators use millimetres and face the pickup, signs, buildings, and boots toward negative Y in Blender and positive Z in Godot.

| Set | New models |
| --- | --- |
| Borrowed house and town | Split level, cedar bungalow, two clocks, blackout traffic signal and utility pole |
| Westbound highway | Two-lane 24 m segment, 8 m guardrail, overhead Route 6 sign and county road signpost |
| Pickup | Truck, hinged passenger door, low fuel gauge, keys, water jug and canned food |
| Last Stop Fuel | Tiled shop, hinged glass door, canopy, mechanical price sign, dark pump, hose and nozzle, checkout, stocked shelf, drink cooler, chest freezer, coffee station, promo stand, bollard, trash bin and door bell |
| Story inserts | Sealed water bottle, open atlas, handwritten note and distant power plant silhouette |
| Roadside dressing | Sedan, wagon, van, trailer, barrier, roadwork drum, mailboxes, fence, grass, leaf, newspaper and bird |
| Wardrobe | Daniel's left and right leather work boots |

For Daniel's borrowed room, reuse the bed, fridge, lamp and kitchen fixtures from `assets/interiors`. The borrowed house exterior works as an establishing shot. Stage the interior as a separate playable set.

The passenger door has a hinge pivot. Mount it at **(0.852, 0.665, 0.771)** relative to the pickup in Godot. The shop door also has a hinge pivot. Place the pump and hose at the same origin. The nozzle is a separate prop so Daniel can lift it. Add the dog and collision shapes separately when blocking the action.

The script is in `story/late-morning-episode-02.md`. Rebuild and preview from the project root:

```powershell
.venv\Scripts\python.exe assets\build_late_morning_02.py
.venv\Scripts\python.exe assets\build_late_morning_02_roads.py
.venv\Scripts\python.exe assets\build_daniel_boots.py
.venv\Scripts\python.exe assets\build_last_stop.py
.venv\Scripts\python.exe assets\preview_late_morning_02.py
```
