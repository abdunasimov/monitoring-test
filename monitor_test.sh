#!/bin/bash

PROCESS_NAME="test"
LOG_FILE="/var/log/monitoring.log"
URL="https://test.com/monitoring/test/api"
CHECK_INTERVAL=60

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

PID_FILE="/tmp/${PROCESS_NAME}_monitor.pid"

while true; do
    PID=$(pgrep -x "$PROCESS_NAME")
    if [[ -n "$PID" ]]; then
        if [[ -f "$PID_FILE" ]]; then
            PREV_PID=$(cat "$PID_FILE")
            if [[ "$PREV_PID" != "$PID" ]]; then
                log_message "Процесс $PROCESS_NAME был перезапущен (PID изменился: $PREV_PID -> $PID)"
            fi
        fi
        echo "$PID" > "$PID_FILE"

        if ! curl -s --max-time 10 -o /dev/null "$URL"; then
            log_message "Ошибка: Сервер мониторинга $URL недоступен"
        fi
    fi
    sleep "$CHECK_INTERVAL"
done
