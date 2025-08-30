#!/bin/bash
# scripts/monitor-agent-activity.sh
# Real-time monitoring of all agent activity across worktrees

WORKTREE_DIR="worktrees"

monitor_all_agents() {
    echo "👀 Multi-Agent Activity Monitor Starting..."
    echo "   Monitoring all agent worktrees in real-time"
    echo "   Press Ctrl+C to stop"
    echo ""
    
    while true; do
        clear
        echo "🤖 MULTI-AGENT DEVELOPMENT MONITOR - $(date)"
        echo "=================================================="
        echo ""
        
        # Monitor each agent
        for agent_worktree in "${WORKTREE_DIR}"/agent-*; do
            if [ -d "$agent_worktree" ]; then
                local agent_name=$(basename "$agent_worktree" | sed 's/agent-//')
                monitor_single_agent "$agent_name" "$agent_worktree"
                echo ""
            fi
        done
        
        # Show overall system status
        show_system_overview
        
        sleep 5
    done
}

monitor_single_agent() {
    local agent_name=$1
    local worktree_path=$2
    
    echo "🤖 Agent: $agent_name"
    echo "   Path: $worktree_path"
    
    # Git status
    local git_status=$(cd "$worktree_path" && git status --porcelain 2>/dev/null || echo "")
    if [ -n "$git_status" ]; then
        echo "   📝 Modified Files:"
        echo "$git_status" | while read line; do
            if [ -n "$line" ]; then
                echo "      $line"
            fi
        done
    else
        echo "   📝 No pending changes"
    fi
    
    # Branch info
    local branch=$(cd "$worktree_path" && git branch --show-current 2>/dev/null || echo "unknown")
    local commits_ahead=$(cd "$worktree_path" && git rev-list --count HEAD ^origin/main 2>/dev/null || echo "0")
    echo "   🌿 Branch: $branch ($commits_ahead commits ahead of main)"
    
    # Recent activity
    local last_commit=$(cd "$worktree_path" && git log -1 --format="%h %s (%ar)" 2>/dev/null || echo "No commits")
    echo "   ⏰ Last Commit: $last_commit"
    
    # Agent status from coordination file
    local status_file="$worktree_path/.agent-coordination/status.json"
    if [ -f "$status_file" ]; then
        if command -v jq >/dev/null 2>&1; then
            local agent_status=$(jq -r '.status' "$status_file" 2>/dev/null || echo "unknown")
            local current_task=$(jq -r '.current_task // "None"' "$status_file" 2>/dev/null || echo "None")
            echo "   🎯 Status: $agent_status"
            echo "   📋 Current Task: $current_task"
        else
            echo "   🎯 Status: available (jq not installed)"
        fi
    fi
    
    # Check for coordination messages
    local messages_dir="$worktree_path/.agent-coordination/messages"
    if [ -d "$messages_dir" ]; then
        local message_count=$(find "$messages_dir" -name "*.json" 2>/dev/null | wc -l | tr -d ' ')
        if [ "$message_count" -gt 0 ]; then
            echo "   💬 Coordination Messages: $message_count unread"
        fi
    fi
    
    # Performance indicators
    local file_count=$(find "$worktree_path" -name "*.dart" 2>/dev/null | wc -l | tr -d ' ')
    local test_count=$(find "$worktree_path/test" -name "*.dart" 2>/dev/null | wc -l | tr -d ' ')
    echo "   📊 Dart Files: $file_count | Test Files: $test_count"
}

show_system_overview() {
    echo "=================================================="
    echo "🌐 SYSTEM OVERVIEW"
    echo ""
    
    # Git worktree list
    echo "📁 Active Worktrees:"
    git worktree list 2>/dev/null | while read line; do
        if [ -n "$line" ]; then
            echo "   $line"
        fi
    done
    echo ""
    
    # Resource usage (macOS specific)
    echo "💻 System Resources:"
    if command -v top >/dev/null 2>&1; then
        local cpu_usage=$(top -l 1 -n 0 | grep "CPU usage" 2>/dev/null | head -1 || echo "CPU: N/A")
        local mem_usage=$(top -l 1 -n 0 | grep "PhysMem" 2>/dev/null | head -1 || echo "Memory: N/A")
        echo "   $cpu_usage"
        echo "   $mem_usage"
    else
        echo "   System info not available"
    fi
    echo ""
    
    # VS Code processes
    local vscode_processes=$(pgrep -f "Code.*crypto_market" 2>/dev/null | wc -l | tr -d ' ')
    echo "🖥️  Active VS Code Instances: $vscode_processes"
    echo ""
    
    # Coordination dashboard
    echo "📊 Coordination Dashboard: http://localhost:8080/scripts/coordination-dashboard.html"
    echo ""
    echo "⏰ Next update in 5 seconds..."
}

# Cleanup function
cleanup() {
    echo ""
    echo "🛑 Stopping agent monitoring..."
    exit 0
}

trap cleanup SIGINT SIGTERM

# Main execution
monitor_all_agents