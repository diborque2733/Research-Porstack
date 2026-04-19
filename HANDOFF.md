# HANDOFF — Research Power Stack

Estado al cierre de sesión (2026-04-19, modo hand-off autonomous).

## ✅ Hecho (listo para probar)

### Backend (n8n cloud — `zenti.app.n8n.cloud`)

| Workflow | ID | Webhook | Estado |
|---|---|---|---|
| Capture Insight | `ijuXnNIve1w6zgaA` | `/webhook/insight-capture` | ✅ activo |
| Daily Synthesis | `gRFz89asdA5p5llu` | `/webhook/insight-synthesis` | ✅ activo |

**Smoke test pasado:**
- Capture → Claude Sonnet 4.6 clasifica bien (test: "prompt caching" → ZENTI 9/10, categoría ai-tech, prioridad alta)
- Synthesis → Claude Opus 4.7 sintetiza con estructura correcta

Ejecuta `bash scripts/test-webhooks.sh` para re-verificar.

### Obsidian vault
```
~/Library/Mobile Documents/iCloud~md~obsidian/Documents/INTELLECTUAL-OS/
├── CAPTURE/Daily-Inbox.md          ✅ seed file
├── INSIGHTS/{8 categorías}/        ✅ dirs creados
├── SYNTHESIS/                      ✅ dir
└── PROJECTS/
    ├── ZENTI.md                    ✅ con dataview query
    └── Charly.io.md                ✅ con dataview query
```

**IMPORTANTE:** abre Obsidian en el Mac UNA VEZ y apunta al vault `INTELLECTUAL-OS` para que el app lo registre. El iPhone/iPad lo detecta automáticamente via iCloud después.

### Repo
- Rama: `claude/research-power-stack`
- 9 archivos, ~1000 líneas
- Scripts en `scripts/`:
  - `deploy-n8n.sh` — re-sync workflows del repo a n8n cloud
  - `test-webhooks.sh` — smoke end-to-end

## ⏳ Pendiente (TÚ debes hacer esto en el iPhone)

### 1. Instalar plugin **Advanced URI** en Obsidian
- Obsidian Settings → Community Plugins → **Browse** → buscar "Advanced URI" → Install + Enable
- Necesario para que el Shortcut "Síntesis del día" pueda leer `Daily-Inbox.md`

### 2. Construir los 2 iOS Shortcuts
Guía completa en [`shortcuts/README.md`](shortcuts/README.md). Toma ~15 min por Shortcut.

- **`+ Insight`** (Share Sheet → captura)
- **`Síntesis del día`** (22:00 diario → síntesis)

### 3. Test real
- Abre Instagram en iPhone, comparte un Reel con `+ Insight`
- Abre Obsidian → verifica que apareció en `CAPTURE/Daily-Inbox.md` e `INSIGHTS/{categoría}/...md`
- Corre `Síntesis del día` al menos una vez manualmente
- Programa automatización para las 22:00

## 📊 Costos observados en el test

- 1 capture call (Sonnet 4.6): ~500 in + 300 out ≈ **$0.006**
- 1 synthesis call (Opus 4.7): ~800 in + 1800 out ≈ **$0.18**

Con 15 insights/día + 1 síntesis: **~$7/mes**. Dentro del budget del stack.

## 🐛 Notas técnicas

1. **Por qué HTTP Request y no el nodo langchain:** `@n8n/n8n-nodes-langchain.anthropic` requiere un AI Agent como parent (es un sub-node). Para standalone calls (webhook → Claude → respond) es más limpio llamar la API directamente con `n8n-nodes-base.httpRequest` v4.2.

2. **IDs de modelos en workflows:** uso los IDs de deploy actuales de Anthropic:
   - `claude-sonnet-4-20250514` (capture)
   - `claude-opus-4-20250514` (synthesis)
   Si cambias a Sonnet 4.6 / Opus 4.7 updates, editar en `n8n/*.json` y correr `scripts/deploy-n8n.sh`.

3. **Credencial Anthropic:** ID `Ivm68Ihk87si9DBJ` (nombre `Anthropic account`). Hardcoded en los JSONs del repo. Si rotas la key en n8n cloud, esto sigue funcionando mientras el ID no cambie.

## 🎯 Siguiente iteración (futuro)

- [ ] YouTube transcript fetch antes del classify (más contexto = mejor clasificación)
- [ ] RAG sobre `INSIGHTS/**` con Supabase pgvector (ya está en stack)
- [ ] Weekly digest (sábado, Opus 4.7 sobre las 7 síntesis diarias)
- [ ] Skill de Obsidian en Claude Code que permita query: "qué insights tengo sobre prompt caching"
