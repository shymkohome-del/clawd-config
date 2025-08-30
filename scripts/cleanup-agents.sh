#!/bin/bash
# scripts/cleanup-agents.sh
# Clean up all agent worktrees and processes

WORKTREE_DIR="worktrees"

cleanup_all_agents() {
    echo "🧹 Cleaning up Multi-Agent Development Environment..."
    
    # Stop all coordination servers
    echo "📡 Stopping coordination servers..."
    for agent_dir in "${WORKTREE_DIR}"/agent-*; do
        if [ -d "$agent_dir" ]; then
            local agent_name=$(basename "$agent_dir" | sed 's/agent-//')
            
            # Stop coordination server
            if [ -f "$agent_dir/.agent-coordination/server.pid" ]; then
                local pid=$(cat "$agent_dir/.agent-coordination/server.pid")
                kill "$pid" 2>/dev/null && echo "   Stopped server for $agent_name (PID: $pid)" || true
                rm -f "$agent_dir/.agent-coordination/server.pid"
            fi
            
            # Stop monitor process
            if [ -f "$agent_dir/.agent-coordination/monitor.pid" ]; then
                local pid=$(cat "$agent_dir/.agent-coordination/monitor.pid")
                kill "$pid" 2>/dev/null && echo "   Stopped monitor for $agent_name (PID: $pid)" || true
                rm -f "$agent_dir/.agent-coordination/monitor.pid"
            fi
        fi
    done
    
    # Stop dashboard server
    if [ -f "scripts/dashboard.pid" ]; then
        local pid=$(cat "scripts/dashboard.pid")
        kill "$pid" 2>/dev/null && echo "   Stopped dashboard server (PID: $pid)" || true
        rm -f "scripts/dashboard.pid"
    fi
    
    echo ""
    echo "🗑️  Removing agent worktrees..."
    
    # List current worktrees
    echo "   Current worktrees:"
    git worktree list | grep -E "agent-" || echo "   No agent worktrees found"
    
    # Remove each agent worktree
    for agent_dir in "${WORKTREE_DIR}"/agent-*; do
        if [ -d "$agent_dir" ]; then
            local agent_name=$(basename "$agent_dir" | sed 's/agent-//')
            
            echo "   Removing worktree for: $agent_name"
            
            # Get the branch name from the agent directory
            local branch_name=$(cd "$agent_dir" && git branch --show-current 2>/dev/null || echo "")
            
            # Remove the worktree
            git worktree remove "$agent_dir" --force 2>/dev/null || {
                echo "     Warning: Could not remove worktree cleanly, removing directory..."
                rm -rf "$agent_dir"
            }
            
            # Delete the branch if it exists
            if [ -n "$branch_name" ] && [ "$branch_name" != "main" ] && [ "$branch_name" != "develop" ]; then
                git branch -D "$branch_name" 2>/dev/null && echo "     Deleted branch: $branch_name" || true
            fi
        fi
    done
    
    # Remove worktree directory if empty
    if [ -d "$WORKTREE_DIR" ]; then
        rmdir "$WORKTREE_DIR" 2>/dev/null && echo "   Removed empty worktree directory" || true
    fi
    
    # Clean up any remaining coordination files
    echo ""
    echo "🧽 Cleaning up coordination files..."
    rm -f "scripts/coordination-dashboard.html"
    rm -f "scripts/dashboard.pid"
    
    echo ""
    echo "🔍 Final verification..."
    echo "   Remaining worktrees:"
    git worktree list
    
    echo ""
    echo "✅ Multi-Agent Development Environment Cleanup Complete!"
    echo ""
    echo "💡 To restart the multi-agent system:"
    echo "   1. bash scripts/setup-agent-worktrees.sh"
    echo "   2. bash scripts/spawn-multi-agent-ides.sh"
}

# Function to clean up specific agent
cleanup_single_agent() {
    local agent_name=$1
    local agent_dir="${WORKTREE_DIR}/agent-${agent_name}"
    
    if [ ! -d "$agent_dir" ]; then
        echo "❌ Agent worktree not found: $agent_name"
        return 1
    fi
    
    echo "🧹 Cleaning up agent: $agent_name"
    
    # Stop processes
    if [ -f "$agent_dir/.agent-coordination/server.pid" ]; then
        local pid=$(cat "$agent_dir/.agent-coordination/server.pid")
        kill "$pid" 2>/dev/null && echo "   Stopped server (PID: $pid)" || true
        rm -f "$agent_dir/.agent-coordination/server.pid"
    fi
    
    if [ -f "$agent_dir/.agent-coordination/monitor.pid" ]; then
        local pid=$(cat "$agent_dir/.agent-coordination/monitor.pid")
        kill "$pid" 2>/dev/null && echo "   Stopped monitor (PID: $pid)" || true
        rm -f "$agent_dir/.agent-coordination/monitor.pid"
    fi
    
    # Get branch name
    local branch_name=$(cd "$agent_dir" && git branch --show-current 2>/dev/null || echo "")
    
    # Remove worktree
    git worktree remove "$agent_dir" --force 2>/dev/null || {
        echo "   Warning: Could not remove worktree cleanly, removing directory..."
        rm -rf "$agent_dir"
    }
    
    # Delete branch
    if [ -n "$branch_name" ] && [ "$branch_name" != "main" ] && [ "$branch_name" != "develop" ]; then
        git branch -D "$branch_name" 2>/dev/null && echo "   Deleted branch: $branch_name" || true
    fi
    
    echo "✅ Agent $agent_name cleanup complete"
}

# Main execution
case "${1:-all}" in
    "all")
        cleanup_all_agents
        ;;
    *)
        if [ -n "$1" ]; then
            cleanup_single_agent "$1"
        else
            echo "Usage: $0 [all|agent-name]"
            echo "Examples:"
            echo "  $0 all                    # Clean up all agents"
            echo "  $0 feature-dev-1         # Clean up specific agent"
            exit 1
        fi
        ;;
esac