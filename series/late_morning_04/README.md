# Late Morning — Episode 4

An 80-second vertical reel that starts on Day 3 and ends the following morning.
The voice track uses Michael from the voice studio. `narration.txt` holds the
recorded text, including the map note callback and Daniel's thoughts about the
animals returning.

Open `motion/project.godot` in Godot 4 and run the project to preview the reel.
Space pauses, R restarts, the arrow keys seek five seconds, and Escape closes it.

The garage, tool kit, and workbench are in `motion/tools_and_garage.gd`. The
neighborhood, house and cab interiors, gamepad, atlas, smoke, and flock are in
`motion/neighborhood.gd`. Cameras, lighting, and animation are in `motion/reel.gd`.

Run `python3 mix_audio.py` to rebuild the voice and effects mix from the takes
in `motion/assets`. Run `./render.sh` to export the 540 × 960 MP4 using Godot
and FFmpeg.
