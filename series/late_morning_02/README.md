# Late Morning Episode 2

Daniel Ward wakes in a stranger's room on Day 18, then tells the story of Day 1. The shot list and animation are in `motion/reel.gd`. The script is in `story/late-morning-episode-02.md`.

Open `launch_live_preview.cmd` to play the Godot scene. Press Space to pause, Left or Right to seek five seconds, R to replay, or Escape to close. Playback stops at the end.

The staged GLBs draw from the 50-model kit in `assets/late_morning_02` and reuse existing interiors and trees. Save the complete Qwen take for the revised script as `narration.wav`. The mixer accepts explicit paragraph break times via `--cuts`. Use `--effects-only` to review the visuals while the new narration is pending.

From the workspace root, rebuild the set and mix:

```powershell
.venv\Scripts\python.exe series\late_morning_02\stage.py
.venv\Scripts\python.exe series\late_morning_02\stage_flashback.py
.venv\Scripts\python.exe series\late_morning_02\mix_episode.py
```

Import the `motion` project in Godot. Capture with `--write-movie full_reel.avi --fixed-fps 24 -- --capture`, then pass the resulting AVI to `mix_episode.py --capture` to export the MP4.
