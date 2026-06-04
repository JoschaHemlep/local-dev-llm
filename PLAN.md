# Local Development LLM Setup Plan

## Project Goal
Set up a local LLM running in Docker on WSL Ubuntu for VS Code development assistance as a GitHub Copilot alternative.

## System Specifications
- **OS**: Windows 10 Pro (WSL2 Ubuntu)
- **CPU**: Intel Core i7-14700KF (20 cores, 28 threads)
- **RAM**: 32GB
- **GPU**: NVIDIA GeForce RTX 3060 12GB GDDR6

---

## Research Findings

### 1. VS Code Integration Options

#### Primary Recommendation: Continue.dev Extension
- **Open-source** autopilot alternative to GitHub Copilot
- **Native Ollama support** - zero configuration needed
- Features:
  - Inline code completion
  - Chat interface in sidebar
  - Context-aware code suggestions
  - Supports multiple LLM providers simultaneously
  - Free and highly customizable

#### Alternative: Twinny Extension
- Lightweight VS Code extension
- Direct Ollama integration
- Simpler but less feature-rich than Continue

#### How It Works
```
VS Code (Continue Extension) → HTTP API → Ollama Server → LLM Model → GPU
```

### 2. LLM Runtime: Ollama

**Why Ollama is Excellent for This Use Case:**
- ✅ **Easy model switching**: `ollama pull <model>` and `ollama run <model>`
- ✅ **Automatic GPU detection**: Works with NVIDIA CUDA out of the box
- ✅ **Model quantization**: Automatically uses optimized formats (GGUF)
- ✅ **Low overhead**: Efficient serving with minimal resource usage
- ✅ **Great Docker support**: Official Docker images available
- ✅ **REST API**: Standard OpenAI-compatible endpoints
- ✅ **Model library**: 100+ pre-configured models

**Installation**: Single binary, no complex dependencies

### 3. Recommended Coding Models

**⚠️ Important Note: Qwen2.5-Coder vs Qwen3-Coder**

While Qwen3-Coder exists, it's **only available in 30B and 480B sizes** (19GB+ VRAM required), which exceeds the RTX 3060's 12GB VRAM capacity. Therefore, we're using **Qwen2.5-Coder**, which is:
- The latest **7B-sized** model from the Qwen series
- Optimized for your hardware (4.7GB VRAM usage)
- Excellent coding performance with fast inference
- The practical choice for RTX 3060 12GB

#### Top Tier (Recommended for Your Hardware)

| Model | Size | VRAM Usage | Strengths | Ollama Command |
|-------|------|------------|-----------|----------------|
| **Qwen2.5-Coder** ✅ | 7B | ~6-8GB | Best 7B coding model, latest practical gen, multilingual, fast | `ollama pull qwen2.5-coder:7b` |
| **Qwen2.5-Coder** | 14B | ~10-12GB | More capable, still fits in 12GB with quantization | `ollama pull qwen2.5-coder:14b` |
| **DeepSeek-Coder-V2** | 16B | ~10-12GB | Excellent code generation, strong reasoning | `ollama pull deepseek-coder-v2:16b` |

#### Also Excellent

| Model | Size | VRAM Usage | Strengths | Ollama Command |
|-------|------|------------|-----------|----------------|
| **CodeLlama** | 7B | ~6-8GB | Meta's solid performer, code completion focus | `ollama pull codellama:7b` |
| **CodeLlama** | 13B | ~9-11GB | Better reasoning than 7B | `ollama pull codellama:13b` |
| **CodeGemma** | 7B | ~6-8GB | Google's efficient model, good for multiple languages | `ollama pull codegemma:7b` |
| **Phi-3.5** | 3.8B | ~4GB | Microsoft's small but capable, very fast | `ollama pull phi3.5:latest` |
| **StarCoder2** | 7B | ~6-8GB | Strong open-source option from BigCode | `ollama pull starcoder2:7b` |

#### Performance Notes for RTX 3060 12GB
- **7B models**: Comfortable fit, fast inference (~30-50 tokens/sec)
- **14B-16B models**: Fits with 4-bit quantization, good speed (~15-25 tokens/sec)
- **32B+ models**: Won't fit, even with heavy quantization

### 4. Best Model Recommendation

**🏆 Using Qwen2.5-Coder 7B (INSTALLED):**
- Best 7B coding model available that fits your hardware
- Supports 92+ programming languages
- Excellent at code completion, debugging, and explanation
- Fast inference on your hardware (~30-50 tokens/sec)
- Can later upgrade to 14B if you want more capability
- **Note**: Qwen3-Coder exists but smallest version is 30B (19GB VRAM) - too large for RTX 3060

