#!/bin/bash
# Job Detective Auto-Scan Script
# Runs every 30 minutes via cron

cd /Users/vitaliisimko/clawd/agents/job_detective

# Check if node script exists
if [ ! -f "djinni_monitor.js" ]; then
    echo "Error: djinni_monitor.js not found"
    exit 1
fi

# Run the monitor
/usr/local/bin/node djinni_monitor.js 2>&1 | tee -a scan.log

echo "Scan completed at $(date)" >> scan.log