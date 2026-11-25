"""Cut the opening from six rendered frames and the Qwen narration WAV."""
from pathlib import Path
import subprocess
import tempfile
import wave

import imageio_ffmpeg
import numpy as np

HERE = Path(__file__).resolve().parent
FFMPEG = imageio_ffmpeg.get_ffmpeg_exe()
FPS = 24
SHOTS = [
    ("01_waking", 13.60, "0.50", "0.51", .036),
    ("02_late_morning", 20.58, "0.47", "0.56", .026),
    ("03_phone", 33.16, "0.51", "0.53", .041),
    ("04_spill", 49.12, "0.47", "0.59", .028),
    ("05_window", 55.62, "0.53", "0.53", .038),
    ("06_open_door", None, "0.56", "0.59", .065),
]


def ffmpeg(*args):
    subprocess.run([FFMPEG, "-nostdin", "-hide_banner", "-loglevel", "error", "-y", *map(str, args)], check=True)


def sound_bed(path, duration, spill_time):
    rate = 24000
    rng = np.random.default_rng(160)
    t = np.arange(round(duration * rate)) / rate
    gust_times = np.arange(0, duration + 1, .011)
    breeze = np.interp(t, gust_times, rng.normal(0, .0019, len(gust_times)))
    tone = .0023 * np.sin(2 * np.pi * 57 * t) + .0016 * np.sin(2 * np.pi * 86 * t)
    canvas = (breeze + tone) * (.5 + .42 * np.sin(np.pi * t / duration) ** 2)
    impact = t - spill_time
    struck = np.maximum(impact, 0)
    ring = (np.sin(2 * np.pi * 714 * struck) + .43 * np.sin(2 * np.pi * 1522 * struck))
    canvas += .039 * ring * np.exp(-25 * struck) * (impact >= 0)
    canvas *= np.clip(np.minimum(t * 3, (duration - t) * 3), 0, 1)
    with wave.open(str(path), "wb") as output:
        output.setparams((1, 2, rate, 0, "NONE", "not compressed"))
        output.writeframes((np.clip(canvas, -1, 1) * 32767).astype("<i2").tobytes())


def cut():
    voice_path = HERE / "narration.wav"
    with wave.open(str(voice_path)) as voice:
        spoken = voice.getnframes() / voice.getframerate()
    length = spoken + 3.1
    total_frames = round(length * FPS)
    print(f"Qwen narration: {spoken:.1f}s. Preview: {length:.1f}s.", flush=True)

    with tempfile.TemporaryDirectory(dir=HERE) as work:
        tmp = Path(work)
        start = 0
        media = []
        for i, (name, cut_time, x, y, movement) in enumerate(SHOTS):
            end = total_frames if cut_time is None else round(cut_time * length / 60.7 * FPS)
            frames = end - start
            start = end
            zoom = f"1.014+{movement}*on/{frames}"
            filters = (f"scale=1080:1920,zoompan=z='{zoom}':x='(iw-iw/zoom)*{x}':"
                       f"y='(ih-ih/zoom)*{y}':d={frames}:s=720x1280:fps={FPS},"
                       "setsar=1,format=yuv420p")
            if i == 0:
                filters += ",fade=t=in:st=0:d=1.75"
            if i == len(SHOTS) - 1:
                filters += f",fade=t=out:st={max(0, frames/FPS-1.35):.3f}:d=1.35"
            piece = tmp / f"cut_{i}.mp4"
            ffmpeg("-i", HERE / "reel_shots" / f"{name}.png", "-vf", filters, "-frames:v", frames,
                   "-an", "-c:v", "libx264", "-preset", "fast", "-crf", "19", piece)
            media.append(f"file '{piece.name}'")
        concat = tmp / "cuts.txt"
        concat.write_text("\n".join(media) + "\n", encoding="ascii")
        bed = tmp / "room_tone.wav"
        sound_bed(bed, length, length * .607)
        ffmpeg("-f", "concat", "-safe", "0", "-i", concat, "-i", voice_path, "-i", bed,
               "-filter_complex", "[1:a]highpass=f=55,adelay=900:all=1[v];[v][2:a]amix=inputs=2:duration=longest:normalize=0,alimiter=limit=0.93[a]",
               "-map", "0:v", "-map", "[a]", "-c:v", "copy", "-c:a", "aac", "-b:a", "160k",
               "-movflags", "+faststart", "-t", f"{length:.3f}", HERE / "late_morning_preview.mp4")


if __name__ == "__main__":
    cut()
