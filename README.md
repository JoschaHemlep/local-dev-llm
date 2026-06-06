# Local Development LLM

Run your own coding assistant locally using Ollama, Docker, and GPU acceleration.

## Quick Start

### 1. Prerequisites Setup (First Time Only)

Install NVIDIA CUDA and Docker with GPU support:

```bash
# Install CUDA toolkit
wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update
sudo apt-get -y install cuda-toolkit-12-6

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install NVIDIA Container Toolkit
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker

# Logout and login to apply Docker group membership
exit
```

### 2. Start Ollama

```bash
docker-compose up -d
```

### 3. Pull Your First Model

```bash
# Recommended: Qwen2.5-Coder 7B (latest stable, fast, excellent quality)
docker exec -it ollama ollama pull qwen2.5-coder:7b
```

### 4. Install Continue Extension in VS Code

1. Open VS Code
2. Install extension: **Continue** (by Continue)
3. The extension will auto-detect Ollama on `localhost:11434`
4. Start coding with AI assistance!

### 5. Enable Agent Tools With Devstral

If you want Continue to create and edit files in Agent mode with `devstral:latest`, use the global Continue config on the Windows side:

```yaml
name: Local Ollama Config
version: 1.0.0
schema: v1

models:
  - uses: ollama/devstral
    override:
      name: Devstral
      apiBase: http://localhost:11434
      capabilities:
        - tool_use
      roles:
        - chat
        - edit
        - apply
```

For this WSL + VS Code setup, the active Continue config is typically `%USERPROFILE%\\.continue\\config.yaml` on Windows, not the Linux `~/.continue/config.yaml` path inside WSL.

After changing the config:

1. Open the Command Palette
2. Run `Developer: Reload Window`
3. Re-select `Devstral` in Continue
4. Use Agent mode for file creation/edit requests

## Management Script (Recommended)

For easier management, use the included `ollama.sh` script:

```bash
# Make it executable (first time only)
chmod +x ollama.sh

# View all available commands
./ollama.sh help

# Common operations
./ollama.sh start              # Start Ollama
./ollama.sh status             # Check status
./ollama.sh models             # List installed models
./ollama.sh pull qwen2.5-coder:14b   # Download a model
./ollama.sh test "Write a function to sort arrays"   # Test model
./ollama.sh info               # Show detailed system info
./ollama.sh gpu                # Check GPU usage
./ollama.sh logs               # View live logs
```

The script provides human-readable commands with colored output and helpful error messages.

## Common Commands (Manual)

```bash
# List installed models
docker exec -it ollama ollama list

# Pull another model
docker exec -it ollama ollama pull deepseek-coder-v2:16b

# Remove a model
docker exec -it ollama ollama rm qwen2.5-coder:7b

# Check GPU usage
nvidia-smi

# View Ollama logs
docker-compose logs -f ollama

# Stop Ollama
docker-compose down
```

## Recommended Models for RTX 3060 12GB

| Model             | Size | Speed    | Quality    | Command                             |
| ----------------- | ---- | -------- | ---------- | ----------------------------------- |
| Qwen2.5-Coder     | 7B   | ⚡⚡⚡   | ⭐⭐⭐⭐⭐ | `ollama pull qwen2.5-coder:7b`      |
| Qwen2.5-Coder     | 14B  | ⚡⚡     | ⭐⭐⭐⭐⭐ | `ollama pull qwen2.5-coder:14b`     |
| DeepSeek-Coder-V2 | 16B  | ⚡⚡     | ⭐⭐⭐⭐⭐ | `ollama pull deepseek-coder-v2:16b` |
| CodeLlama         | 7B   | ⚡⚡⚡   | ⭐⭐⭐     | `ollama pull codellama:7b`          |
| Phi-3.5           | 3.8B | ⚡⚡⚡⚡ | ⭐⭐⭐     | `ollama pull phi3.5:latest`         |

## Documentation

- **[PLAN.md](PLAN.md)**: Complete research findings and implementation plan
- **[.copilot-instructions.md](.copilot-instructions.md)**: Instructions for AI agents working on this project

## System Requirements

- Windows 10/11 with WSL2
- NVIDIA GPU with 8GB+ VRAM
- Docker with NVIDIA container support
- 20GB+ free disk space (for models)

## Features

✅ Fully offline - no internet required for inference  
✅ Private - code never leaves your machine  
✅ Fast - GPU-accelerated inference  
✅ Free - no API costs  
✅ Easy model switching - try different models anytime  
✅ VS Code integration - inline completion and chat

## Troubleshooting

**Can't access GPU in Docker?**

```bash
docker run --rm --gpus all nvidia/cuda:12.6.0-base-ubuntu22.04 nvidia-smi
```

**Continue extension not connecting?**

```bash
curl http://localhost:11434/api/tags
```

**Continue Agent mode answers in plain chat and does not edit files?**

- Make sure the selected Continue model is `Devstral`
- Ensure the model has `capabilities: [tool_use]`
- Prefer the published `uses: ollama/devstral` block over a fully manual model stanza
- Reload VS Code after editing the Continue config
- Continue can fall back to system-message tools, but the model still needs to follow tool instructions reliably

**Out of disk space?**

```bash
docker exec -it ollama ollama list
docker exec -it ollama ollama rm <unused-model>
```

## Next Steps

1. Read [PLAN.md](PLAN.md) for detailed setup instructions
2. Try different models to find your favorite
3. Configure Continue extension for your workflow
4. Enjoy private, local AI coding assistance!
