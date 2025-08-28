# 🌳 GIT WORKTREES + MULTI-IDE MULTI-AGENT SYSTEM
# Revolutionary Parallel Development with Git Worktrees and Multiple IDE Instances

## 🎯 THE BRILLIANT APPROACH

Using **Git Worktrees + Multiple IDE Instances** for multi-agent development is absolutely genius because:

- **Perfect Isolation**: Each agent works in completely separate directory
- **Shared Git History**: All worktrees share the same .git, so changes are immediately visible
- **Multiple VS Code Instances**: Each agent gets its own IDE instance  
- **Real-time Coordination**: Agents can see each other's work through Git
- **Natural Branch Management**: Each worktree is automatically on different branch
- **Zero Conflicts**: Physical separation prevents most conflicts
- **Easy Monitoring**: You can literally watch agents work in real-time

## 🏗️ ARCHITECTURE OVERVIEW

```
crypto_market/                          # Main repository
├── .git/                              # Shared Git database
├── main-workspace/                    # Main development (your normal work)
│   ├── lib/
│   ├── pubspec.yaml
│   └── ...
├── worktrees/
│   ├── agent-feature-dev-1/          # Agent 1 worktree
│   │   ├── lib/                      # Same files, different branch
│   │   ├── pubspec.yaml
│   │   └── .vscode/                  # Agent-specific VS Code settings
│   ├── agent-bug-fixer-1/            # Agent 2 worktree  
│   │   ├── lib/
│   │   ├── pubspec.yaml
│   │   └── .vscode/
│   └── agent-test-engineer-1/        # Agent 3 worktree
│       ├── lib/
│       ├── pubspec.yaml
│       └── .vscode/
└── scripts/
    ├── setup-agent-worktrees.sh      # Setup script
    ├── spawn-multi-agent-ides.sh     # Launch multiple IDEs
    └── monitor-agent-activity.sh     # Real-time monitoring
```

## 🚀 COMPLETE IMPLEMENTATION

### Step 1: Worktree Setup Script

