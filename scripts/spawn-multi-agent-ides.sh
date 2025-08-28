#!/bin/bash
# scripts/spawn-multi-agent-ides.sh
# Launches multiple VS Code instances, one for each agent worktree

set -e

WORKTREE_DIR="worktrees"
AGENTS=("feature-dev-1" "bug-fixer-1" "test-engineer-1" "refactor-specialist-1" "doc-writer-1")

echo "🚀 Spawning Multiple IDE Instances for Multi-Agent Development..."

# Function to launch VS Code for an agent
launch_agent_ide() {
    local agent_name=$1
    local worktree_path="${WORKTREE_DIR}/agent-${agent_name}"
    
    if [ ! -d "$worktree_path" ]; then
        echo "❌ Worktree not found for agent: $agent_name"
        echo "   Run: bash scripts/setup-agent-worktrees.sh first"
        return 1
    fi
    
    echo "💻 Launching VS Code for Agent: $agent_name"
    echo "   Workspace: $worktree_path"
    
    # Launch VS Code with agent-specific configuration
    code "$worktree_path" \
        --new-window \
        --goto "$worktree_path/lib/main.dart:1:1" &
    
    # Wait a moment between launches to prevent resource conflicts
    sleep 2
    
    echo "✅ VS Code launched for Agent: $agent_name"
}

# Function to setup agent coordination server
setup_agent_coordination() {
    echo "📡 Setting up agent coordination servers..."
    
    for agent in "${AGENTS[@]}"; do
        local port=$(get_agent_port "$agent")
        local worktree_path="${WORKTREE_DIR}/agent-${agent}"
        
        # Start coordination server for this agent
        (
            cd "$worktree_path"
            python3 -m http.server "$port" --bind 127.0.0.1 > /dev/null 2>&1 &
            echo $! > ".agent-coordination/server.pid"
        ) 2>/dev/null
        
        echo "   Agent $agent coordination server: http://localhost:$port"
    done
}

# Function to start agent activity monitors
start_agent_monitors() {
    echo "👀 Starting agent activity monitors..."
    
    for agent in "${AGENTS[@]}"; do
        local worktree_path="${WORKTREE_DIR}/agent-${agent}"
        
        # Start file system monitor for this agent
        (
            cd "$worktree_path"
            bash "../scripts/monitor-single-agent.sh" "$agent" > /dev/null 2>&1 &
            echo $! > ".agent-coordination/monitor.pid"
        ) 2>/dev/null || true
    done
}

# Helper function to get agent port
get_agent_port() {
    case $1 in
        "feature-dev-1") echo "3001" ;;
        "bug-fixer-1") echo "3002" ;;
        "test-engineer-1") echo "3003" ;;
        "refactor-specialist-1") echo "3004" ;;
        "doc-writer-1") echo "3005" ;;
        *) echo "3000" ;;
    esac
}

# Function to open coordination dashboard
open_coordination_dashboard() {
    echo "📊 Opening coordination dashboard..."
    
    # Start dashboard server
    python3 -m http.server 8080 > /dev/null 2>&1 &
    DASHBOARD_PID=$!
    echo $DASHBOARD_PID > "scripts/dashboard.pid"
    
    sleep 2
    
    # Open dashboard in browser
    if command -v open >/dev/null 2>&1; then
        open "http://localhost:8080/scripts/coordination-dashboard.html" 2>/dev/null || true
    elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "http://localhost:8080/scripts/coordination-dashboard.html" 2>/dev/null || true
    else
        echo "   Dashboard available at: http://localhost:8080/scripts/coordination-dashboard.html"
    fi
    
    echo "   Dashboard PID: $DASHBOARD_PID"
}

# Function to update agent statuses
update_agent_statuses() {
    for agent in "${AGENTS[@]}"; do
        local worktree_path="${WORKTREE_DIR}/agent-${agent}"
        local status_file="$worktree_path/.agent-coordination/status.json"
        
        if [ -f "$status_file" ] && command -v jq >/dev/null 2>&1; then
            # Update timestamp
            local temp_file=$(mktemp)
            jq --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
               '.last_update = $timestamp | .last_update_readable = ($timestamp | strptime("%Y-%m-%dT%H:%M:%SZ") | strftime("%Y-%m-%d %H:%M:%S"))' \
               "$status_file" > "$temp_file" 2>/dev/null || cp "$status_file" "$temp_file"
            mv "$temp_file" "$status_file"
        fi
    done
}

# Cleanup function
cleanup_agents() {
    echo ""
    echo "🛑 Shutting down multi-agent system..."
    
    # Stop coordination servers
    for agent in "${AGENTS[@]}"; do
        local worktree_path="${WORKTREE_DIR}/agent-${agent}"
        
        if [ -f "$worktree_path/.agent-coordination/server.pid" ]; then
            kill $(cat "$worktree_path/.agent-coordination/server.pid") 2>/dev/null || true
            rm -f "$worktree_path/.agent-coordination/server.pid"
        fi
        
        if [ -f "$worktree_path/.agent-coordination/monitor.pid" ]; then
            kill $(cat "$worktree_path/.agent-coordination/monitor.pid") 2>/dev/null || true
            rm -f "$worktree_path/.agent-coordination/monitor.pid"
        fi
    done
    
    # Stop dashboard server
    if [ -f "scripts/dashboard.pid" ]; then
        kill $(cat "scripts/dashboard.pid") 2>/dev/null || true
        rm -f "scripts/dashboard.pid"
    fi
    
    echo "✅ Multi-agent system shut down complete"
    exit 0
}

# Main execution
main() {
    echo "🌟 Multi-Agent IDE Spawning Process Starting..."
    
    # Verify worktrees exist
    if [ ! -d "$WORKTREE_DIR" ]; then
        echo "❌ Worktrees not found. Run setup first:"
        echo "   bash scripts/setup-agent-worktrees.sh"
        exit 1
    fi
    
    # Setup coordination infrastructure
    setup_agent_coordination
    start_agent_monitors
    
    echo ""
    echo "🚀 Launching VS Code instances for each agent..."
    echo ""
    
    # Launch IDE for each agent
    for agent in "${AGENTS[@]}"; do
        launch_agent_ide "$agent"
        echo ""
    done
    
    # Open coordination dashboard
    open_coordination_dashboard
    
    echo ""
    echo "🎉 Multi-Agent Development Environment Ready!"
    echo ""
    echo "📊 Coordination Dashboard: http://localhost:8080/scripts/coordination-dashboard.html"
    echo "📁 Active Worktrees:"
    git worktree list
    echo ""
    echo "🤖 Active Agents:"
    for agent in "${AGENTS[@]}"; do
        echo "   - $agent (Port: $(get_agent_port $agent))"
    done
    echo ""
    echo "💡 Pro Tips:"
    echo "   - Each VS Code window is a different agent"
    echo "   - Agents work on separate branches automatically"
    echo "   - Use the dashboard to monitor all agents"
    echo "   - Run 'bash scripts/cleanup-agents.sh' when done"
    echo ""
    
    # Keep script running to maintain coordination
    echo "🔄 Coordination system running... Press Ctrl+C to stop all agents"
    trap cleanup_agents SIGINT SIGTERM
    
    while true; do
        sleep 30
        update_agent_statuses
    done
}

# Execute main function
main "$@"