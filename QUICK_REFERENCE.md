# Ollama Quick Reference

## Script Commands

### Basic Operations

```bash
./ollama.sh start          # Start Ollama server
./ollama.sh stop           # Stop Ollama server
./ollama.sh restart        # Restart Ollama server
./ollama.sh status         # Show running status
./ollama.sh info           # Detailed system information
```

### Model Management

```bash
./ollama.sh models                    # List installed models
./ollama.sh pull <model>              # Download a model
./ollama.sh remove <model>            # Delete a model
./ollama.sh test ["prompt"]           # Test model inference
```

### Monitoring

```bash
./ollama.sh logs           # View Ollama logs (live)
./ollama.sh gpu            # Show GPU status
./ollama.sh gpu-watch      # Monitor GPU in real-time
./ollama.sh shell          # Open container shell
```

## Direct Docker Commands

### Container Management

```bash
docker-compose up -d              # Start Ollama
docker-compose down               # Stop Ollama
docker-compose restart ollama     # Restart Ollama
docker-compose logs -f ollama     # View logs
docker ps | grep ollama           # Check if running
```

### Model Operations

```bash
docker exec -it ollama ollama list                    # List models
docker exec -it ollama ollama pull qwen2.5-coder:7b  # Download model
docker exec -it ollama ollama rm qwen2.5-coder:7b    # Remove model
docker exec -it ollama ollama run qwen2.5-coder:7b   # Start interactive chat
```

### System Monitoring

```bash
nvidia-smi                           # GPU snapshot
watch -n 1 nvidia-smi               # GPU monitoring (live)
docker stats ollama                  # Container resource usage
docker exec -it ollama nvidia-smi   # GPU from inside container
```

## API Endpoints

### Check API Health

```bash
curl http://localhost:11434/api/version
curl http://localhost:11434/api/tags
```

### Generate Code

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "qwen2.5-coder:7b",
  "prompt": "Write a Python function to reverse a string",
  "stream": false
}'
```

### Chat Completion

```bash
curl http://localhost:11434/api/chat -d '{
  "model": "qwen2.5-coder:7b",
  "messages": [
    {"role": "user", "content": "How do I use async/await in JavaScript?"}
  ]
}'
```

## Continue Extension (VS Code)

### Keyboard Shortcuts

- `Ctrl+L` - Open Continue chat sidebar
- `Tab` - Accept code completion
- `Ctrl+I` - Inline edit (edit code in place)

### Configuration File

```bash
%USERPROFILE%\\.continue\\config.yaml
```

### Devstral Agent Config

```yaml
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

### Reload Continue

1. Open Continue sidebar
2. Click settings icon (gear)
3. Reload window after config changes

## Recommended Models

### For RTX 3060 12GB

| Model                 | Size  | Best For             | Pull Command                             |
| --------------------- | ----- | -------------------- | ---------------------------------------- |
| qwen2.5-coder:7b      | 4.7GB | General coding, fast | `./ollama.sh pull qwen2.5-coder:7b`      |
| qwen2.5-coder:14b     | 8GB   | Better reasoning     | `./ollama.sh pull qwen2.5-coder:14b`     |
| deepseek-coder-v2:16b | 10GB  | Advanced tasks       | `./ollama.sh pull deepseek-coder-v2:16b` |
| codellama:7b          | 4GB   | Meta's option        | `./ollama.sh pull codellama:7b`          |
| phi3.5:latest         | 2.3GB | Speed, small tasks   | `./ollama.sh pull phi3.5:latest`         |

## Troubleshooting

### Ollama Not Responding

```bash
./ollama.sh logs                     # Check logs
docker-compose restart ollama        # Restart service
docker exec -it ollama /bin/bash    # Debug inside container
```

### GPU Not Used

```bash
docker exec -it ollama nvidia-smi   # Check GPU access in container
./ollama.sh gpu                     # Check GPU on host
```

### Model Too Slow

```bash
./ollama.sh pull phi3.5:latest      # Try smaller model
./ollama.sh remove qwen2.5-coder:14b  # Free VRAM
```

### Continue Extension Issues

```bash
# Check Ollama API
curl http://localhost:11434/api/tags

# Edit Continue config
code /c/Users/<windows-user>/.continue/config.yaml

# Restart VS Code
```

## File Locations

| File              | Location                                     |
| ----------------- | -------------------------------------------- |
| Docker Compose    | `./docker-compose.yml`                       |
| Management Script | `./ollama.sh`                                |
| Continue Config   | `~/.continue/config.yaml`                    |
| Model Storage     | Docker volume: `local-dev-llm_ollama_models` |
| Project Docs      | `./PLAN.md`, `./README.md`                   |

## Useful Aliases

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
alias ollama="./ollama.sh"
alias ollama-start="./ollama.sh start"
alias ollama-stop="./ollama.sh stop"
alias ollama-status="./ollama.sh status"
alias ollama-models="./ollama.sh models"
alias ollama-gpu="./ollama.sh gpu"
```

Then use:

```bash
ollama start
ollama models
ollama gpu
```
