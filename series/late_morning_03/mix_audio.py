"""Build the 75-second narration and effects track for the Godot reel."""
from array import array
from math import exp, pi, sin
from pathlib import Path
import random
import sys
import wave

RATE = 24000
DURATION = 75
STARTS = [0.35, 10.0, 23.6, 32.7, 42.1, 52.9, 64.1]
ASSETS = Path(__file__).resolve().parent / "motion" / "assets"


def read_mono(path):
    with wave.open(str(path), "rb") as wav:
        channels = wav.getnchannels()
        rate = wav.getframerate()
        if wav.getsampwidth() != 2:
            raise ValueError(f"Expected 16-bit PCM for {path.name}")
        samples = array("h", wav.readframes(wav.getnframes()))
    if sys.byteorder != "little":
        samples.byteswap()
    return samples[::channels], rate


def main():
    static, static_rate = read_mono(ASSETS / "radio_static.wav")
    voices = []
    for index, start in enumerate(STARTS, 1):
        samples, rate = read_mono(ASSETS / f"voice_{index:02}.wav")
        if rate != RATE:
            raise ValueError(f"Expected {RATE} Hz for voice {index}")
        voices.append((round(start * RATE), samples))

    sound = array("f", [0]) * (RATE * DURATION)
    rng = random.Random(203)
    noise = 0.0
    phase = 0.0
    for i in range(len(sound)):
        t = i / RATE
        movement = max(0.0, min(1.0, 14 - t, (t - 62.5) * 3))
        if t < 14:
            movement = min(1.0, max(0.0, (14 - t) / 3))
        elif t >= 62.5:
            movement = min(1.0, (t - 62.5) / 3)
        phase += 2 * pi * (34 + movement * 24) / RATE
        noise = .985 * noise + .015 * rng.uniform(-1, 1)
        engine = movement * (sin(phase) * 350 + sin(phase * 2) * 100 + noise * 880)
        radio_level = .047 if t < 23 or t > 59 else .008
        if 56.4 <= t <= 60.0:
            radio_level += .045
        radio = static[int(i * static_rate / RATE) % len(static)] * radio_level
        sound[i] = engine + noise * 430 + radio

    for start, gain, frequency in [(14.7, 1350, 570), (24.3, 1050, 770), (25.1, 900, 470),
                                  (42.9, 520, 320), (48.8, 920, 195), (56.5, 950, 990),
                                  (62.5, 1400, 68)]:
        for index in range(RATE // 3):
            t = index / RATE
            sound[round(start * RATE) + index] += gain * exp(-19 * t) * sin(2 * pi * frequency * t)

    for offset, voice in voices:
        for index, value in enumerate(voice):
            sound[offset + index] += value * .84
    last = len(sound)
    pcm = array("h", (int(max(-32767, min(32767, x * min(1, (last - i) / RATE))))
                      for i, x in enumerate(sound)))
    if sys.byteorder != "little":
        pcm.byteswap()
    with wave.open(str(ASSETS / "mix.wav"), "wb") as output:
        output.setparams((1, 2, RATE, len(pcm), "NONE", "not compressed"))
        output.writeframes(pcm.tobytes())


if __name__ == "__main__":
    main()