**DeepSeek-Coder-V2 16B as alternative:**
- Slightly better at complex reasoning
- Uses more VRAM, slightly slower
- Excellent for architectural discussions

### 5. Docker Setup Strategy

#### Why Docker?
- ✅ Clean isolation from host system
- ✅ Easy backup and portability
- ✅ Simple version management
- ✅ Consistent environment

#### GPU Passthrough Requirements
1. **NVIDIA Container Toolkit** (nvidia-docker2)
2. **CUDA drivers** on WSL2
3. **Docker configured** to use nvidia runtime

#### Docker Compose Setup
- Single `docker-compose.yml` for easy management
- Persistent volume for models (models are large, 4-8GB each)
- GPU passthrough configuration
- Port mapping for API access
- Environment variables for configuration

### 6. WSL2 Performance Analysis

**✅ KEEP IT ON WSL - You made the right choice!**

**Why WSL2 is Optimal:**
- **GPU Performance**: WSL2 has native CUDA support with near-native Linux performance
- **Docker Performance**: Better than Docker Desktop on Windows
- **File I/O**: As long as files stay on WSL filesystem (`/home/joscha/...`), performance is excellent
- **Linux Tooling**: Better ecosystem for LLM tools (Ollama, Docker)
- **Memory Management**: More efficient for LLM workloads

**Performance Comparison:**
```
WSL2 GPU Inference:  ~98-99% of native Linux performance
Windows GPU:         ~95-98% (with overhead from Windows)
WSL filesystem I/O:  Excellent (native ext4)
/mnt/c/ I/O:         Poor (avoid this)
```

**⚠️ Only move to Windows if:**
- You experience issues with GPU passthrough (unlikely)
- You need Windows-specific tools

---

## Implementation Plan

### Phase 1: Environment Setup (30 minutes)

1. **Install NVIDIA CUDA on WSL2**
   ```bash
   # Check if CUDA is already available
   nvidia-smi
   
   # If not, install CUDA toolkit
   wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-keyring_1.1-1_all.deb
   sudo dpkg -i cuda-keyring_1.1-1_all.deb
   sudo apt-get update
   sudo apt-get -y install cuda-toolkit-12-6
   ```

2. **Install Docker and NVIDIA Container Toolkit**
   ```bash
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
   ```

3. **Verify GPU Access**
   ```bash
   docker run --rm --gpus all nvidia/cuda:12.6.0-base-ubuntu22.04 nvidia-smi
   ```

### Phase 2: Ollama Docker Setup (15 minutes)

1. **Create docker-compose.yml**
   - Ollama service with GPU support
   - Persistent volume for models
   - Port 11434 exposed for API

2. **Start Ollama**
   ```bash
   docker-compose up -d
   ```

3. **Pull initial model**
   ```bash
   docker exec -it ollama ollama pull qwen2.5-coder:7b
   ```

### Phase 3: VS Code Integration (10 minutes)

1. **Install Continue Extension**
   - Open VS Code
   - Install "Continue" extension
   - Configure to use Ollama (auto-detects on localhost:11434)

2. **Test the setup**
   - Try inline completion
   - Test chat interface
   - Verify GPU utilization

### Phase 4: Model Management (Ongoing)

**Easy Model Switching:**
```bash
# Pull a new model
docker exec -it ollama ollama pull deepseek-coder-v2:16b

# List installed models
docker exec -it ollama ollama list

# Remove a model
docker exec -it ollama ollama rm qwen3-coder:7b

# Run a model (starts it)
docker exec -it ollama ollama run qwen3-coder:14b
```

**In Continue Extension:**
- Go to settings
- Add/switch models in the provider configuration
- Can configure multiple models for different tasks

---

## Project Structure

```
local-dev-llm/
├── docker-compose.yml          # Main orchestration file
├── .env                        # Environment variables (optional)
├── models/                     # Mounted volume for Ollama models (created by Docker)
├── PLAN.md                     # This file
├── .copilot-instructions.md    # AI agent instructions
└── README.md                   # Quick start guide
```

---

## Expected Resource Usage

### With Qwen2.5-Coder 7B (INSTALLED):
- **GPU VRAM**: 6-8GB
- **System RAM**: 4-6GB
- **Disk Space**: ~4.7GB per model
- **Inference Speed**: 30-50 tokens/second

