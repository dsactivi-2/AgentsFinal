#!/bin/bash
# Ava Memory Autosave — Synct OpenClaw Workspace Memory → Supermemory
# Läuft als systemd Timer alle 15 Minuten

MEM0_API="http://127.0.0.1:8010"
WORKSPACE="/root/.openclaw/workspace-social-ai"
STATE_FILE="/root/.supermemory-ava/last-sync.txt"
LOG_FILE="/root/.supermemory-ava/sync.log"
USER_ID="global"

mkdir -p /root/.supermemory-ava

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG_FILE"; }

# Health check mem0-api
HEALTH=$(curl -s --max-time 5 "$MEM0_API/health" 2>/dev/null)
if ! echo "$HEALTH" | grep -q '"ok":true'; then
    log "ERROR mem0-api nicht erreichbar"
    exit 1
fi

LAST_SYNC=$(cat "$STATE_FILE" 2>/dev/null || echo "0")
NOW=$(date +%s)
SYNCED=0

sync_file() {
    local FILE="$1"
    local LABEL="$2"
    [ ! -f "$FILE" ] && return
    local MTIME=$(stat -c %Y "$FILE" 2>/dev/null || echo 0)
    [ "$MTIME" -le "$LAST_SYNC" ] && return  # nicht verändert
    
    local CONTENT=$(cat "$FILE")
    [ -z "$CONTENT" ] && return
    
    local PAYLOAD=$(python3 -c "
import json, sys
content, label = sys.argv[1], sys.argv[2]
print(json.dumps({'user_id': 'global', 'content': f'[Ava Workspace | {label}]\n\n{content}', 'metadata': {'source': 'ava-workspace', 'file': label}}))
" "$CONTENT" "$LABEL" 2>/dev/null)
    
    [ -z "$PAYLOAD" ] && return
    
    HTTP=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 \
        -X POST "$MEM0_API/memory/add" \
        -H "Content-Type: application/json" \
        -d "$PAYLOAD" 2>/dev/null)
    
    if [ "$HTTP" = "200" ] || [ "$HTTP" = "201" ]; then
        SYNCED=$((SYNCED + 1))
    else
        log "FAIL HTTP $HTTP | $LABEL"
    fi
}

# MEMORY.md (Langzeit-Wissen)
sync_file "$WORKSPACE/MEMORY.md" "MEMORY.md"

# Daily logs (memory/YYYY-MM-DD.md)
if [ -d "$WORKSPACE/memory" ]; then
    for f in "$WORKSPACE"/memory/*.md; do
        [ -f "$f" ] && sync_file "$f" "daily/$(basename "$f")"
    done
fi

# Timestamp aktualisieren
echo "$NOW" > "$STATE_FILE"

[ $SYNCED -gt 0 ] && log "Synced=$SYNCED Dateien"

exit 0
