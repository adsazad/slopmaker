"""Build the live Reel mix and mux the Godot movie capture."""
import argparse
from pathlib import Path
import subprocess
import wave

import imageio_ffmpeg
import numpy as np

ROOT = Path(__file__).resolve().parent
RATE = 24000
DURATION = 67.2


def read_voice(path):
    with wave.open(str(path)) as source:
        if (source.getframerate(), source.getnchannels(), source.getsampwidth()) != (RATE, 1, 2):
            raise ValueError(f"Expected a 24 kHz mono 16-bit Qwen WAV: {path}")
        return np.frombuffer(source.readframes(source.getnframes()), dtype="<i2") / 32768.0


def build_mix():
    rng = np.random.default_rng(944)
    full_t = np.arange(round(RATE * DURATION)) / RATE
    mix = np.zeros(len(full_t))

    def add(start, signal, gain=1.0):
        offset = max(0, round(start * RATE))
        take = min(len(signal), len(mix) - offset)
        if take > 0:
            mix[offset:offset + take] += signal[:take] * gain

    def samples(length):
        return np.arange(max(1, round(length * RATE))) / RATE

    def fade(signal, start=.015, stop=.05):
        t = np.arange(len(signal)) / RATE
        return signal * np.clip(t / start, 0, 1) * np.clip((len(signal) / RATE - t) / stop, 0, 1)

    def atmosphere():
        noise = rng.normal(0, 1, len(full_t))
        grain = np.convolve(noise, np.ones(64) / 64, mode="same") * .011
        quiet = 1 - .85 * np.exp(-((full_t - 12.8) / 2.35) ** 4)
        tone = (.0032 * np.sin(2 * np.pi * full_t * 57) + .0020 * np.sin(2 * np.pi * full_t * 86))
        return (grain + tone) * quiet

    def whoosh(where, length, gain):
        t = samples(length)
        noise = rng.normal(0, 1, len(t))
        color = np.convolve(noise, np.ones(16) / 16, mode="same")
        passby = np.sin(np.pi * t / length) ** 2
        add(where, (color + .25 * np.sin(2 * np.pi * (95 * t + 95 * t * t))) * passby, gain)

    def hit(where, strength, note=78):
        t = samples(.3)
        noise = rng.normal(0, 1, len(t))
        wave_sound = np.sin(2 * np.pi * (note * t + .28 * note * (.27 - .27 * np.exp(-13 * t))))
        signal = np.exp(-24 * t) * (wave_sound + noise * np.exp(-90 * t) * .18)
        add(where, fade(signal, .004, .04), strength)

    def footfalls(first, count, gap, gain):
        for i in range(count):
            hit(first + gap * i, gain * (.8 if i % 2 == 0 else 1), 58 + 12 * (i % 2))

    def radio(where, notes, gain):
        for i, midi in enumerate(notes):
            hz = 440 * (2 ** ((midi - 69) / 12))
            t = samples(.355)
            phrase = np.sin(2 * np.pi * hz * t) + .46 * np.sin(2 * np.pi * hz * 2 * t)
            add(where + i * .485, fade(phrase * np.exp(-7 * t), .024, .07), gain)

    add(0, atmosphere())
    voice = read_voice(ROOT / "narration.wav")
    for at, start, end in [(0.35, 0, 2.70), (3.75, 9.28, 12.10), (7.62, 32.38, 39.12),
                           (13.96, 46.30, 48.25), (16.12, 48.25, 57.60)]:
        add(at, fade(voice[round(start * RATE):round(end * RATE)], .026, .04), .91)
    extension = read_voice(ROOT / "narration_extension.wav")
    # Use the quiet gaps in the take to place the story beats independently.
    for at, start, end in [(29.75, 0, 8.60), (40.80, 8.60, 10.30),
                           (43.73, 10.30, 17.73)]:
        add(at, fade(extension[round(start * RATE):round(end * RATE)], .026, .04), .91)

    whoosh(1.63, .49, .065)
    whoosh(14.52, .67, .061)
    whoosh(29.32, .27, .043)
    whoosh(50.29, .60, .061)
    hit(3.88, .067, 102)
    pulse = samples(.32)
    add(4.04, fade(np.sin(2 * np.pi * 93 * pulse) * np.sin(2 * np.pi * 15 * pulse) ** 2, .005, .05), .037)
    whoosh(9.08, .66, .052)
    for when, level, pitch in [(10.276, .078, 806), (10.51, .033, 987), (10.69, .024, 735)]:
        t = samples(.23)
        struck = np.sin(2 * np.pi * pitch * t) + .42 * np.sin(2 * np.pi * pitch * 2.29 * t)
        add(when, fade(struck * np.exp(-33 * t), .003, .06), level)
    footfalls(15.40, 7, .39, .054)
    hit(21.28, .030, 148)
    hit(25.58, .063, 71)
    footfalls(30.06, 8, .48, .062)
    hit(33.15, .035, 107)
    hit(33.34, .026, 115)
    radio(35.38, [62, 65, 69, 67, 64, 60, 62, 57, 65, 63, 59], .020)
    radio(41.20, [59, 62, 69, 74, 71, 62], .021)
    for when in (43.61, 44.04, 47.20):
        t = samples(.29)
        carrier = np.sin(2 * np.pi * (194 * t + 12 * np.sin(9 * t)))
        rasp = np.tanh(1.8 * carrier + .63 * rng.normal(0, 1, len(t)))
        add(when, fade(rasp * np.exp(-11 * t), .014, .056), .114)
    footfalls(50.7, 16, .385, .066)
    for burst in (60.13, 61.74, 63.35, 64.96, 66.57):
        gain = .102 if burst < 61 else .145
        for pulse in range(4):
            t = samples(.112)
            tone = np.sin(2 * np.pi * 2130 * t) + .27 * np.sin(2 * np.pi * 4260 * t)
            add(burst + pulse * .152, fade(tone, .003, .016), gain)
    hit(58.61, .07, 62)
    mix = fade(np.tanh(mix * 1.13), .10, .33)
    out = ROOT / "motion" / "mix.wav"
    with wave.open(str(out), "wb") as output:
        output.setparams((1, 2, RATE, 0, "NONE", "not compressed"))
        output.writeframes((mix * 32767).astype("<i2").tobytes())
    return out


def mux(capture, mix):
    out = ROOT / "late_morning_motion_reel.mp4"
    pending = ROOT / "late_morning_motion_reel.partial.mp4"
    subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(), "-nostdin", "-hide_banner", "-loglevel", "error",
                    "-y", "-i", str(capture), "-i", str(mix), "-map", "0:v", "-map", "1:a",
                    "-vf", "scale=720:1280:flags=lanczos,setsar=1", "-c:v", "libx264", "-preset", "veryfast",
                    "-crf", "19", "-pix_fmt", "yuv420p", "-c:a", "aac", "-b:a", "160k",
                    "-movflags", "+faststart", "-shortest", str(pending)], check=True)
    pending.replace(out)
    print(out)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--capture", type=Path, help="Godot AVI to mux after building the audio.")
    args = parser.parse_args()
    soundtrack = build_mix()
    if args.capture:
        mux(args.capture, soundtrack)