### With Qwen2.5-Coder 14B:
- **GPU VRAM**: 10-12GB (close to limit)
- **System RAM**: 6-8GB
- **Disk Space**: ~8GB per model
- **Inference Speed**: 15-25 tokens/second

---

## Advantages of This Setup

1. **Easy Model Switching**: Single command to try different models
2. **No Cloud Dependency**: Fully offline, no API costs
3. **Privacy**: Code never leaves your machine
4. **Performance**: Local inference is fast with GPU
5. **Customization**: Full control over model behavior
6. **Cost**: Free (after hardware investment)
7. **Docker Isolation**: Clean, reproducible environment
8. **WSL2 Benefits**: Best of Linux and Windows

---

## Alternative Solutions Considered

### Why Not These?

| Solution | Why Not Selected |
|----------|------------------|
| **LM Studio** | GUI-focused, less automation, not Dockerized |
| **vLLM** | More complex setup, overkill for single-user |
| **llama.cpp** | Lower-level, Ollama provides better abstraction |
| **KoboldAI** | Gaming/creative writing focus, not coding-optimized |
| **Text Generation WebUI** | Heavier, more complex, UI overhead |
| **LocalAI** | Good alternative, but Ollama is more specialized |

**Ollama + Continue.dev** is the sweet spot for developer productivity.

---

## Next Steps

1. ✅ Review this plan
2. ⚡ Set up environment (Phase 1)
3. ⚡ Deploy Ollama container (Phase 2)
4. ⚡ Install Continue extension (Phase 3)
5. 🧪 Test with sample code
6. 📊 Monitor performance and adjust model if needed
7. 🔄 Experiment with other models

---

## Resources

- **Ollama**: https://ollama.ai
- **Continue.dev**: https://continue.dev
- **Qwen2.5-Coder**: https://huggingface.co/Qwen/Qwen2.5-Coder
- **Qwen3-Coder**: https://ollama.com/library/qwen3-coder (30B+ only, too large for RTX 3060)
- **DeepSeek-Coder**: https://github.com/deepseek-ai/DeepSeek-Coder
- **NVIDIA Container Toolkit**: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/

---

## How to Use Continue in VS Code

### Setup Verification

Before using Continue, verify your setup:

```bash
# Check Ollama is running
./ollama.sh status

# Verify model is installed
./ollama.sh models

# Test API endpoint
curl http://localhost:11434/api/tags
```

### Continue Extension Features

#### 1. Chat Interface (Primary Feature)

**How to Open:**
- Press `Ctrl+L` (Windows/Linux) or `Cmd+L` (Mac)
- Or click the Continue icon in the sidebar

**What You Can Do:**
- Ask coding questions: "How do I implement authentication in Express.js?"
- Request code generation: "Write a Python function to parse CSV files"
- Debug issues: "Why is my React component not re-rendering?"
- Explain code: Select code and ask "Explain this function"
- Get best practices: "What's the best way to handle errors in async Rust?"

**Example Prompts:**
```
- "Write a REST API endpoint for user registration in Node.js"
- "How do I use async/await in Python?"
- "Explain this regex pattern: ^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$"
- "Refactor this function to be more efficient"
- "Write unit tests for this class"
```

#### 2. Inline Code Completion (Tab Autocomplete)

**How It Works:**
- Start typing code in any file
- Continue automatically suggests completions (gray text)
- Press `Tab` to accept the suggestion
- Press `Esc` to dismiss

**Example:**
```python
# You type:
def calculate_fibonacci(

# Continue suggests:
def calculate_fibonacci(n: int) -> int:
    """Calculate the nth Fibonacci number."""
    if n <= 1:
        return n
    return calculate_fibonacci(n-1) + calculate_fibonacci(n-2)
```

#### 3. Code Actions (Right-Click Menu)

**How to Use:**
1. Select code in your editor
2. Right-click on the selection
3. Choose "Continue" from the context menu
4. Select an action:

**Available Actions:**
- **Edit** - Modify code based on your instructions
- **Explain** - Get a detailed explanation of the code
- **Fix** - Automatically fix bugs or issues
- **Optimize** - Improve performance or readability
- **Comment** - Add detailed comments
- **Write Tests** - Generate unit tests
- **Write Docstring** - Add documentation

#### 4. Inline Edit Mode

