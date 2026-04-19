# Research Power Stack — Setup

Pipeline completo para capturar insights desde móvil, clasificarlos con Claude, y sintetizarlos diariamente. Integra iOS Shortcut + n8n cloud + Claude + Obsidian.

## Arquitectura

```
📱 iPhone/iPad (Reel/YouTube/Tweet)
  └─ Share Sheet → Shortcut "+ Insight"
       └─ POST → n8n cloud (zenti.app.n8n.cloud/webhook/insight-capture)
            ├─ Claude Sonnet 4.6: clasifica
            │   (category, relevance ZENTI/Charly, priority, tags, acción)
            └─ Devuelve markdown + filepath
       └─ Shortcut escribe en Obsidian via URL scheme
            ├─ CAPTURE/Daily-Inbox.md (append)
            └─ INSIGHTS/{category}/{fecha}-{slug}.md (nuevo)
       → iCloud sync → Mac / iPad / iPhone

🕙 22:00 cada día (Automatización iOS)
  └─ Shortcut "Síntesis del día"
       └─ Lee CAPTURE/Daily-Inbox.md
       └─ POST → n8n (zenti.app.n8n.cloud/webhook/insight-synthesis)
            └─ Claude Opus 4.7: sintetiza
                (Top 3, impacto ZENTI, impacto Charly, conexiones, acciones)
       └─ Shortcut escribe en SYNTHESIS/{fecha}-sintesis.md
       └─ Abre la nota
```

## Setup paso a paso

### 1. Obsidian vault

**Dónde:** iCloud Drive / Obsidian / INTELLECTUAL-OS/

**Estructura mínima (crear carpetas vacías):**
```
INTELLECTUAL-OS/
├── CAPTURE/
├── INSIGHTS/
│   ├── ai-tech/
│   ├── fundraising/
│   ├── product/
│   ├── growth/
│   ├── sales/
│   ├── ops/
│   ├── leadership/
│   └── otro/
├── SYNTHESIS/
└── PROJECTS/
```

**Crear archivo semilla:** `CAPTURE/Daily-Inbox.md`:
```markdown
# Daily Inbox

_Insights capturados desde Share Sheet. Se sintetizan cada noche._
```

**Plugins necesarios:** Advanced URI (Settings → Community Plugins → buscar "Advanced URI" → Install + Enable)

### 2. n8n cloud — Workflows

Cuenta: `zenti.app.n8n.cloud`

**Ya importados y activos** (deploy vía `scripts/deploy-n8n.sh`):
- `Research Power Stack - Capture Insight` → webhook `/webhook/insight-capture`
- `Research Power Stack - Daily Synthesis` → webhook `/webhook/insight-synthesis`

Ambos usan **HTTP Request node** contra `api.anthropic.com/v1/messages` (no el nodo langchain, que requiere parent AI Agent). Credencial: `Anthropic account` (tipo `anthropicApi`).

**Modelos:**
- Capture → `claude-sonnet-4-20250514` (clasificación barata)
- Synthesis → `claude-opus-4-20250514` (razonamiento estratégico)

**Re-deploy** (si editas los JSONs del repo):
```bash
bash scripts/deploy-n8n.sh
```

**Test capture desde terminal Mac:**
```bash
curl -X POST https://zenti.app.n8n.cloud/webhook/insight-capture \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    "title": "Test insight",
    "note": "Testing the pipeline"
  }'
```
Respuesta esperada (JSON):
```json
{
  "status": "ok",
  "title": "...",
  "category": "otro",
  "priority": "baja",
  "filepath": "INSIGHTS/otro/2026-04-19-....md",
  "insightMd": "---\ntitle: ...",
  "inboxEntry": "\n### ..."
}
```

### 3. iOS Shortcuts

Ver [shortcuts/README.md](../shortcuts/README.md) — guía completa de construcción en el iPhone.

Son 2 Shortcuts:
- **+ Insight** (Share Sheet) → captura
- **Síntesis del día** (22:00 daily) → síntesis

### 4. Primer uso real

1. Abre Instagram o YouTube en iPhone
2. Encuentra un Reel/video sobre AI agents o SaaS growth
3. Share → **+ Insight** → escribe nota: `"Interesante patrón de prompt chaining"`
4. Espera notificación ✅
5. Abre Obsidian → revisa `CAPTURE/Daily-Inbox.md` y `INSIGHTS/ai-tech/...md`

### 5. Síntesis diaria

Primera noche:
1. Abre Shortcuts → **Síntesis del día** → tap
2. Se genera `SYNTHESIS/2026-04-19-sintesis.md`
3. Obsidian la abre automáticamente

Automatizar:
1. Shortcuts app → **Automatización** → **+** → **Hora del día**
2. Hora: 22:00 — Repetir: Diariamente
3. Acción: **Ejecutar Shortcut** → `Síntesis del día`
4. ✅ Preguntar antes de ejecutar: **OFF**

---

## Costos estimados

Con uso típico (15 insights/día):

| Concepto | Modelo | Tokens/call | Cost/call | Cost/día |
|---|---|---|---|---|
| Clasificación | Sonnet 4.6 | ~500 in / ~200 out | $0.005 | $0.08 |
| Síntesis (1/día) | Opus 4.7 | ~3000 in / ~1500 out | $0.15 | $0.15 |
| **Total** | | | | **~$0.23/día** |

**Mensual:** ~$7 USD. Si crece a 50 insights/día → ~$20/mes.

---

## Extensiones futuras

- [ ] Transcript de YouTube automático (whisper o youtube-transcript API → más contexto para clasificar)
- [ ] RAG sobre `INSIGHTS/**` → agente que responde "¿qué insights tengo sobre prompt caching?"
- [ ] Weekly digest (sábado) que sintetiza las 7 síntesis diarias
- [ ] Conexión a `PROJECTS/ZENTI.md` — cada insight con `relevance.zenti >= 7` linkea automáticamente
- [ ] Dashboard HTML (local) que lee Obsidian vault y muestra métricas: insights/semana, categorías, relevancia media
- [ ] Telegram bot como alternativa al Shortcut (útil para desktop capture)

---

## Troubleshooting

| Síntoma | Causa probable | Fix |
|---|---|---|
| Shortcut falla con "400 Bad Request" | JSON mal formado | Check `Content-Type: application/json` y estructura del body |
| Claude devuelve texto fuera de JSON | Temperatura muy alta o contexto largo | Bajar temp a 0.2, o prompt más estricto con "SOLO JSON" |
| Obsidian no crea el archivo | Nombre de vault incorrecto | `INTELLECTUAL-OS` es case-sensitive en URL scheme |
| Insights mal clasificados | Contexto de proyectos desactualizado | Editar prompt en n8n + commit cambio en `prompts/classify-insight.md` |
| Síntesis genérica / poco accionable | Prompt no itera sobre ejemplos reales | Agregar 1 few-shot a `prompts/daily-synthesis.md` con output ganador |
| Cost spike | Demasiados insights sin filtro | Agregar step "skip if relevance<3" antes de guardar |

---

## Archivos de este repo

- `n8n/capture-workflow.json` — import en n8n cloud
- `n8n/synthesis-workflow.json` — import en n8n cloud
- `prompts/classify-insight.md` — prompt del step de clasificación + criterios
- `prompts/daily-synthesis.md` — prompt de síntesis + heurísticas
- `shortcuts/README.md` — cómo construir los 2 Shortcuts en iOS
- `docs/setup.md` — este archivo
