#!/usr/bin/env bash
# ==============================================================================
# Script 3: Automated Service & Network Health Watchdog
# Demonstrates: Arrays, functions, loops, pgrep/ss, exit status ($?)
# ==============================================================================

SERVICES=("cron" "ssh")
ENDPOINTS=("https://example.com" "http://localhost:8080")
ALERT_LOG="/tmp/health_watchdog.log"

log_message() {
    local LEVEL="$1"
    local MESSAGE="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$LEVEL] $MESSAGE" | tee -a "$ALERT_LOG"
}

echo "--- Running Health Check ---"

# 1. Check if critical background daemons are running
for svc in "${SERVICES[@]}"; do
    if pgrep -x "$svc" >/dev/null 2>&1; then
        log_message "OK" "Service '$svc' is running."
    else
        log_message "ALERT" "Service '$svc' is NOT running!"
    fi
done

# 2. Check HTTP endpoint reachability using curl with a 3-second timeout
for url in "${ENDPOINTS[@]}"; do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "$url")
    if [[ "$HTTP_CODE" -ge 200 && "$HTTP_CODE" -lt 400 ]]; then
        log_message "OK" "Endpoint $url reachable (HTTP $HTTP_CODE)."
    else
        log_message "WARN" "Endpoint $url unreachable or returned HTTP $HTTP_CODE."
    fi
done