```bash
#!/bin/bash
# scripts/setup-agent-worktrees.sh
# Sets up Git worktrees for multi-agent development

set -e

MAIN_BRANCH="develop"
WORKTREE_DIR="worktrees"
AGENTS=("feature-dev-1" "bug-fixer-1" "test-engineer-1" "refactor-specialist-1" "doc-writer-1")

echo "🌳 Setting up Git Worktrees for Multi-Agent Development..."

# Create worktree directory
mkdir -p "$WORKTREE_DIR"

# Function to create agent worktree
create_agent_worktree() {
    local agent_name=$1
    local branch_name="agent-${agent_name}-$(date +%s)"
    local worktree_path="${WORKTREE_DIR}/agent-${agent_name}"
    
    echo "📁 Creating worktree for agent: $agent_name"
    
    # Create new branch from develop
    git checkout "$MAIN_BRANCH"
    git pull origin "$MAIN_BRANCH"
    git checkout -b "$branch_name"
    
    # Create worktree
    git worktree add "$worktree_path" "$branch_name"
    
    # Setup agent-specific configuration
    setup_agent_workspace "$agent_name" "$worktree_path" "$branch_name"
    
    echo "✅ Agent $agent_name worktree created at: $worktree_path"
    echo "   Branch: $branch_name"
}

# Function to setup agent workspace
setup_agent_workspace() {
    local agent_name=$1
    local worktree_path=$2
    local branch_name=$3
    
    # Create agent-specific VS Code settings
    mkdir -p "$worktree_path/.vscode"
    
    # Agent-specific VS Code settings
    cat > "$worktree_path/.vscode/settings.json" << EOF
{
  "window.title": "🤖 Agent: $agent_name - \${workspaceFolderBasename}",
  "workbench.colorTheme": "$(get_agent_theme $agent_name)",
  "workbench.colorCustomizations": {
    "titleBar.activeBackground": "$(get_agent_color $agent_name)",
    "titleBar.activeForeground": "#ffffff",
    "statusBar.background": "$(get_agent_color $agent_name)",
    "statusBar.foreground": "#ffffff"
  },
  "git.defaultCloneDirectory": "$worktree_path",
  "terminal.integrated.cwd": "$worktree_path",
  "files.autoSave": "onWindowChange",
  "github.copilot.enable": {
    "*": true,
    "yaml": true,
    "dart": true,
    "javascript": true,
    "python": true
  }
}
EOF

    # Agent-specific tasks
    cat > "$worktree_path/.vscode/tasks.json" << EOF
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Agent $agent_name: Flutter Analyze",
      "type": "shell",
      "command": "flutter",
      "args": ["analyze"],
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "new"
      }
    },
    {
      "label": "Agent $agent_name: Run Tests",
      "type": "shell", 
      "command": "flutter",
      "args": ["test"],
      "group": "test",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "new"
      }
    },
    {
      "label": "Agent $agent_name: Coordinate with Other Agents",
      "type": "shell",
      "command": "bash",
      "args": ["../scripts/coordinate-agents.sh", "$agent_name"],
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "new"
      }
    }
  ]
}
EOF

    # Create agent-specific README
    cat > "$worktree_path/AGENT-README.md" << EOF
# 🤖 Agent: $agent_name

**Branch**: \`$branch_name\`
**Worktree**: \`$worktree_path\`
**Specialization**: $(get_agent_specialization $agent_name)

## 🎯 Agent Mission
$(get_agent_mission $agent_name)

## 🛠️ Agent Commands
\`\`\`bash
# Start agent development
flutter pub get
flutter analyze
flutter test

# Coordinate with other agents
bash ../scripts/coordinate-agents.sh $agent_name

# Sync with main development
git fetch origin
git rebase origin/develop
\`\`\`

## 📊 Real-time Status
- **Status**: Active
- **Current Task**: Waiting for assignment
- **Last Update**: $(date)
EOF

    # Create coordination status file
    mkdir -p "$worktree_path/.agent-coordination"
    cat > "$worktree_path/.agent-coordination/status.json" << EOF
{
  "agent_id": "$agent_name",
  "branch": "$branch_name",
  "worktree_path": "$worktree_path",
  "status": "ready",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "specialization": "$(get_agent_specialization $agent_name)",
  "current_task": null,
  "files_being_modified": [],
  "coordination_port": $(get_agent_port $agent_name)
}
EOF

    echo "📝 Agent workspace configured for: $agent_name"
}

# Helper functions
get_agent_theme() {
    case $1 in
        "feature-dev-1") echo "GitHub Dark" ;;
        "bug-fixer-1") echo "Monokai" ;;
        "test-engineer-1") echo "Solarized Dark" ;;
        "refactor-specialist-1") echo "Dark+ (default dark)" ;;
        "doc-writer-1") echo "Quiet Light" ;;
        *) echo "Default Dark+" ;;
    esac
}

get_agent_color() {
    case $1 in
        "feature-dev-1") echo "#28a745" ;;      # Green
        "bug-fixer-1") echo "#dc3545" ;;        # Red  
        "test-engineer-1") echo "#007bff" ;;    # Blue
        "refactor-specialist-1") echo "#fd7e14" ;; # Orange
        "doc-writer-1") echo "#6f42c1" ;;       # Purple
        *) echo "#6c757d" ;;                    # Gray
    esac
}

get_agent_specialization() {
    case $1 in
        "feature-dev-1") echo "Feature Development & Implementation" ;;
        "bug-fixer-1") echo "Bug Analysis & Resolution" ;;
        "test-engineer-1") echo "Test Automation & Quality Assurance" ;;
        "refactor-specialist-1") echo "Code Optimization & Architecture" ;;
        "doc-writer-1") echo "Documentation & Technical Writing" ;;
        *) echo "General Development" ;;
    esac
}

get_agent_mission() {
    case $1 in
        "feature-dev-1") echo "Implement new features with comprehensive testing and documentation. Focus on user experience and performance." ;;
        "bug-fixer-1") echo "Identify, analyze, and resolve bugs. Create regression tests and improve system stability." ;;
        "test-engineer-1") echo "Develop comprehensive test suites, improve coverage, and ensure quality standards." ;;
        "refactor-specialist-1") echo "Optimize code structure, improve performance, and enhance maintainability." ;;
        "doc-writer-1") echo "Create and maintain high-quality documentation, API docs, and user guides." ;;
        *) echo "Provide general development support and coordination." ;;
    esac
}

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

# Main execution
main() {
    echo "🚀 Multi-Agent Worktree Setup Starting..."
    
    # Verify we're in a git repository
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "❌ Error: Not in a Git repository"
        exit 1
    fi
    
    # Create worktrees for each agent
    for agent in "${AGENTS[@]}"; do
        create_agent_worktree "$agent"
        echo ""
    done
    
    # Create coordination dashboard
    create_coordination_dashboard
    
    echo "🎉 Multi-Agent Worktree Setup Complete!"
    echo ""
    echo "📋 Next Steps:"
    echo "   1. Run: bash scripts/spawn-multi-agent-ides.sh"
    echo "   2. Start developing with multiple agents simultaneously"
    echo "   3. Monitor progress: bash scripts/monitor-agent-activity.sh"
    echo ""
    echo "📁 Worktrees Created:"
    git worktree list
}

create_coordination_dashboard() {
    cat > "scripts/coordination-dashboard.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>🤖 Multi-Agent Coordination Dashboard</title>
    <meta charset="UTF-8">
    <meta http-equiv="refresh" content="5">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 20px; background: #1a1a1a; color: #fff; }
        .agent { border: 2px solid #333; margin: 10px 0; padding: 15px; border-radius: 8px; }
        .agent-feature-dev-1 { border-color: #28a745; }
        .agent-bug-fixer-1 { border-color: #dc3545; }
        .agent-test-engineer-1 { border-color: #007bff; }
        .agent-refactor-specialist-1 { border-color: #fd7e14; }
        .agent-doc-writer-1 { border-color: #6f42c1; }
        .status { font-weight: bold; }
        .active { color: #28a745; }
        .working { color: #ffc107; }
        .completed { color: #17a2b8; }
        h1 { text-align: center; }
        .refresh { text-align: center; margin: 20px; }
    </style>
</head>
<body>
    <h1>🤖 Multi-Agent Development Dashboard</h1>
    <div class="refresh">Auto-refresh every 5 seconds | <a href="#" onclick="location.reload()">Manual Refresh</a></div>
    
    <div id="agents">
        <!-- Agents will be loaded via JavaScript -->
    </div>
    
    <script>
        async function loadAgentStatus() {
            const agents = ['feature-dev-1', 'bug-fixer-1', 'test-engineer-1', 'refactor-specialist-1', 'doc-writer-1'];
            const container = document.getElementById('agents');
            container.innerHTML = '';
            
            for (const agent of agents) {
                try {
                    const response = await fetch(`./worktrees/agent-${agent}/.agent-coordination/status.json`);
                    const status = await response.json();
                    
                    const agentDiv = document.createElement('div');
                    agentDiv.className = `agent agent-${agent}`;
                    agentDiv.innerHTML = `
                        <h3>🤖 Agent: ${agent}</h3>
                        <p><strong>Status:</strong> <span class="status ${status.status}">${status.status}</span></p>
                        <p><strong>Branch:</strong> ${status.branch}</p>
                        <p><strong>Specialization:</strong> ${status.specialization}</p>
                        <p><strong>Current Task:</strong> ${status.current_task || 'None'}</p>
                        <p><strong>Files Being Modified:</strong> ${status.files_being_modified.join(', ') || 'None'}</p>
                        <p><strong>Last Update:</strong> ${new Date(status.created_at).toLocaleString()}</p>
                    `;
                    container.appendChild(agentDiv);
                } catch (e) {
                    console.log(`Could not load status for ${agent}`);
                }
            }
        }
        
        loadAgentStatus();
        setInterval(loadAgentStatus, 5000);
    </script>
</body>
</html>
EOF
    
    echo "📊 Coordination dashboard created: scripts/coordination-dashboard.html"
}

# Execute main function
main "$@"
```

