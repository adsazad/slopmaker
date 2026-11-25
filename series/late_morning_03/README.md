# Late Morning — Episode 3

A 75-second vertical reel about Day 2. The 3D set reuses the pickup, dog, station,
and highway from Episode 2. Episode 3 adds a rear cab for the nap, a storage tank
yard, stocked shelves, a police van and handheld radio, fuel cans, and a recovered
hose. `motion/station_assets.gd` builds those pieces. `motion/reel.gd` stages and
lights 17 camera shots.

Open `motion/project.godot` in Godot 4 and run the project. Space pauses, R starts
over, Left and Right seek five seconds, and Escape closes playback.

The seven takes in `motion/assets/` use the voice studio's Michael voice.
`narration.txt` contains the recording script. Run `python3 mix_audio.py` to
rebuild the soundtrack from those takes and the radio effects. Run `./render.sh`
with Godot and FFmpeg on PATH to export the 540×960 MP4.
