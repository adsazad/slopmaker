"""Time the Qwen narration, mix original sound effects, and export Episode 2."""
import argparse
import subprocess
import wave
from pathlib import Path

import imageio_ffmpeg
import numpy as np

ROOT = Path(__file__).resolve().parent
RATE = 24000
DURATION = 90
BEATS = ((.72, 11.25), (12.1, 24.75), (25.25, 39.05),
         (39.80, 55.30), (56.00, 71.45), (75.0, 89.15))
VOICE_WORDS = (29, 28, 39, 30, 27, 37)
FFMPEG = imageio_ffmpeg.get_ffmpeg_exe()


def read(path):
    pcm = subprocess.check_output([FFMPEG, "-v", "error", "-i", str(path), "-f", "f32le",
                                   "-ac", "1", "-ar", str(RATE), "-"])
    return np.frombuffer(pcm, dtype="<f4").copy()


def detect_boundaries(voice):
    """Choose five pauses near the expected paragraph boundaries."""
    hop = RATE // 100
    frames = voice[:len(voice)//hop*hop].reshape((-1, hop))
    rms = np.sqrt(np.mean(frames ** 2, axis=1))
    voiced = rms > max(.006, np.percentile(rms, 85)*.083)
    silence_changes = np.flatnonzero(np.diff(np.r_[False, ~voiced, False]))
    pauses = [((l+r)*.005, (r-l)*.01) for l,r in silence_changes.reshape(-1, 2) if r-l >= 24]
    duration = len(voice)/RATE
    expected = np.cumsum(VOICE_WORDS)[:-1] / sum(VOICE_WORDS) * duration
    boundaries = [0.]
    for index, transition in enumerate(expected):
        later = expected[index+1] if index+1 < len(expected) else duration
        earlier = expected[index-1] if index else 0.0
        options = [(p,g) for p,g in pauses if max(boundaries[-1]+3, (earlier+transition)*.5)
                   < p < (transition+later)*.5]
        cutoff = min(options, key=lambda v: (abs(v[0]-transition) - min(.95,v[1])*2.6))[0] if options else transition
        boundaries.append(cutoff)
    return boundaries + [duration]


def pace(clip, maximum):
    # Retain pitch when a paragraph needs a little less screen time.
    duration = len(clip)/RATE
    if duration <= maximum:
        return clip
    speed = duration/maximum
    filter_chain = []
    while speed > 2:
        filter_chain.append("atempo=2")
        speed /= 2
    filter_chain.append(f"atempo={speed:.6f}")
    out = subprocess.run([FFMPEG, "-v", "error", "-f", "f32le", "-ar", str(RATE), "-ac", "1",
                          "-i", "-", "-af", ",".join(filter_chain), "-f", "f32le", "-"],
                         input=clip.astype("<f4").tobytes(), capture_output=True, check=True)
    return np.frombuffer(out.stdout, dtype="<f4").copy()


def trim_edges(clip):
    active = np.flatnonzero(np.abs(clip) > .012)
    if len(active) == 0:
        return clip
    return clip[max(0,active[0]-int(.07*RATE)):min(len(clip),active[-1]+int(.10*RATE))]


def write_audio(voice_path, cuts, effects_only=False, draft=False):
    rng = np.random.default_rng(151)
    mix = np.zeros(RATE*DURATION)
    t = np.arange(len(mix))/RATE

    def sample(length):
        return np.arange(round(RATE*length))/RATE

    def add(start, data, gain=1.0, ramp=.011):
        place = round(start*RATE)
        size = min(len(data), len(mix)-place)
        u = np.arange(size)/RATE
        envelope = np.clip(u/ramp,0,1) * np.clip((size/RATE-u)/ramp,0,1)
        mix[place:place+size] += data[:size]*gain*envelope

    def hum(start, length, freq, gain):
        u = sample(length)
        tone = np.sin(2*np.pi*freq*u)+.17*np.sin(4*np.pi*freq*u)
        add(start,tone,gain,.016)

    def strike(start, sounds, gain, decay=19):
        u = sample(.48)
        signal = sum(np.sin(2*np.pi*f*u)*a for f,a in sounds)
        add(start,signal*np.exp(-decay*u),gain,.004)

    def footfall(start, gain):
        strike(start,[(64,1),(173,.35),(843,.09)],gain,24)

    def swish(start,length,gain):
        u = sample(length)
        noise = rng.normal(0,1,len(u))
        moving_air = np.convolve(noise,np.ones(24)/24,mode="same")
        add(start,moving_air*np.sin(np.pi*u/length)**2,gain)

    wind = np.convolve(rng.normal(0,1,len(mix)),np.ones(48)/48,mode="same")
    mix += wind*.012
    for at in (.10,.28):
        hum(at,.092,2130,.047)
    hum(.32,20.70,61,.019)
    hum(.32,20.70,121,.009)
    for at in (5.65,7.0,30.3,30.48,30.77):
        u=sample(.19)
        add(at,np.sin(2*np.pi*(2800*u-1400*u*u))*np.sin(np.pi*u/.19)**2,.023)
    for at in (12.05, 12.20, 12.35, 13.65, 13.80, 13.95):
        hum(at,.092,2130,.067)
    for i, note in enumerate((330,392,494,440,392,330,370,330)):
        strike(14.61+i*.28,[(note,.78),(note*2,.31)],.023,9)
    swish(15.80,.51,.044)
    swish(16.93,.45,.062)
    strike(20.98,[(56,1),(128,.4),(300,.28)],.140,24)
    strike(21.12,[(81,1)],.056,12)
    swish(28.6,2.80,.068)
    for hit in (36.66,36.74,36.86):
        strike(hit,[(991,1),(1680,.5),(2690,.4)],.047,35)
    for hit in (40.11,41.05,42.23,45.50):
        footfall(hit,.070)
    for at in (43.2,43.56,43.95,44.38):
        footfall(at,.038)
    strike(45.42,[(66,1),(205,.4),(735,.15)],.124)
    engine = sample(15.72)
    frequency = 32+33*np.clip(engine/3,0,1)-34*np.clip((engine-10)/5.72,0,1)
    phase = 2*np.pi*np.cumsum(frequency)/RATE
    engine_sound = np.sin(phase)+.42*np.sin(phase*2)+.21*np.sin(phase*3.02)
    add(45.30,engine_sound,.061,.34)
    for at,d in [(46.61,.95),(48.84,1.30),(51.12,.97),(55.32,.68),(57.04,1.53)]:
        swish(at,d,.087)
    strike(53.28,[(920,1)],.051,13)
    strike(60.78,[(58,1),(102,.36)],.086)
    for at in (64.19,64.70,65.47,66.74):
        strike(at,[(275,1),(969,.28)],.059,39)
    for i in range(13):
        footfall(67.15+i*.49,.053 if i<6 else .039)
    strike(70.34,[(958,.6),(1474,1),(2155,.27)],.079,7)
    strike(70.50,[(958,.6),(1474,1),(2155,.27)],.036,7)
    swish(81.95,.81,.076)
    hum(85.35,3.14,49,.022)
    strike(87.99,[(48,1),(110,.24)],.119,6)
    swish(88.78,.37,.082)

    if effects_only:
        print("Mixing sound effects for visual review.",flush=True)
    elif voice_path.exists():
        voice = read(voice_path)
        if len(voice) < 42 * RATE:
            raise ValueError("The narration WAV is too short for the six-beat episode.")
        boundaries = [0.,*cuts,len(voice)/RATE] if cuts else detect_boundaries(voice)
        if len(boundaries) != 7 or any(a >= b for a,b in zip(boundaries,boundaries[1:])):
            raise ValueError("Expected five increasing paragraph breaks inside the full narration.")
        for (start,end),(left,right) in zip(BEATS,zip(boundaries,boundaries[1:])):
            clip = trim_edges(voice[round(left*RATE):round(right*RATE)])
            clip = pace(clip,end-start)
            add(start,clip,.93,.016)
        print("Narration boundaries:", [round(b,2) for b in boundaries], flush=True)
    elif draft:
        for index,(start,end) in enumerate(BEATS,1):
            clip = trim_edges(read(ROOT/"audio"/f"beat_{index:02d}.wav"))
            add(start,pace(clip,end-start),.83,.016)
    else:
        raise FileNotFoundError(f"Save the revised narration as {voice_path}, or use --effects-only.")

    mix *= np.clip((DURATION-t)/.32,0,1)
    out = ROOT/"motion"/"mix.wav"
    with wave.open(str(out),"wb") as handle:
        handle.setparams((1,2,RATE,0,"NONE","not compressed"))
        handle.writeframes((np.tanh(mix*1.19)*32767).astype("<i2").tobytes())
    return out


def encode(capture, mix, out):
    temp = out.with_suffix(".partial.mp4")
    subprocess.run([FFMPEG,"-nostdin","-v","error","-y","-i",str(capture),"-i",str(mix),
                    "-map","0:v","-map","1:a","-vf","scale=720:1280:flags=lanczos,setsar=1,format=yuv420p",
                    "-c:v","libx264","-preset","veryfast","-crf","18","-c:a","aac","-b:a","160k",
                    "-t",str(DURATION),"-movflags","+faststart",str(temp)],check=True)
    temp.replace(out)
    print(out,flush=True)


if __name__ == "__main__":
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--capture",type=Path)
    parser.add_argument("--voice",type=Path,default=ROOT/"narration.wav")
    parser.add_argument("--cuts",type=float,nargs=5)
    parser.add_argument("--effects-only",action="store_true",help="Prepare an asset review mix while narration is pending.")
    parser.add_argument("--draft",action="store_true",help="Use locally recorded beats if the Qwen take is absent.")
    parser.add_argument("--output",type=Path,default=ROOT/"late_morning_episode_02.mp4")
    options=parser.parse_args()
    track=write_audio(options.voice,options.cuts,options.effects_only,options.draft)
    if options.capture:
        encode(options.capture,track,options.output)