### Step 2: Multi-IDE Spawner Script

```bash
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
        )
        
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
            bash "../scripts/monitor-single-agent.sh" "$agent" &
            echo $! > ".agent-coordination/monitor.pid"
        )
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
        open "http://localhost:8080/scripts/coordination-dashboard.html"
    elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "http://localhost:8080/scripts/coordination-dashboard.html"
    else
        echo "   Dashboard available at: http://localhost:8080/scripts/coordination-dashboard.html"
    fi
    
    echo "   Dashboard PID: $DASHBOARD_PID"
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

# Function to update agent statuses
update_agent_statuses() {
    for agent in "${AGENTS[@]}"; do
        local worktree_path="${WORKTREE_DIR}/agent-${agent}"
        local status_file="$worktree_path/.agent-coordination/status.json"
        
        if [ -f "$status_file" ]; then
            # Update timestamp
            local temp_file=$(mktemp)
            jq '.last_update = now | .last_update_readable = (now | strftime("%Y-%m-%d %H:%M:%S"))' "$status_file" > "$temp_file"
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

# Execute main function
main "$@"
```

### Step 3: Agent Coordination Script

```bash
#!/bin/bash
# scripts/coordinate-agents.sh  
# Handles coordination between agents working in different worktrees

AGENT_ID=$1
WORKTREE_DIR="worktrees"

coordinate_with_agents() {
    local current_agent=$1
    local current_worktree="${WORKTREE_DIR}/agent-${current_agent}"
    
    echo "🤝 Agent $current_agent coordinating with other agents..."
    
    # Get list of files being modified by this agent
    local modified_files=$(cd "$current_worktree" && git status --porcelain | awk '{print $2}')
    
    if [ -z "$modified_files" ]; then
        echo "   No modified files to coordinate"
        return 0
    fi
    
    echo "   Files being modified: $modified_files"
    
    # Check other agents for conflicts
    local conflicts=()
    
    for other_worktree in "${WORKTREE_DIR}"/agent-*; do
        if [ "$other_worktree" != "$current_worktree" ] && [ -d "$other_worktree" ]; then
            local other_agent=$(basename "$other_worktree" | sed 's/agent-//')
            
            # Check if other agent is modifying same files
            local other_modified=$(cd "$other_worktree" && git status --porcelain | awk '{print $2}')
            
            # Find overlapping files
            local overlap=$(comm -12 <(echo "$modified_files" | sort) <(echo "$other_modified" | sort))
            
            if [ -n "$overlap" ]; then
                conflicts+=("$other_agent:$overlap")
                echo "   ⚠️  Potential conflict with $other_agent on files: $overlap"
                
                # Send coordination message
                send_coordination_message "$current_agent" "$other_agent" "$overlap"
            fi
        fi
    done
    
    if [ ${#conflicts[@]} -eq 0 ]; then
        echo "   ✅ No conflicts detected"
    else
        echo "   📋 Coordination messages sent for ${#conflicts[@]} potential conflicts"
    fi
    
    # Update agent status
    update_agent_status "$current_agent" "coordinating" "$modified_files"
}

send_coordination_message() {
    local from_agent=$1
    local to_agent=$2
    local files=$3
    
    local to_worktree="${WORKTREE_DIR}/agent-${to_agent}"
    local message_file="$to_worktree/.agent-coordination/messages/$(date +%s)-from-$from_agent.json"
    
    mkdir -p "$to_worktree/.agent-coordination/messages"
    
    cat > "$message_file" << EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "from_agent": "$from_agent",
  "to_agent": "$to_agent", 
  "type": "potential_conflict",
  "message": "I am working on the same files as you",
  "files": "$files",
  "suggested_action": "coordinate_changes",
  "priority": "medium"
}
EOF
    
    echo "   📨 Coordination message sent to $to_agent"
}

update_agent_status() {
    local agent_id=$1
    local status=$2
    local files=$3
    
    local worktree_path="${WORKTREE_DIR}/agent-${agent_id}"
    local status_file="$worktree_path/.agent-coordination/status.json"
    
    if [ -f "$status_file" ]; then
        local temp_file=$(mktemp)
        jq --arg status "$status" --arg files "$files" \
           '.status = $status | .files_being_modified = ($files | split("\n") | map(select(length > 0))) | .last_update = now' \
           "$status_file" > "$temp_file"
        mv "$temp_file" "$status_file"
    fi
}

# Main execution
if [ -z "$AGENT_ID" ]; then
    echo "Usage: $0 <agent-id>"
    echo "Example: $0 feature-dev-1"
    exit 1
fi

coordinate_with_agents "$AGENT_ID"
```