**How to Use:**
- Press `Ctrl+I` (Windows/Linux) or `Cmd+I` (Mac)
- Or select code and use "Continue > Edit" from right-click menu
- Type your instruction (e.g., "add error handling")
- Continue will modify the code in place

**Example Workflow:**
```python
# Original code:
def divide(a, b):
    return a / b

# Select the function, press Ctrl+I, type: "add error handling for division by zero"

# Result:
def divide(a, b):
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b
```

#### 5. Codebase Context (@-mentions)

**How to Use:**
In the chat interface, use `@` to reference:
- `@file` - Specific files
- `@folder` - Entire directories
- `@code` - Specific functions or classes
- `@docs` - Documentation

**Example:**
```
@app.py How do I add a new route to this file?
@src/components/ What patterns are used in these React components?
```

### Keyboard Shortcuts Reference

| Action | Windows/Linux | Mac |
|--------|---------------|-----|
| Open Chat | `Ctrl+L` | `Cmd+L` |
| Inline Edit | `Ctrl+I` | `Cmd+I` |
| Accept Suggestion | `Tab` | `Tab` |
| Reject Suggestion | `Esc` | `Esc` |
| New Chat | `Ctrl+Shift+L` | `Cmd+Shift+L` |

### Configuration

**Location:** `~/.continue/config.yaml`

**Current Configuration:**
```yaml
name: Local Ollama Config
version: 1.0.0
schema: v1
models:
  - title: Qwen2.5 Coder 7B
    provider: ollama
    model: qwen2.5-coder:7b
    apiBase: http://localhost:11434
    contextLength: 32768
    completionOptions:
      temperature: 0.2
      topP: 0.95
      topK: 50
```

**Edit Configuration:**
```bash
code ~/.continue/config.yaml
```

**After editing, reload VS Code:**
- Press `F1` or `Ctrl+Shift+P`
- Type "Reload Window"
- Press Enter

### Tips for Best Results

1. **Be Specific**: "Write a Python function to validate email addresses using regex" is better than "email validation"

2. **Provide Context**: Include file type, framework, or language: "In React TypeScript, how do I..."

3. **Iterate**: If the first response isn't perfect, ask follow-up questions: "Can you add error handling to that?"

4. **Use Code Selection**: Select problematic code and ask specific questions about it

5. **Check Generated Code**: Always review AI-generated code before using it in production

### Common Use Cases

#### Writing New Code
```
Prompt: "Write a Python class to handle database connections with connection pooling"
```

#### Debugging
```
1. Select the buggy code
2. Right-click > Continue > Fix
3. Or ask: "Why isn't this working? [paste error message]"
```

#### Learning
```
Prompt: "Explain the difference between Promise.all() and Promise.race() in JavaScript with examples"
```

#### Code Review
```
1. Select code
2. Ask: "Review this code for security issues and best practices"
```

#### Refactoring
```
1. Select code
2. Right-click > Continue > Optimize
3. Or ask: "Refactor this to use async/await instead of callbacks"
```

### Performance Expectations

With Qwen2.5-Coder 7B on RTX 3060:
- **Response Time**: 1-3 seconds for typical requests
- **Streaming**: Responses appear word-by-word (like ChatGPT)
- **Context**: Can handle up to 32,768 tokens (~24,000 words)
- **Speed**: ~30-50 tokens/second generation

### Troubleshooting

**Continue Not Responding?**
```bash
./ollama.sh status  # Check Ollama is running
./ollama.sh logs    # Check for errors
```

**Completions Too Slow?**
- Try smaller model: `./ollama.sh pull phi3.5:latest`
- Update config to use phi3.5 instead

**Wrong Answers?**
- Try rephrasing your question
- Provide more context
- Use code selection to give specific examples

**Extension Not Loading?**
1. Restart VS Code
2. Check extension is enabled: Extensions panel > Continue
3. Check configuration: `~/.continue/config.yaml`

### Advanced: Using Multiple Models

You can configure Continue to use different models for different tasks:

```yaml
models:
  - title: Qwen2.5 Coder 7B (Fast)
    provider: ollama
    model: qwen2.5-coder:7b
    apiBase: http://localhost:11434
  
  - title: DeepSeek Coder 16B (Advanced)
    provider: ollama
    model: deepseek-coder-v2:16b
    apiBase: http://localhost:11434
```

Then switch models in the Continue chat interface dropdown.

---

**Status**: ✅ SETUP COMPLETE (as of June 4, 2026)
**Estimated Setup Time**: 1 hour
**Maintenance**: Low (occasional model updates)
