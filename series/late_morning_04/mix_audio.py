"""Build the 80-second narration and effects track for the Godot reel."""
from array import array
from math import exp, pi, sin
from pathlib import Path
import random
import sys
import wave

RATE = 24000
DURATION = 80
STARTS = [.35, 11.05, 23.50, 40.05, 53.65, 65.25]
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
        movement = min(1.0, max(0.0, (11 - t) / 2)) if t < 11 else min(1.0, max(0.0, (t - 72.5) / 3))
        phase += 2 * pi * (34 + movement * 24) / RATE
        noise = .985 * noise + .015 * rng.uniform(-1, 1)
        engine = movement * (sin(phase) * 350 + sin(phase * 2) * 100 + noise * 880)
        in_cab = t < 5.4 or 36.1 <= t < 40.1 or 67.3 < t < 76.2
        radio_level = .034 if in_cab else .002
        radio = static[int(i * static_rate / RATE) % len(static)] * radio_level
        sound[i] = engine + noise * 430 + radio

    for start, gain, frequency in [(12.5, 1200, 540), (14.6, 820, 1021),
                                  (22.5, 485, 430), (28.0, 720, 535),
                                  (33.1, 1100, 305), (33.62, 1050, 315),
                                  (34.15, 1040, 315), (34.67, 1020, 315),
                                  (35.19, 980, 315), (36.4, 910, 480),
                                  (66.45, 670, 1150), (72.6, 1300, 71)]:
        for index in range(RATE // 3):
            t = index / RATE
            sound[round(start * RATE) + index] += gain * exp(-19 * t) * sin(2 * pi * frequency * t)
    for _ in range(49):
        start = rng.uniform(39.65, 51.6)
        root = rng.uniform(680, 1780)
        duration = rng.uniform(.05, .19)
        for i in range(round(duration * RATE)):
            t = i / RATE
            window = sin(pi * t / duration) ** 2
            signal = sin(2 * pi * (root * t - 1000 * t * t))
            sound[round(start * RATE) + i] += window * signal * rng.uniform(280, 670)

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
