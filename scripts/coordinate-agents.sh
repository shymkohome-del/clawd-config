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
    local modified_files=$(cd "$current_worktree" && git status --porcelain 2>/dev/null | awk '{print $2}' || echo "")
    
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
            local other_modified=$(cd "$other_worktree" && git status --porcelain 2>/dev/null | awk '{print $2}' || echo "")
            
            if [ -n "$other_modified" ] && [ -n "$modified_files" ]; then
                # Find overlapping files
                local overlap=$(comm -12 <(echo "$modified_files" | sort) <(echo "$other_modified" | sort))
                
                if [ -n "$overlap" ]; then
                    conflicts+=("$other_agent:$overlap")
                    echo "   ⚠️  Potential conflict with $other_agent on files: $overlap"
                    
                    # Send coordination message
                    send_coordination_message "$current_agent" "$other_agent" "$overlap"
                fi
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
        if command -v jq >/dev/null 2>&1; then
            local temp_file=$(mktemp)
            jq --arg status "$status" --arg files "$files" \
               '.status = $status | .files_being_modified = ($files | split("\n") | map(select(length > 0))) | .last_update = now' \
               "$status_file" > "$temp_file" 2>/dev/null && mv "$temp_file" "$status_file"
        else
            # Fallback without jq
            echo "   Note: jq not available, status update skipped"
        fi
    fi
}

# Main execution
if [ -z "$AGENT_ID" ]; then
    echo "Usage: $0 <agent-id>"
    echo "Example: $0 feature-dev-1"
    exit 1
fi

coordinate_with_agents "$AGENT_ID"