### Step 4: Real-time Monitoring Script

```bash
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
    local git_status=$(cd "$worktree_path" && git status --porcelain 2>/dev/null)
    if [ -n "$git_status" ]; then
        echo "   📝 Modified Files:"
        echo "$git_status" | while read line; do
            echo "      $line"
        done
    else
        echo "   📝 No pending changes"
    fi
    
    # Branch info
    local branch=$(cd "$worktree_path" && git branch --show-current 2>/dev/null)
    local commits_ahead=$(cd "$worktree_path" && git rev-list --count HEAD ^origin/develop 2>/dev/null || echo "0")
    echo "   🌿 Branch: $branch ($commits_ahead commits ahead of develop)"
    
    # Recent activity
    local last_commit=$(cd "$worktree_path" && git log -1 --format="%h %s (%ar)" 2>/dev/null)
    echo "   ⏰ Last Commit: $last_commit"
    
    # Agent status from coordination file
    local status_file="$worktree_path/.agent-coordination/status.json"
    if [ -f "$status_file" ]; then
        local agent_status=$(jq -r '.status' "$status_file" 2>/dev/null)
        local current_task=$(jq -r '.current_task // "None"' "$status_file" 2>/dev/null)
        echo "   🎯 Status: $agent_status"
        echo "   📋 Current Task: $current_task"
    fi
    
    # Check for coordination messages
    local messages_dir="$worktree_path/.agent-coordination/messages"
    if [ -d "$messages_dir" ]; then
        local message_count=$(find "$messages_dir" -name "*.json" | wc -l)
        if [ "$message_count" -gt 0 ]; then
            echo "   💬 Coordination Messages: $message_count unread"
        fi
    fi
    
    # Performance indicators
    local file_count=$(find "$worktree_path" -name "*.dart" | wc -l)
    local test_count=$(find "$worktree_path/test" -name "*.dart" 2>/dev/null | wc -l)
    echo "   📊 Dart Files: $file_count | Test Files: $test_count"
}

show_system_overview() {
    echo "=================================================="
    echo "🌐 SYSTEM OVERVIEW"
    echo ""
    
    # Git worktree list
    echo "📁 Active Worktrees:"
    git worktree list | while read line; do
        echo "   $line"
    done
    echo ""
    
    # Resource usage
    echo "💻 System Resources:"
    echo "   CPU: $(top -l 1 | grep "CPU usage" | cut -d' ' -f3-8 2>/dev/null || echo "N/A")"
    echo "   Memory: $(top -l 1 | grep "PhysMem" | cut -d' ' -f2-8 2>/dev/null || echo "N/A")"
    echo ""
    
    # VS Code processes
    local vscode_processes=$(pgrep -f "Code.*crypto_market" | wc -l)
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
```

