#!/bin/bash

# Workspace switcher with Alt+Tab cycling support
# Usage: workspace-switcher.sh [next|prev|reset]

STATE_FILE="/tmp/hypr-workspace-switcher-state"
LOCK_FILE="/tmp/hypr-workspace-switcher-lock"
TIMEOUT=1  # seconds before resetting to single-press mode

# Function to get current workspace
get_current_workspace() {
    hyprctl activeworkspace -j | jq -r '.id'
}

# Function to get all workspace IDs (sorted)
get_all_workspaces() {
    hyprctl workspaces -j | jq -r '.[].id' | sort -n
}

# Function to switch workspace
switch_to_workspace() {
    local target=$1
    hyprctl dispatch workspace "$target" >/dev/null 2>&1
}

# Initialize or read state
if [[ -f "$STATE_FILE" ]]; then
    source "$STATE_FILE"
    # Check if timeout expired
    if (( $(date +%s) - LAST_PRESS > TIMEOUT )); then
        CYCLING=false
        ORIGINAL_WS=""
    fi
else
    CYCLING=false
    ORIGINAL_WS=""
fi

CURRENT_WS=$(get_current_workspace)
LAST_PRESS=$(date +%s)

case "${1:-next}" in
    next)
        if [[ "$CYCLING" == "false" ]]; then
            # First press - go to previous workspace (use hyprland's built-in previous)
            ORIGINAL_WS="$CURRENT_WS"
            hyprctl dispatch workspace previous >/dev/null 2>&1
            CYCLING=true
        else
            # Continue cycling - go to next workspace
            ALL_WS=($(get_all_workspaces))
            CURRENT_IDX=-1
            for i in "${!ALL_WS[@]}"; do
                if [[ "${ALL_WS[$i]}" == "$CURRENT_WS" ]]; then
                    CURRENT_IDX=$i
                    break
                fi
            done
            
            # Get next workspace (wrap around)
            NEXT_IDX=$(( (CURRENT_IDX + 1) % ${#ALL_WS[@]} ))
            TARGET="${ALL_WS[$NEXT_IDX]}"
            switch_to_workspace "$TARGET"
        fi
        ;;
        
    prev)
        # Cycle backwards
        ALL_WS=($(get_all_workspaces))
        CURRENT_IDX=-1
        for i in "${!ALL_WS[@]}"; do
            if [[ "${ALL_WS[$i]}" == "$CURRENT_WS" ]]; then
                CURRENT_IDX=$i
                break
            fi
        done
        
        # Get previous workspace (wrap around)
        PREV_IDX=$(( (CURRENT_IDX - 1 + ${#ALL_WS[@]}) % ${#ALL_WS[@]} ))
        TARGET="${ALL_WS[$PREV_IDX]}"
        
        switch_to_workspace "$TARGET"
        CYCLING=true
        if [[ -z "$ORIGINAL_WS" ]]; then
            ORIGINAL_WS="$CURRENT_WS"
        fi
        ;;
        
    reset)
        # Reset to single-press mode
        CYCLING=false
        ORIGINAL_WS=""
        rm -f "$STATE_FILE"
        exit 0
        ;;
esac

# Save state
cat > "$STATE_FILE" << EOF
CYCLING=$CYCLING
ORIGINAL_WS="$ORIGINAL_WS"
LAST_PRESS=$LAST_PRESS
EOF
