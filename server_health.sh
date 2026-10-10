
#!/bin/bash

# Linux Server Health Monitoring Tool - Version 5

set -u

PROJECT_DIR="$HOME/linux-health-monitor"
LOG_FILE="$PROJECT_DIR/health.log"
ALERT_FILE="$PROJECT_DIR/alerts.log"

# Configurable thresholds
CPU_WARN_MULTIPLIER=1
MEMORY_WARN=80
MEMORY_CRITICAL=90
DISK_WARN=80
DISK_CRITICAL=90

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
UPTIME=$(uptime -p)
CPU_LOAD=$(awk '{print $1}' /proc/loadavg)
CPU_COUNT=$(nproc)

# Memory usage based on available memory
MEMORY_USAGE=$(free | awk '/Mem:/ {
    if ($2 > 0) printf "%.0f", (($2-$7)/$2)*100
    else print 0
}')

# Root filesystem usage
DISK_USAGE=$(df -P / | awk 'NR==2 {
    gsub("%", "", $5)
    print $5
}')

# Exclude ps itself from the process tables
TOP_CPU_PROCESSES=$(
    ps -eo pid,comm,%cpu,%mem --sort=-%cpu |
    awk 'NR == 1 || $2 != "ps"' |
    head -n 6
)

TOP_MEMORY_PROCESSES=$(
    ps -eo pid,comm,%cpu,%mem --sort=-%mem |
    awk 'NR == 1 || $2 != "ps"' |
    head -n 6
)

STATUS="HEALTHY"
WARNINGS=()
CRITICALS=()

# CPU load check
if awk -v load="$CPU_LOAD" -v cores="$CPU_COUNT" \
    -v multiplier="$CPU_WARN_MULTIPLIER" \
    'BEGIN {exit !(load >= cores * multiplier)}'; then
    WARNINGS+=("High CPU load: $CPU_LOAD across $CPU_COUNT CPU cores")
fi

# Memory checks
if [ "$MEMORY_USAGE" -ge "$MEMORY_CRITICAL" ]; then
    CRITICALS+=("Critical memory usage: ${MEMORY_USAGE}%")
elif [ "$MEMORY_USAGE" -ge "$MEMORY_WARN" ]; then
    WARNINGS+=("High memory usage: ${MEMORY_USAGE}%")
fi

# Disk checks
if [ "$DISK_USAGE" -ge "$DISK_CRITICAL" ]; then
    CRITICALS+=("Critical disk usage: ${DISK_USAGE}%")
elif [ "$DISK_USAGE" -ge "$DISK_WARN" ]; then
    WARNINGS+=("High disk usage: ${DISK_USAGE}%")
fi

# Determine overall status
if [ "${#CRITICALS[@]}" -gt 0 ]; then
    STATUS="CRITICAL"
elif [ "${#WARNINGS[@]}" -gt 0 ]; then
    STATUS="WARNING"
fi

# Generate and save the report
{
    echo "=========================================="
    echo "       LINUX SERVER HEALTH REPORT"
    echo "=========================================="
    echo "Timestamp: $TIMESTAMP"
    echo "Hostname: $(hostname)"
    echo "Uptime: $UPTIME"
    echo "CPU Load (1 min): $CPU_LOAD"
    echo "CPU Cores: $CPU_COUNT"
    echo "Memory Usage: ${MEMORY_USAGE}%"
    echo "Disk Usage (/): ${DISK_USAGE}%"

    echo
    echo "TOP 5 CPU-CONSUMING PROCESSES:"
    echo "$TOP_CPU_PROCESSES"

    echo
    echo "TOP 5 MEMORY-CONSUMING PROCESSES:"
    echo "$TOP_MEMORY_PROCESSES"

    echo
    echo "Overall Status: $STATUS"

    if [ "${#WARNINGS[@]}" -gt 0 ] ||
       [ "${#CRITICALS[@]}" -gt 0 ]; then
        echo
        echo "ALERTS:"
        for warning in "${WARNINGS[@]}"; do
            echo "[WARNING] $warning"
        done
        for critical in "${CRITICALS[@]}"; do
            echo "[CRITICAL] $critical"
        done
    else
        echo "Alerts: None"
    fi

    echo "=========================================="
    echo
} | tee -a "$LOG_FILE"

# Save alerts separately
if [ "${#CRITICALS[@]}" -gt 0 ] ||
   [ "${#WARNINGS[@]}" -gt 0 ]; then

    for warning in "${WARNINGS[@]}"; do
        echo "[$TIMESTAMP] [WARNING] $warning" >> "$ALERT_FILE"
    done

    for critical in "${CRITICALS[@]}"; do
        echo "[$TIMESTAMP] [CRITICAL] $critical" >> "$ALERT_FILE"
    done
else
    echo "[$TIMESTAMP] [HEALTHY] No threshold breaches" \
        >> "$ALERT_FILE"
fi

# Exit codes: 0 = healthy, 1 = warning, 2 = critical
if [ "$STATUS" = "CRITICAL" ]; then
    exit 2
elif [ "$STATUS" = "WARNING" ]; then
    exit 1
else
    exit 0
fi