### Step 5: AI Agent Integration with Worktrees

```javascript
// scripts/worktree-agent-executor.js
// Integrates AI agents with Git worktrees for parallel development

const { spawn, execSync } = require('child_process');
const fs = require('fs').promises;
const path = require('path');

class WorktreeAIAgent {
    constructor(agentId, worktreePath, aiProvider = 'copilot') {
        this.agentId = agentId;
        this.worktreePath = worktreePath;
        this.aiProvider = aiProvider;
        this.coordinationDir = path.join(worktreePath, '.agent-coordination');
        this.statusFile = path.join(this.coordinationDir, 'status.json');
    }

    async startAgentWork(task) {
        console.log(`🤖 Agent ${this.agentId} starting work in worktree: ${this.worktreePath}`);
        
        // Update status
        await this.updateStatus('working', task);
        
        // Change to agent worktree
        process.chdir(this.worktreePath);
        
        // Start AI-powered development loop
        await this.developmentLoop(task);
    }

    async developmentLoop(task) {
        const phases = [
            'analyze_requirements',
            'plan_implementation', 
            'write_code',
            'write_tests',
            'run_quality_checks',
            'coordinate_with_agents',
            'commit_changes'
        ];

        for (const phase of phases) {
            console.log(`📋 Agent ${this.agentId} - Phase: ${phase}`);
            
            try {
                await this.executePhase(phase, task);
                await this.updateStatus(`completed_${phase}`, task);
                
                // Check for coordination messages between phases
                await this.checkCoordinationMessages();
                
            } catch (error) {
                console.error(`❌ Agent ${this.agentId} failed at phase ${phase}:`, error);
                await this.updateStatus('failed', `Failed at ${phase}: ${error.message}`);
                break;
            }
        }
    }

    async executePhase(phase, task) {
        switch (phase) {
            case 'analyze_requirements':
                return await this.analyzeRequirements(task);
            case 'plan_implementation':
                return await this.planImplementation(task);
            case 'write_code':
                return await this.writeCode(task);
            case 'write_tests':
                return await this.writeTests();
            case 'run_quality_checks':
                return await this.runQualityChecks();
            case 'coordinate_with_agents':
                return await this.coordinateWithAgents();
            case 'commit_changes':
                return await this.commitChanges();
            default:
                throw new Error(`Unknown phase: ${phase}`);
        }
    }

    async writeCode(task) {
        console.log(`💻 Agent ${this.agentId} writing code...`);
        
        // Use AI provider to generate code
        const aiPrompt = this.generateCodePrompt(task);
        
        if (this.aiProvider === 'copilot') {
            return await this.useCopilotCLI(aiPrompt);
        } else if (this.aiProvider === 'openai') {
            return await this.useOpenAI(aiPrompt);
        }
    }

    async useCopilotCLI(prompt) {
        return new Promise((resolve, reject) => {
            const copilotProcess = spawn('gh', ['copilot', 'suggest', '--type', 'shell', '--prompt', prompt], {
                stdio: ['pipe', 'pipe', 'pipe'],
                cwd: this.worktreePath
            });

            let output = '';
            copilotProcess.stdout.on('data', (data) => {
                output += data.toString();
            });

            copilotProcess.on('close', (code) => {
                if (code === 0) {
                    resolve(output);
                } else {
                    reject(new Error(`Copilot CLI failed with code ${code}`));
                }
            });
        });
    }

    async coordinateWithAgents() {
        console.log(`🤝 Agent ${this.agentId} coordinating with other agents...`);
        
        // Run coordination script
        execSync(`bash ../scripts/coordinate-agents.sh ${this.agentId}`, {
            cwd: this.worktreePath,
            stdio: 'inherit'
        });
    }

    async checkCoordinationMessages() {
        const messagesDir = path.join(this.coordinationDir, 'messages');
        
        try {
            const messages = await fs.readdir(messagesDir);
            
            for (const messageFile of messages) {
                if (messageFile.endsWith('.json')) {
                    const messagePath = path.join(messagesDir, messageFile);
                    const message = JSON.parse(await fs.readFile(messagePath, 'utf8'));
                    
                    console.log(`📨 Agent ${this.agentId} received message from ${message.from_agent}: ${message.message}`);
                    
                    // Handle the message based on type
                    await this.handleCoordinationMessage(message);
                    
                    // Remove processed message
                    await fs.unlink(messagePath);
                }
            }
        } catch (error) {
            // Messages directory might not exist yet
        }
    }

    async updateStatus(status, details) {
        const statusData = {
            agent_id: this.agentId,
            status: status,
            details: details,
            timestamp: new Date().toISOString(),
            worktree_path: this.worktreePath
        };

        await fs.writeFile(this.statusFile, JSON.stringify(statusData, null, 2));
    }

    generateCodePrompt(task) {
        return `
