#!/usr/bin/env bash
# ==============================================================================
# Script 2: Log Directory Cleanup & Alerting
# Demonstrates: Loops, conditionals (if/else), find, exit codes, logging
# ==============================================================================

LOG_DIR="/tmp/app_logs"
RETENTION_DAYS=7
REPORT_FILE="/tmp/cleanup_report.log"

# Ensure target directory exists before proceeding
if [[ ! -d "$LOG_DIR" ]]; then
    echo "ERROR: Directory $LOG_DIR does not exist."
    exit 1
fi

echo "=== Log Cleanup Started: $(date) ===" >> "$REPORT_FILE"

# 1. Loop through all .log files to check for oversized files (> 1MB)
for logfile in "$LOG_DIR"/*.log; do
    # Skip if no .log files match
    [[ -e "$logfile" ]] || continue

    FILE_SIZE=$(du -m "$logfile" | cut -f1)
    if [[ "$FILE_SIZE" -gt 1 ]]; then
        echo "WARNING: $logfile is ${FILE_SIZE}MB (exceeds 1MB threshold)" | tee -a "$REPORT_FILE"
    fi
done

# 2. Delete .log files older than RETENTION_DAYS
DELETED_COUNT=$(find "$LOG_DIR" -name "*.log" -type f -mtime +"$RETENTION_DAYS" -print -delete | wc -l)

echo "Removed $DELETED_COUNT log files older than $RETENTION_DAYS days." | tee -a "$REPORT_FILE"
echo "" >> "$REPORT_FILE"