# Slopmaker — AI-Assisted 3D Storytelling and Animation Studio

Slopmaker is a completely agentic creative-production workspace for making short, narrated 3D stories. It brings together AI-assisted story writing, voice generation, reusable low-poly assets, Godot scene building, preview tools, and video-rendering workflows in an iterative agent-led production process.

The repository currently contains two narrative projects: **Late Morning**, a post-apocalyptic vertical short series, and **LINE 13**, a narrated horror pilot. It also includes **Qwen Voice Studio**, a local text-to-speech app used to create and revise voice tracks for those projects, along with character, environment, interior, and prop libraries.

> This is an evolving creator workspace, not a single packaged game or one-click production pipeline. Individual projects have their own scripts, setup requirements, and maturity levels.

## What’s in the project

### Qwen Voice Studio

A password-protected Gradio interface for generating speech with the Qwen3-TTS CustomVoice model. Write or paste narration, choose a supported speaker and language, add optional delivery direction, listen to the result, and download a WAV file. It runs inference on the local computer, using an available NVIDIA GPU or falling back to CPU.

The Windows launcher can optionally expose the local studio through a temporary Cloudflare Quick Tunnel. This has been useful for generating narration from another device and sharing a short-lived interface while a production session is running.

### Late Morning — narrated short series

A continuing story about Daniel Ward after a sudden disappearance empties his town. Episodes are developed as scripts and staged as vertical 3D reels in Godot. The production workflow combines custom scenes and props, Qwen-generated narration, sound effects, preview playback, and MP4 export.

Episode folders contain the project-specific scene, mix, and render instructions. The first four episode workspaces are:

- `series/late_morning/` — Episode 1 and its animated preview/export.
- `series/late_morning_02/` — Episode 2, including staged sets and capture/mix workflow.
- `series/late_morning_03/` — Episode 3, with a 75-second vertical reel workflow.
- `series/late_morning_04/` — Episode 4, with an 80-second vertical reel workflow.

Scripts and continuity notes live in `story/`. Each episode README is the source of truth for that episode’s exact preview, audio-mix, and export commands. The episodes use Godot and, depending on the episode, Python and FFmpeg.

### LINE 13 — narrated horror pilot

A separate vertical horror project set around 14 Old Bell Road. Its Godot 4 project stages a narrated cinematic pilot using custom environments, characters, lighting, shot timing, WAV narration, and subtitle cues. The story and production code are in `story/episode-01-line-13.md` and `godot/line_13/`.

Open `godot/line_13/project.godot` in Godot 4 to inspect or run the pilot. The project is configured for a 720 × 1280 portrait viewport. `tools/LIVE_REVIEW.md` explains the local live-review window and how to publish preview frames during asset work.

### Reusable 3D assets and builders

`assets/` contains source scripts, exported GLB models, and previews used across the story projects. Current libraries include a 13-character block-style roster, trees, home interiors, town storefronts and streets, and episode-specific props and set pieces. Some assets are designed as reusable production pieces; others are bespoke to a particular episode.

Use the README files within `assets/` for model inventories, scale/orientation notes, and rebuild commands. Builders may require project-specific Python packages or Godot; those dependencies are not all installed by the voice-studio launcher.

## How this workspace is used

The typical production loop is:

1. Draft or revise the story and narration in `story/` and the episode’s `narration.txt`.
2. Generate voice takes in Qwen Voice Studio, then save the chosen WAV and any timing or subtitle cues in the relevant project folder.
3. Build or adjust models and sets with the scripts in `assets/`, or arrange shots and animation in the episode’s Godot project.
4. Run the project’s live preview, review pacing, visuals, and sound, and make targeted revisions.
5. Capture the Godot sequence and use the episode’s audio/mix script and FFmpeg workflow to produce the vertical video export.

This reflects the current contents of the repository; each episode’s README documents its own variations and commands.

## Getting started: Qwen Voice Studio on Windows

The voice studio is the easiest entry point. It is currently designed around Windows and PowerShell.

### Requirements

- Windows 10 or 11
- Python 3.11, 3.12, or 3.13 (the launcher prefers Python 3.12 when using the `py` launcher)
- Internet access for first-run dependency, Cloudflare, and model downloads
- An NVIDIA GPU is recommended for practical generation speed; CPU mode is supported but may be slow

### Launch

From PowerShell in the repository directory, run:

```powershell
.\run_voice_studio.ps1
```

On first launch, the script creates `.venv`, downloads the official `cloudflared` executable, installs `requirements.txt`, and starts the app. Qwen downloads its model from Hugging Face when the app loads; these downloads can total several gigabytes. The terminal prints a temporary tunnel URL and a one-session password. Sign in with username `voice` and that password.

Press **Ctrl+C** in the same PowerShell window to stop the app and close the tunnel.

### Choose a model

The default is `Qwen/Qwen3-TTS-12Hz-0.6B-CustomVoice`. To select the larger 1.7B model for a session:

```powershell
$env:QWEN_TTS_MODEL = 'Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice'
.\run_voice_studio.ps1
```

The studio supports the speakers and languages provided by the selected model. Keep each text input at or below 1,800 characters; generate longer scripts in sections when needed.

## Network and privacy notes

The studio binds to `127.0.0.1`; the optional Quick Tunnel creates a temporary public route to that local app. The URL changes each run and stops working when the process exits. The app generates a random password per session and limits generation to one job at a time. Keep both the URL and password private while the tunnel is active because a visitor with access can submit text for inference on your computer.

Speech generation runs locally with the downloaded Qwen model; the app does not send text to a hosted speech-generation API. First-run setup connects to PyPI, Cloudflare’s official GitHub releases, and Hugging Face to install or download software and model files.

## Repository map

```text
app.py                         Qwen Voice Studio Gradio app
run_voice_studio.ps1           Windows setup and launch script
requirements.txt               Voice studio Python dependencies
qwen_voice_studio_cloudflare.ipynb  Notebook-based studio workflow
story/                         Story scripts and series continuity notes
series/                        Late Morning episode projects and previews
godot/line_13/                 LINE 13 Godot horror pilot
assets/                        Reusable models, builders, and previews
tools/                         Local live-review utilities
```

## Requirements by workflow

| Workflow | Main tools | Project instructions |
| --- | --- | --- |
| Generate narration | Windows, Python, PyTorch, Qwen3-TTS; CUDA GPU recommended | This README and `requirements.txt` |
| Preview or render LINE 13 | Godot 4; Python for review utilities | `godot/line_13/`, `tools/LIVE_REVIEW.md` |
| Preview or render Late Morning | Godot 4; episode-specific Python scripts; FFmpeg for documented exports | `series/<episode>/README.md` |
| Rebuild 3D asset kits | Godot and/or Python, depending on the builder | README files under `assets/` |

## Model and acknowledgements

Qwen Voice Studio uses the official [Qwen3-TTS project](https://github.com/QwenLM/Qwen3-TTS) and the [Qwen3-TTS 0.6B CustomVoice model](https://huggingface.co/Qwen/Qwen3-TTS-12Hz-0.6B-CustomVoice) by default. Review the model and dependency licenses and usage terms before redistributing generated outputs or bundled assets.

## Status

Slopmaker is a work in progress. The repository includes playable previews, rendered media, scripts, and asset-building experiments, but completeness and reproducibility vary by project and episode. Start with the README beside the project you want to work on.
