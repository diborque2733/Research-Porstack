#!/usr/bin/env bash
# Smoke test de los 2 webhooks del Research Power Stack.
# Usage: bash scripts/test-webhooks.sh

set -euo pipefail

ENV_FILE="${N8N_ENV_FILE:-$HOME/n8n-mcp/.env.local}"
# shellcheck source=/dev/null
source "$ENV_FILE"

: "${N8N_BASE_URL:?Missing N8N_BASE_URL}"

echo "=== TEST 1/2: Capture ==="
curl -s -X POST "$N8N_BASE_URL/webhook/insight-capture" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://www.youtube.com/watch?v=smoke-test",
    "title": "Smoke test: Claude prompt caching cuts AI costs 90%",
    "note": "Test from deploy script"
  }' | python3 -c "
import sys, json
d = json.load(sys.stdin)
if isinstance(d, list) and d:
    d = d[0]
print(f\"  status:   {d.get('status','FAIL')}\")
print(f\"  title:    {d.get('title','?')}\")
print(f\"  category: {d.get('category','?')}\")
print(f\"  ZENTI:    {d.get('zentiRelevance','?')}/10\")
print(f\"  Charly:   {d.get('charlyRelevance','?')}/10\")
"

echo ""
echo "=== TEST 2/2: Synthesis ==="
curl -s -X POST "$N8N_BASE_URL/webhook/insight-synthesis" \
  -H "Content-Type: application/json" \
  -d '{
    "date": "'"$(date +%Y-%m-%d)"'",
    "inbox": "### Claude Prompt Caching\n- Relevancia: ZENTI 9/10\n- Resumen: Prompt caching reduce costos 90%\n- Acción: Implementar en evaluador CORFO\n\n### DIMOS Physical AI OS\n- Relevancia: ZENTI 5/10\n- Resumen: OS para robots\n- Acción: solo-referencia"
  }' | python3 -c "
import sys, json
d = json.load(sys.stdin)
if isinstance(d, list) and d:
    d = d[0]
md = d.get('synthesisMd','')
print(f\"  status:   {d.get('status','FAIL')}\")
print(f\"  filepath: {d.get('filepath','?')}\")
print(f\"  preview (first 400 chars):\")
print('  ' + md[:400].replace(chr(10), chr(10) + '  '))
"
