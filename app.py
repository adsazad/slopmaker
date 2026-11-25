"""Private-by-default, local Qwen3-TTS studio with an optional Cloudflare Quick Tunnel."""

from __future__ import annotations

import os
import secrets
import subprocess
import tempfile
import threading
import time
import uuid
from pathlib import Path

import gradio as gr
import soundfile as sf
import torch
from qwen_tts import Qwen3TTSModel


MODEL_ID = os.environ.get(
    "QWEN_TTS_MODEL", "Qwen/Qwen3-TTS-12Hz-0.6B-CustomVoice"
)
MAX_CHARACTERS = 1800
PORT = int(os.environ.get("VOICE_STUDIO_PORT", "7860"))

if torch.cuda.is_available():
    device_map = "cuda:0"
    dtype = torch.float16
    device_name = torch.cuda.get_device_name(0)
else:
    device_map = "cpu"
    dtype = torch.float32
    device_name = "CPU (generation may be slow)"

print(f"Loading {MODEL_ID} from Hugging Face on {device_name} …", flush=True)
tts = Qwen3TTSModel.from_pretrained(
    MODEL_ID,
    device_map=device_map,
    dtype=dtype,
    attn_implementation="sdpa",
)
speakers = tts.get_supported_speakers()
languages = ["Auto", *[x for x in tts.get_supported_languages() if x != "Auto"]]
print("Qwen3-TTS is ready.", flush=True)


def generate_speech(text: str, speaker: str, language: str, direction: str):
    text = (text or "").strip()
    if not text:
        raise gr.Error("Write a line of text before generating speech.")
    if len(text) > MAX_CHARACTERS:
        raise gr.Error(f"Keep each generation under {MAX_CHARACTERS:,} characters.")

    try:
        with torch.inference_mode():
            wavs, sample_rate = tts.generate_custom_voice(
                text=text,
                language=language,
                speaker=speaker,
                instruct=(direction.strip() or None),
            )
        output_path = Path(tempfile.gettempdir()) / f"qwen-voice-{uuid.uuid4().hex}.wav"
        sf.write(output_path, wavs[0], sample_rate)
        return str(output_path), str(output_path)
    except gr.Error:
        raise
    except Exception as exc:
        raise gr.Error(f"Speech generation failed: {exc}") from exc


CSS = """
#studio { max-width: 1120px; margin: 0 auto; }
.hero { padding: 24px 4px 12px; }
.hero h1 { font-size: 2.55rem; letter-spacing: -0.05em; margin: 0 0 6px; }
.hero p { font-size: 1rem; opacity: .76; }
.generate button { min-height: 52px; font-size: 1rem; font-weight: 700; }
"""

with gr.Blocks(
    theme=gr.themes.Soft(primary_hue="violet", secondary_hue="slate"),
    css=CSS,
    title="Qwen Voice Studio",
) as demo:
    with gr.Column(elem_id="studio"):
        gr.HTML(
            '<div class="hero"><h1>Qwen Voice Studio</h1>'
            "<p>Write a line. Choose a voice. Hear it come alive.</p></div>"
        )
        with gr.Row(equal_height=True):
            with gr.Column(scale=6):
                script = gr.Textbox(
                    label="Your script",
                    placeholder="Paste or write something to say …",
                    lines=9,
                    max_lines=18,
                    max_length=MAX_CHARACTERS,
                    value="Welcome to Qwen Voice Studio. Write a line, choose a voice, and bring your words to life.",
                )
                character_count = gr.Markdown("**0** characters")
                script.input(
                    lambda value: f"**{len(value or ''):,}** characters",
                    inputs=script,
                    outputs=character_count,
                )
                with gr.Row():
                    voice = gr.Dropdown(speakers, value="Ryan" if "Ryan" in speakers else speakers[0], label="Voice")
                    language = gr.Dropdown(languages, value="English" if "English" in languages else languages[0], label="Language")
                direction = gr.Textbox(
                    label="Delivery direction (optional)",
                    placeholder="For example: Warm and reassuring, with a gentle pace",
                    lines=2,
                )
                create = gr.Button("Generate speech", variant="primary", elem_classes=["generate"])
            with gr.Column(scale=5):
                gr.Markdown("### Your audio\nThe first generation may take a little longer while the model warms up.")
                preview = gr.Audio(label="Preview", type="filepath", interactive=False)
                download = gr.File(label="Download WAV", interactive=False)
                gr.Markdown("Tip: A speaker’s native language usually gives the most natural result.")
        create.click(
            generate_speech,
            inputs=[script, voice, language, direction],
            outputs=[preview, download],
        )


def run() -> None:
    cloudflared = os.environ.get("QWEN_CLOUDFLARED_BIN")
    if not cloudflared or not Path(cloudflared).is_file():
        raise SystemExit("cloudflared was not found. Start this app with run_voice_studio.ps1.")

    password = secrets.token_urlsafe(12)
    print("\nQwen Voice Studio is starting.", flush=True)
    print("Login username: voice", flush=True)
    print(f"One-session access password: {password}", flush=True)
    print("Keep that password private. Press Ctrl+C here to close the public link.\n", flush=True)

    tunnel = subprocess.Popen(
        [cloudflared, "tunnel", "--url", f"http://127.0.0.1:{PORT}"],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
    )

    def show_tunnel_output() -> None:
        assert tunnel.stdout is not None
        for line in tunnel.stdout:
            print(line.rstrip(), flush=True)

    threading.Thread(target=show_tunnel_output, daemon=True).start()
    try:
        demo.queue(default_concurrency_limit=1).launch(
            server_name="127.0.0.1",
            server_port=PORT,
            share=False,
            auth=("voice", password),
            show_api=False,
            show_error=True,
            prevent_thread_lock=True,
        )
        while tunnel.poll() is None:
            time.sleep(1)
        raise SystemExit("cloudflared stopped. The public URL is no longer available.")
    except KeyboardInterrupt:
        print("\nStopping the app and public tunnel …", flush=True)
    finally:
        if tunnel.poll() is None:
            tunnel.terminate()
            try:
                tunnel.wait(timeout=5)
            except subprocess.TimeoutExpired:
                tunnel.kill()
        demo.close()


if __name__ == "__main__":
    run()
