#!/bin/bash

LOG_FILE="/var/log/update-all-lxc-pro.log"
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/xxxx"

DATE_NOW=$(date '+%Y-%m-%d %H:%M:%S')
UPDATED=0
SKIPPED=0
FAILED=0
REBOOT_REQUIRED=0

echo "===== LXC update report - $DATE_NOW =====" | tee "$LOG_FILE"

send_discord() {
  local MESSAGE="$1"

  MESSAGE_ESCAPED=$(printf '%s' "$MESSAGE" \
    | sed ':a;N;$!ba;s/\n/\\n/g' \
    | sed 's/"/\\"/g')

  curl -s -H "Content-Type: application/json" \
    -X POST \
    -d "{\"content\":\"$MESSAGE_ESCAPED\"}" \
    "$DISCORD_WEBHOOK_URL" >/dev/null
}

for CTID in $(pct list | awk 'NR>1 {print $1}'); do
  STATUS=$(pct status "$CTID" | awk '{print $2}')
  NAME=$(pct config "$CTID" | awk -F': ' '/^hostname:/ {print $2}')

  [ -z "$NAME" ] && NAME="CT-$CTID"

  echo "" | tee -a "$LOG_FILE"
  echo "----- Processing $NAME ($CTID) -----" | tee -a "$LOG_FILE"

  if [ "$STATUS" != "running" ]; then
    echo "SKIPPED: $NAME ($CTID) is not running" | tee -a "$LOG_FILE"
    SKIPPED=$((SKIPPED+1))
    continue
  fi

  DISTRO=$(pct exec "$CTID" -- sh -c '. /etc/os-release 2>/dev/null && echo "$ID"' 2>/dev/null | tr -d '\r')

  if [[ "$DISTRO" =~ ^(debian|ubuntu|kali)$ ]]; then
    echo "Detected distro: $DISTRO" | tee -a "$LOG_FILE"

    if pct exec "$CTID" -- bash -lc "export DEBIAN_FRONTEND=noninteractive; apt update && apt full-upgrade -y && apt autoremove -y && apt autoclean -y" >> "$LOG_FILE" 2>&1; then

      echo "UPDATED: $NAME ($CTID)" | tee -a "$LOG_FILE"
      UPDATED=$((UPDATED+1))

      if pct exec "$CTID" -- test -f /var/run/reboot-required; then
        echo "REBOOT REQUIRED: $NAME ($CTID)" | tee -a "$LOG_FILE"
        REBOOT_REQUIRED=$((REBOOT_REQUIRED+1))
      fi

    else
      echo "FAILED: $NAME ($CTID)" | tee -a "$LOG_FILE"
      FAILED=$((FAILED+1))
    fi

  elif [ "$DISTRO" = "alpine" ]; then
    echo "Detected distro: alpine" | tee -a "$LOG_FILE"

    if pct exec "$CTID" -- sh -c 'apk update && apk upgrade' >> "$LOG_FILE" 2>&1; then
      echo "UPDATED: $NAME ($CTID)" | tee -a "$LOG_FILE"
      UPDATED=$((UPDATED+1))
    else
      echo "FAILED: $NAME ($CTID)" | tee -a "$LOG_FILE"
      FAILED=$((FAILED+1))
    fi

  else
    echo "SKIPPED: unsupported or unknown distro for $NAME ($CTID): $DISTRO" | tee -a "$LOG_FILE"
    SKIPPED=$((SKIPPED+1))
  fi
done

FINAL_REPORT="✅ LXC Update Finished
Date: $DATE_NOW
Updated: $UPDATED
Skipped: $SKIPPED
Failed: $FAILED
Reboot required: $REBOOT_REQUIRED
Log: $LOG_FILE"

echo "" | tee -a "$LOG_FILE"
echo "$FINAL_REPORT" | tee -a "$LOG_FILE"

send_discord "$FINAL_REPORT"