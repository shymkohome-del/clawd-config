#!/bin/bash
# Job Detective Launcher with work hours check

CONFIG="/Users/vitaliisimko/clawd/agents/job_detective/JOB_CONFIG.json"

# Get current time and day
HOUR=$(date +%H)
DAY=$(date +%u)  # 1=Monday, 7=Sunday

# Check if enabled
ENABLED=$(cat "$CONFIG" | grep -o '"enabled": true' | wc -l)
if [ "$ENABLED" -eq 0 ]; then
    echo "Job Detective is disabled"
    exit 0
fi

# Check work hours
if [ "$HOUR" -lt 9 ] || [ "$HOUR" -gt 20 ]; then
    echo "Outside work hours (9-20). Current: $HOUR:00"
    exit 0
fi

# Check work days (1-5 = Mon-Fri)
if [ "$DAY" -gt 5 ]; then
    echo "Weekend. Job Detective sleeps."
    exit 0
fi

echo "Work hours confirmed: Day $DAY, Hour $HOUR. Launching job_detective..."

# Launch job_detective via clawdbot
clawdbot sessions spawn --agent main --label job_detective --task "Ти job_detective. Перевір Djinni на нові Flutter вакансії та надішли Вітальону звіт."