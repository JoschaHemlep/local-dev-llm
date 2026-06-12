#!/bin/bash

# Ollama Management Script
# Human-readable shortcuts for common Ollama operations

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Helper function to print colored output
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Function to check if Ollama container is running
is_running() {
    docker ps --filter "name=ollama" --format "{{.Names}}" | grep -q "ollama"
}

# Commands

cmd_start() {
    print_info "Starting Ollama server..."
    docker-compose up -d
    sleep 2
    if is_running; then
        print_success "Ollama is running"
        cmd_status
    else
        print_error "Failed to start Ollama"
        exit 1
    fi
}

cmd_stop() {
    print_info "Stopping Ollama server..."
    docker-compose down
    print_success "Ollama stopped"
}

cmd_restart() {
    print_info "Restarting Ollama server..."
    docker-compose restart ollama
    sleep 2
    print_success "Ollama restarted"
}

cmd_status() {
    if is_running; then
        print_success "Ollama is running"
        docker ps --filter "name=ollama" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        echo ""
        print_info "API Version:"
        curl -s http://localhost:11434/api/version 2>/dev/null || echo "API not responding"
        echo ""
    else
        print_warning "Ollama is not running"
        echo "Run: ./ollama.sh start"
    fi
}

cmd_models() {
    print_info "Installed models:"
    if is_running; then
        docker exec -it ollama ollama list
    else
        print_error "Ollama is not running. Start it first: ./ollama.sh start"
        exit 1
    fi
}

cmd_pull() {
    if [ -z "$1" ]; then
        print_error "Usage: ./ollama.sh pull <model-name>"
        echo ""
        echo "Examples:"
        echo "  ./ollama.sh pull qwen2.5-coder:7b"
        echo "  ./ollama.sh pull deepseek-coder-v2:16b"
        echo "  ./ollama.sh pull codellama:7b"
        echo "  ./ollama.sh pull phi3.5:latest"
        exit 1
    fi
    
    print_info "Pulling model: $1"
    docker exec -it ollama ollama pull "$1"
    print_success "Model $1 downloaded successfully"
}

cmd_remove() {
    if [ -z "$1" ]; then
        print_error "Usage: ./ollama.sh remove <model-name>"
        echo ""
        echo "First, list models to see what's installed:"
        echo "  ./ollama.sh models"
        exit 1
    fi
    
    print_warning "Removing model: $1"
    docker exec -it ollama ollama rm "$1"
    print_success "Model $1 removed"
}

cmd_test() {
    local prompt="${1:-Write a Python hello world function}"
    
    if ! is_running; then
        print_error "Ollama is not running. Start it first: ./ollama.sh start"
        exit 1
    fi
    
    print_info "Testing model with prompt: $prompt"
    echo ""
    
    curl -s http://localhost:11434/api/generate -d "{
        \"model\": \"qwen2.5-coder:7b\",
        \"prompt\": \"$prompt\",
        \"stream\": false
    }" | grep -o '"response":"[^"]*"' | sed 's/"response":"//;s/"$//' | sed 's/\\n/\n/g'
    
    echo ""
    print_success "Test complete"
}

cmd_logs() {
    print_info "Showing Ollama logs (Ctrl+C to exit)..."
    docker-compose logs -f ollama
}

cmd_gpu() {
    print_info "GPU Status:"
    nvidia-smi
}

cmd_gpu_watch() {
    print_info "Monitoring GPU (Ctrl+C to exit)..."
    watch -n 1 nvidia-smi
}

cmd_shell() {
    print_info "Opening shell in Ollama container..."
    docker exec -it ollama /bin/bash
}

cmd_info() {
    echo ""
    print_info "Ollama Setup Information"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if is_running; then
        print_success "Status: Running"
    else
        print_warning "Status: Stopped"
    fi
    
    echo ""
    echo "Container: ollama"
    echo "API Endpoint: http://localhost:11434"
    echo "Continue Config (Windows VS Code): %USERPROFILE%\\.continue\\config.yaml"
    echo "Continue Config (WSL path example): /c/Users/<windows-user>/.continue/config.yaml"
    echo ""
    
    if is_running; then
        echo "Installed Models:"
        docker exec ollama ollama list 2>/dev/null || echo "  (none)"
        echo ""
        
        echo "Resource Usage:"
        nvidia-smi --query-gpu=memory.used,memory.total,utilization.gpu,temperature.gpu --format=csv,noheader,nounits | \
        awk -F', ' '{printf "  GPU Memory: %s / %s MB\n  GPU Utilization: %s%%\n  Temperature: %s°C\n", $1, $2, $3, $4}'
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

cmd_help() {
    cat << 'EOF'

🤖 Ollama Management Script

USAGE:
  ./ollama.sh <command> [arguments]

BASIC COMMANDS:
  start              Start Ollama server
  stop               Stop Ollama server
  restart            Restart Ollama server
  status             Show Ollama status
  info               Show detailed system information

MODEL MANAGEMENT:
  models             List installed models
  pull <model>       Download a new model
  remove <model>     Remove an installed model
  test [prompt]      Test model with a prompt

MONITORING:
  logs               Show Ollama logs (live)
  gpu                Show current GPU status
  gpu-watch          Monitor GPU in real-time
  shell              Open shell in Ollama container

EXAMPLES:
  ./ollama.sh start
  ./ollama.sh pull qwen2.5-coder:14b
  ./ollama.sh test "Write a Rust fibonacci function"
  ./ollama.sh models
  ./ollama.sh gpu
  ./ollama.sh info

RECOMMENDED MODELS:
  qwen2.5-coder:7b        - Best balance (7B, fast)
  qwen2.5-coder:14b       - More capable (14B, slower)
  deepseek-coder-v2:16b   - Advanced reasoning (16B)
  codellama:7b            - Meta's solid option (7B)
  phi3.5:latest           - Very fast, smaller (3.8B)

For more information, see README.md

EOF
}

# Main command router
case "${1:-help}" in
    start)
        cmd_start
        ;;
    stop)
        cmd_stop
        ;;
    restart)
        cmd_restart
        ;;
    status)
        cmd_status
        ;;
    models|list)
        cmd_models
        ;;
    pull|download)
        cmd_pull "$2"
        ;;
    remove|rm|delete)
        cmd_remove "$2"
        ;;
    test)
        cmd_test "$2"
        ;;
    logs)
        cmd_logs
        ;;
    gpu)
        cmd_gpu
        ;;
    gpu-watch|watch)
        cmd_gpu_watch
        ;;
    shell|bash)
        cmd_shell
        ;;
    info)
        cmd_info
        ;;
    help|--help|-h)
        cmd_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo "Run './ollama.sh help' for usage information"
        exit 1
        ;;
esac
