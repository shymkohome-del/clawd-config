#!/bin/bash
# scripts/setup-agent-worktrees.sh
# Sets up Git worktrees for multi-agent development

set -e

MAIN_BRANCH=$(git branch --show-current)
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
    
    # Create new branch from current branch
    git checkout "$MAIN_BRANCH" 2>/dev/null || {
        echo "❌ Could not checkout base branch: $MAIN_BRANCH"
        exit 1
    }
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
git rebase origin/main
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

# Function to create coordination dashboard
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
                    const response = await fetch(`../worktrees/agent-${agent}/.agent-coordination/status.json`);
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

# Execute main function
main "$@"