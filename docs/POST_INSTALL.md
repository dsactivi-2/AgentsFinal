# Post-Installation Setup Guide

**Social AI Stack — Agent Ava**
After running `bootstrap.sh`, complete these steps to go live.

Prerequisites: OpenClaw, Caddy, PostgreSQL, Redis are already running.

---

## Step 1 — Fill in API Keys

### `config/.env`

```bash
nano /root/social-ai/config/.env
```

| Variable | Where to get it |
|---|---|
| `OLLAMA_CLOUD_API_KEY` | Already set during bootstrap |
| `ANTHROPIC_API_KEY` | [console.anthropic.com](https://console.anthropic.com) → API Keys |
| `SUPERMEMORY_API_KEY` | [supermemory.ai](https://supermemory.ai) → Dashboard → API Keys |

### `services/meta-bridge/.env`

```bash
nano /root/social-ai/services/meta-bridge/.env
```

| Variable | Where to get it |
|---|---|
| `META_APP_SECRET` | [developers.facebook.com](https://developers.facebook.com) → App → Settings → Basic → App Secret |
| `META_VERIFY_TOKEN` | Choose any string, e.g. `ava-webhook-2026` — you'll enter this again in Step 4 |
| `META_PAGE_ACCESS_TOKEN` | developers.facebook.com → App → Messenger → Settings → Access Tokens → Generate |
| `ADMIN_PSID` | Leave empty for now — fill in after Step 5 |
| `DB_PASSWORD` | Your PostgreSQL password (empty if none set) |

### `services/mem0-api/.env`

```bash
nano /root/social-ai/services/mem0-api/.env
```

| Variable | Where to get it |
|---|---|
| `SUPERMEMORY_API_KEY` | Same key as in `config/.env` |

---

## Step 2 — Apply Database Schema + Install Dependencies

`bootstrap.sh` already runs both steps automatically. If you need to run them manually (e.g. after pulling new changes):

```bash
cd /root/social-ai

# Re-apply schema (safe, uses CREATE TABLE IF NOT EXISTS)
psql -U postgres -d social_ai < services/db/schema.sql

# Re-install dependencies for both services
pip install -r services/meta-bridge/requirements.txt
pip install -r services/mem0-api/requirements.txt
```

Verify the `error_logs` table exists:

```bash
psql -U postgres -d social_ai -c "\dt"
```

---

## Step 3 — Start Services

Start all three services in order:

```bash
cd /root/social-ai

# 1. mem0 memory API (port 8010)
bash scripts/start-mem0-api.sh

# 2. Meta Bridge — Facebook/Instagram webhook receiver (port 8085)
bash scripts/start-meta-bridge.sh

# 3. Watchdog — auto-restarts services if they crash (checks every 30s)
bash scripts/start-watchdog.sh
```

Verify all three are running:

```bash
curl -s http://127.0.0.1:8010/health | python3 -m json.tool
curl -s http://127.0.0.1:8085/health | python3 -m json.tool
cat /tmp/mem0-api.pid /tmp/meta-bridge.pid   # should print PIDs
```

---

## Step 5 — Configure Facebook Webhook

1. Go to [developers.facebook.com](https://developers.facebook.com)
2. Open your App → **Webhooks** → **Add Subscription** (Page object)
3. Set:
   - **Callback URL:** `https://marki.ds.activi.io/hooks/meta`
   - **Verify Token:** the value you put in `META_VERIFY_TOKEN`
4. Subscribe to fields: `messages`, `messaging_postbacks`
5. Click **Verify and Save** — meta-bridge must be running at this point

---

## Step 6 — Find Your Admin PSID

The PSID is your own Facebook user ID as seen by the bot. Needed for admin approval flows.

1. Send any message to your Facebook Page from your personal account
2. On the server, check the meta-bridge log:

```bash
tail -f /tmp/meta-bridge.log | grep psid
```

3. Copy the PSID, add it to `services/meta-bridge/.env`:

```
ADMIN_PSID=10012345678901234
```

4. Restart meta-bridge:

```bash
kill $(cat /tmp/meta-bridge.pid)
bash /root/social-ai/scripts/start-meta-bridge.sh
```

---

## Step 7 — Set Up Cron Jobs in OpenClaw Dashboard

All 7 cron jobs are defined in **`config/crons.json`** — use that file as reference.

Navigate to: **Dashboard → Agent (main) → Scheduled Jobs**

Add each job from `config/crons.json`:

| Job ID | Schedule | When |
|---|---|---|
| `planner-daily` | `0 2 * * *` | Daily 02:00 Berlin |
| `analytics-daily` | `0 1 * * *` | Daily 01:00 Berlin |
| `memory-critic-weekly` | `0 3 * * 0` | Sunday 03:00 Berlin |
| `reflexion-weekly` | `0 4 * * 0` | Sunday 04:00 Berlin |
| `lead-nurturing-morning` | `0 9 * * 1-5` | Weekdays 09:00 Berlin |
| `lead-nurturing-midday` | `0 12 * * 1-5` | Weekdays 12:00 Berlin |
| `lead-nurturing-evening` | `0 18 * * 1-5` | Weekdays 18:00 Berlin |

Copy the `message` field for each job from `config/crons.json`. Timezone: `Europe/Berlin`.

---

## Step 8 — Approve Dashboard Devices

If you're accessing the OpenClaw Dashboard from a new browser or device:

```bash
openclaw devices list
openclaw devices approve <REQUEST_ID>
```

---

## Step 9 — Merge Branch to Main

Once everything is verified working:

```bash
cd /root/social-ai
git checkout main
git merge refactor/openclaw-conform
git push origin main
```

---

## Verification Checklist

Run through this before considering the setup complete:

```bash
# Services running
curl -sf http://127.0.0.1:8010/health && echo "mem0-api OK"
curl -sf http://127.0.0.1:8085/health && echo "meta-bridge OK"

# OpenClaw reachable
curl -sf https://marki.ds.activi.io/ && echo "Gateway OK"

# Database tables exist
psql -U postgres -d social_ai -c "SELECT COUNT(*) FROM leads;"
psql -U postgres -d social_ai -c "SELECT COUNT(*) FROM error_logs;"

# Webhook endpoint reachable from the internet
curl -sf https://marki.ds.activi.io/hooks/meta && echo "Webhook endpoint OK"
```

Send a test message to your Facebook Page and verify:
1. Meta Bridge log shows the incoming event
2. OpenClaw receives the hook
3. Agent Ava replies

---

## Quick Command Reference

```bash
# View live logs
tail -f /tmp/meta-bridge.log
tail -f /tmp/mem0-api.log
tail -f /tmp/watchdog.log
journalctl --user -u openclaw-gateway -f

# Restart a service manually
kill $(cat /tmp/meta-bridge.pid) && bash /root/social-ai/scripts/start-meta-bridge.sh
kill $(cat /tmp/mem0-api.pid)    && bash /root/social-ai/scripts/start-mem0-api.sh

# Recent errors from database
psql -U postgres -d social_ai -c "SELECT service, error_type, error_msg, created_at FROM error_logs ORDER BY created_at DESC LIMIT 20;"

# OpenClaw status
systemctl --user status openclaw-gateway
```
