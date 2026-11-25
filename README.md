# Qwen Voice Studio

A local text-to-speech web app using Qwen3-TTS CustomVoice from Hugging Face. It launches a temporary Cloudflare Quick Tunnel so the password-protected interface can be reached over the internet while the app is running.

## Start on Windows

1. Install Python 3.12 (3.11–3.13 are also supported): [python.org/downloads/windows](https://www.python.org/downloads/windows/).
2. Open PowerShell in this folder and run:

   ```powershell
   .\run_voice_studio.ps1
   ```

3. On first start, the launcher downloads the official Cloudflare `cloudflared` executable and installs the Python packages. The app then downloads the model from Hugging Face. These downloads total several gigabytes.
4. Copy the temporary `https://…trycloudflare.com` address and the one-session password shown in the PowerShell window. Open the address from any device and sign in with username `voice`.
5. Press **Ctrl+C** in that same PowerShell window when finished. This stops the app and the public link.

## Hardware

The default model is `Qwen/Qwen3-TTS-12Hz-0.6B-CustomVoice`. It uses an NVIDIA GPU when PyTorch can see one; otherwise it falls back to CPU, which can be slow. To use the larger 1.7B model, set this before starting:

```powershell
$env:QWEN_TTS_MODEL = 'Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice'
.\run_voice_studio.ps1
```

## Internet access and privacy

Cloudflare Quick Tunnels are temporary and intended for demos. The link changes each time and stops working when the launcher exits. This app binds only to `127.0.0.1`, requires a random password for each run, allows one generation at a time, and limits text to 1,800 characters. Keep the URL and password private while the tunnel is running. Anyone who can access the link and password can use the app and your machine's available compute.

The app sends browser requests through Cloudflare Tunnel to this computer. Text-to-speech inference uses the downloaded Qwen model locally; the app does not call a hosted speech-generation API. Initial package and model downloads connect to PyPI, Cloudflare's official GitHub releases, and Hugging Face.

## Model

The interface uses Qwen's official `Qwen/Qwen3-TTS-12Hz-0.6B-CustomVoice` model and supports the built-in speakers and languages exposed by that model. See the [Qwen3-TTS repository](https://github.com/QwenLM/Qwen3-TTS) and [Hugging Face model card](https://huggingface.co/Qwen/Qwen3-TTS-12Hz-0.6B-CustomVoice).
