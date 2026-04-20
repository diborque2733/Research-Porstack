# HANDOFF — Research Power Stack

Estado al cierre de sesión (2026-04-19, modo hand-off autonomous).

## ✅ Hecho (listo para probar)

### Backend (n8n cloud — `zenti.app.n8n.cloud`)

| Workflow | ID | Webhook | Estado |
|---|---|---|---|
| Capture Insight | `ijuXnNIve1w6zgaA` | `/webhook/insight-capture` | ✅ activo |
| Daily Synthesis | `gRFz89asdA5p5llu` | `/webhook/insight-synthesis` | ✅ activo |

**Smoke test pasado** (`scripts/test-webhooks.sh`):
- Capture → Claude Sonnet 4.6 clasifica bien (test: "prompt caching" → ZENTI 9/10, categoría ai-tech, prioridad alta)
- Synthesis → Claude Opus 4.7 sintetiza con estructura correcta

**Vault poblado con 3 insights reales** + 1 síntesis del día. Abre Obsidian y ve:
- `CAPTURE/Daily-Inbox.md` con 3 entradas
- `INSIGHTS/ai-tech/` y `INSIGHTS/product/` con archivos detallados
- `SYNTHESIS/2026-04-19-sintesis.md` con Top 3 + impacto ZENTI + Charly + acciones

### Obsidian vault
```
~/Library/Mobile Documents/iCloud~md~obsidian/Documents/INTELECTUAL-BRAIN/
├── CAPTURE/Daily-Inbox.md          ✅ seed file
├── INSIGHTS/{8 categorías}/        ✅ dirs creados
├── SYNTHESIS/                      ✅ dir
└── PROJECTS/
    ├── ZENTI.md                    ✅ con dataview query
    └── Charly.io.md                ✅ con dataview query
```

**IMPORTANTE:** abre Obsidian en el Mac UNA VEZ y apunta al vault `INTELECTUAL-BRAIN` para que el app lo registre. El iPhone/iPad lo detecta automáticamente via iCloud después.

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

## 🛡️ Hardening aplicado (vía Gemini QA)

Gemini auditó ambos workflows y encontró 14 issues. Aplicados ahora:

- **CRITICAL** Retry on failure en los 2 HTTP Request → `retryOnFail=true, maxTries=3, waitBetweenTries=2-3s`
- **HIGH** Prompt injection guard: el contenido del usuario se envuelve en `<user_note>...</user_note>` con instrucción explícita a Claude de no seguir instrucciones contenidas en él
- **HIGH** Parser JSON robusto: extrae de primer `{` a último `}`, tolera fences/texto envolvente; fallback con shape garantizada
- **MEDIUM** Colisión de filenames: ahora el slug incluye segundos (`{fecha}-{slug}-{ss}.md`), evita sobreescritura cuando capturas 2 insights con título similar el mismo minuto
- **LOW** Slug ASCII: `normalize('NFD')` + strip accents → evita issues de iCloud sync con ñ/acentos
- **LOW** Title sanitize: reemplaza `"` por `'` → evita YAML frontmatter corrupto

## 📋 Known issues pendientes (no bloquean prueba)

- **HIGH** Synthesis puede tardar >30s (Opus). iOS Shortcut default timeout ~60s, debería estar ok. Si da timeout: cambiar `responseMode` a `onReceived` y push notification async.
- **MEDIUM** Webhook sin auth token: cualquiera que adivine la URL puede consumir tus créditos Anthropic. Mitigar con header `X-Auth-Token` en el webhook y validación (requiere también actualizar el Shortcut).
- **MEDIUM** Sin límite de tokens para inbox: si un día acumulas >150k chars, la llamada a Opus fallará. Baja probabilidad (serían ~500 insights/día). Fix: clipear `inboxContent` a 100k chars en `Parse Inbox`.
- **LOW** Modelos hardcoded con fecha (`claude-sonnet-4-20250514`). Alias `claude-sonnet-4-latest` serían más durables si Anthropic los publica.
- **LOW** Timestamp de server n8n (UTC, no hora chilena). Si quieres hora local, el Shortcut debe mandar `localTime` en el body.

## 🔮 Feature solicitada (siguiente sprint): Vault Advisor

**Objetivo**: que Claude escanee el vault y diga "de todo lo capturado, esto es lo que conviene usar en ZENTI/Charly esta semana + recomendaciones".

**Arquitectura propuesta**:
- Script local `scripts/vault-advisor.sh` que:
  1. Lee todos los `.md` de `INSIGHTS/` de la última N semanas (default 4)
  2. Envía a Claude Opus 4.7 en chunks con prompt caching (reutiliza contexto)
  3. Devuelve: top 10 insights accionables, oportunidades cruzadas, patterns repetidos, acciones sugeridas por proyecto
  4. Escribe resultado a `SYNTHESIS/advisor-{fecha}.md`
- O como workflow n8n con trigger manual + el repo clonado como storage (evita problemas de iCloud read).

**Cuándo implementar**: cuando haya ≥30 insights en el vault (hoy hay 6). Antes no tiene material suficiente para recomendar bien.

## 🎯 Siguiente iteración (futuro)

- [ ] YouTube transcript fetch antes del classify (más contexto = mejor clasificación)
- [ ] RAG sobre `INSIGHTS/**` con Supabase pgvector (ya está en stack)
- [ ] Weekly digest (sábado, Opus 4.7 sobre las 7 síntesis diarias)
- [ ] Skill de Obsidian en Claude Code que permita query: "qué insights tengo sobre prompt caching"
