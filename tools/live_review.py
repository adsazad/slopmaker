"""Local review window and Godot render launcher for LINE 13."""
from __future__ import annotations

import argparse
from datetime import datetime
import json
import os
from pathlib import Path
import subprocess
import wave

ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "godot" / "line_13"
STATE = PROJECT / "render" / ".live-review"
STATUS = STATE / "status.json"
NOTES = STATE / "review-notes.txt"
LOG = STATE / "godot.log"
HOUSE_PREVIEW = ROOT / "assets" / "houses" / "houses_preview.png"
GODOT = ROOT / "tools" / "godot" / "Godot_v4.7.2-stable_win64_console.exe"


def publish(stage, detail, image=None, run=None, duration=None):
    STATE.mkdir(parents=True, exist_ok=True)
    update = dict(stage=stage, detail=detail, image=str(image) if image else None, run=run, duration=duration)
    draft = STATUS.with_suffix(f".{os.getpid()}.tmp")
    draft.write_text(json.dumps(update), encoding="utf-8")
    draft.replace(STATUS)


def render(sample):
    run = datetime.now().strftime("%Y%m%d-%H%M%S-%f")
    frames = STATE / run
    frames.mkdir(parents=True)
    output = PROJECT / "render" / f"LINE_13_{'sample' if sample else 'review'}_{run}.avi"
    env = os.environ.copy()
    env["APPDATA"] = str(PROJECT / ".godot-home" / "Roaming")
    env["LOCALAPPDATA"] = str(PROJECT / ".godot-home" / "Local")
    env["LINE13_REVIEW_FRAMES"] = str(frames)
    command = [str(GODOT), "--path", str(PROJECT), "--fixed-fps", "30", "--write-movie", str(output)]
    if sample:
        command += ["--quit-after", "240"]
    with wave.open(str(PROJECT / "audio" / "eli_narration.wav"), "rb") as narration:
        duration = 8 if sample else narration.getnframes() / narration.getframerate() + 2
    publish("Rendering sample" if sample else "Rendering", "Godot is rendering the scene. The frame below updates during the run.", run=run, duration=duration)
    try:
        with LOG.open("w", encoding="utf-8") as log:
            result = subprocess.run(command, env=env, stdout=log, stderr=subprocess.STDOUT, creationflags=subprocess.CREATE_NO_WINDOW, check=False)
        with LOG.open(encoding="utf-8", errors="replace") as log:
            completed = any("Done recording movie" in line for line in log)
        if result.returncode != 0 or not completed or not output.is_file():
            raise RuntimeError("Godot did not finish recording. See godot.log in the review folder.")
    except (OSError, RuntimeError) as error:
        publish("Render interrupted", str(error), run=run)
        return 1
    publish("Sample ready" if sample else "Render ready", str(output), run=run)
    return 0


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--render", action="store_true", help="render the full pilot with live frame updates")
    parser.add_argument("--sample", action="store_true", help="render an eight second sample")
    parser.add_argument("--publish", nargs=2, metavar=("STAGE", "DETAIL"))
    parser.add_argument("--image", type=Path, help="optional PNG to display with a published update")
    args = parser.parse_args()
    if args.render or args.sample:
        return render(args.sample)
    if args.publish:
        publish(*args.publish, image=args.image.resolve() if args.image else None)
        return 0
    if not STATUS.exists():
        publish("House asset review", "Latest Sand3D draft. Live Godot frames appear when a review render starts.", HOUSE_PREVIEW)
    launch = ["pwsh.exe", "-NoProfile", "-STA", "-File", str(Path(__file__).with_name("live_review.ps1"))]
    return subprocess.call(launch, creationflags=subprocess.CREATE_NO_WINDOW)


if __name__ == "__main__":
    raise SystemExit(main())



