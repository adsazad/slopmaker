# Late Morning — Episode 1

The animated Reel runs for 67 seconds. It starts in the bedroom, follows the empty street and Martin's open apartment, then ends at an alarm clock ringing in the car. The dog stops outside the open door.

- `launch_live_preview.cmd` opens the Godot preview. Space pauses it, R replays it, and Escape closes it. Playback stops at the end.
- `preview.html` plays the exported motion cut.
- `late_morning_motion_reel.mp4` is the vertical MP4.
- `motion/reel.gd` contains the camera positions, timing, and prop animation.
- `motion_audio.py` mixes both Qwen Aiden takes (`narration.wav` and `narration_extension.wav`) with footsteps, radio, and other sound effects.
- `stage.py --export-world` stages the Godot set, including the added Sand3D buildings.

The earlier still-frame cut remains in `late_morning_preview.mp4`. To rebuild the animated set and audio from the workspace root:

```powershell
.venv\Scripts\python.exe series\late_morning\stage.py --export-world
.venv\Scripts\python.exe series\late_morning\motion_audio.py
```

Import `series/late_morning/motion` in Godot, then run the project to preview changes. Capture with `--write-movie motion_capture.avi --resolution 540x960 --fixed-fps 24 -- --capture`, then pass the resulting AVI to `motion_audio.py --capture`.