You are Agent ${this.agentId} working in a multi-agent Flutter development environment.

Task: ${task}

Working Directory: ${this.worktreePath}
Branch: ${execSync('git branch --show-current', { cwd: this.worktreePath, encoding: 'utf8' }).trim()}

IMPORTANT COORDINATION RULES:
1. Only modify files in your worktree
2. Coordinate with other agents before making major changes
3. Write comprehensive tests for all code
4. Follow Flutter best practices
5. Commit changes incrementally

Generate the necessary Flutter/Dart code to complete this task.
        `;
    }
}

// Usage example
async function main() {
    const args = process.argv.slice(2);
    const agentId = args[0];
    const worktreePath = args[1];
    const task = args[2];
    const aiProvider = args[3] || 'copilot';

    if (!agentId || !worktreePath || !task) {
        console.error('Usage: node worktree-agent-executor.js <agent-id> <worktree-path> <task> [ai-provider]');
        process.exit(1);
    }

    const agent = new WorktreeAIAgent(agentId, worktreePath, aiProvider);
    await agent.startAgentWork(task);
}

if (require.main === module) {
    main().catch(console.error);
}

module.exports = { WorktreeAIAgent };
```

## 🚀 USAGE EXAMPLES

### Complete Setup and Launch

```bash
# 1. Setup worktrees for all agents
bash scripts/setup-agent-worktrees.sh

# 2. Launch multiple VS Code instances (one per agent)
bash scripts/spawn-multi-agent-ides.sh

# 3. Monitor all agents in real-time
bash scripts/monitor-agent-activity.sh

# 4. Assign tasks to agents
node scripts/worktree-agent-executor.js feature-dev-1 worktrees/agent-feature-dev-1 "Implement price alerts"
node scripts/worktree-agent-executor.js bug-fixer-1 worktrees/agent-bug-fixer-1 "Fix navigation bug in portfolio screen"
```

### Real-time Workflow

1. **You see 5 VS Code windows open simultaneously**
2. **Each window shows a different agent's workspace**
3. **Each agent works on a different branch automatically**
4. **Coordination happens automatically through file system**
5. **Dashboard shows real-time progress of all agents**
6. **Git worktrees handle all the branch management**

## 🎯 AMAZING BENEFITS

### Perfect Isolation + Coordination
- **Physical Separation**: Each agent in separate directory
- **Branch Isolation**: Each agent on different branch automatically
- **Shared Git**: All changes visible across worktrees instantly
- **Real-time Coordination**: File system coordination prevents conflicts

### Visual Development Experience  
- **Multiple IDEs**: Watch agents work in real-time across different windows
- **Color-coded Agents**: Each VS Code window has different theme/colors
- **Live Dashboard**: See all agent activity in real-time browser dashboard
- **Coordination Messages**: Visual alerts when agents need to coordinate

### Practical Implementation
- **Uses Standard Tools**: Git worktrees, VS Code, standard AI providers
- **No Complex Infrastructure**: Just file system coordination
- **Easy to Scale**: Add more agents by creating more worktrees
- **Easy to Monitor**: Everything visible in real-time

This is **absolutely brilliant** and completely practical! 🌟