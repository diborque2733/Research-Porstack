#!/usr/bin/env bash
# Deploy/update Research Power Stack workflows in n8n cloud.
# Requires: N8N_BASE_URL + N8N_API_KEY in ~/n8n-mcp/.env.local
#
# Usage: bash scripts/deploy-n8n.sh

set -euo pipefail

ENV_FILE="${N8N_ENV_FILE:-$HOME/n8n-mcp/.env.local}"
[ -f "$ENV_FILE" ] || { echo "ERROR: $ENV_FILE not found"; exit 1; }
# shellcheck source=/dev/null
source "$ENV_FILE"

: "${N8N_BASE_URL:?Missing N8N_BASE_URL}"
: "${N8N_API_KEY:?Missing N8N_API_KEY}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CAPTURE_WF_ID="ijuXnNIve1w6zgaA"
SYNTHESIS_WF_ID="gRFz89asdA5p5llu"

clean_and_update() {
  local wf_id="$1"
  local file="$2"
  local tmp="/tmp/$(basename "$file" .json)-clean.json"

  python3 -c "
import json
with open('$file') as f:
    wf = json.load(f)
clean = {
    'name': wf['name'],
    'nodes': wf['nodes'],
    'connections': wf['connections'],
    'settings': wf.get('settings', {'executionOrder': 'v1'})
}
with open('$tmp', 'w') as f:
    json.dump(clean, f)
"

  echo ">>> Updating workflow $wf_id from $file"
  curl -s -X PUT "$N8N_BASE_URL/api/v1/workflows/$wf_id" \
    -H "X-N8N-API-KEY: $N8N_API_KEY" \
    -H "Content-Type: application/json" \
    -d @"$tmp" | python3 -c "
import sys, json
d = json.load(sys.stdin)
if 'id' in d:
    print(f'  OK: {d[\"name\"]} (active={d.get(\"active\",False)})')
else:
    print('  ERROR:', d)
    sys.exit(1)
"

  echo ">>> Re-activating $wf_id"
  curl -s -X POST -H "X-N8N-API-KEY: $N8N_API_KEY" \
    "$N8N_BASE_URL/api/v1/workflows/$wf_id/activate" > /dev/null
}

clean_and_update "$CAPTURE_WF_ID" "$ROOT/n8n/capture-workflow.json"
clean_and_update "$SYNTHESIS_WF_ID" "$ROOT/n8n/synthesis-workflow.json"

echo ""
echo "Webhooks:"
echo "  Capture:   $N8N_BASE_URL/webhook/insight-capture"
echo "  Synthesis: $N8N_BASE_URL/webhook/insight-synthesis"
