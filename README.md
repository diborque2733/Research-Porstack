# Research Power Stack

Pipeline de captura y síntesis de insights para **ZENTI** y **Charly.io**.

```
📱 iPhone/iPad → Share → + Insight → n8n + Claude → Obsidian (iCloud)
🕙 22:00 daily → Síntesis del día → Claude Opus → SYNTHESIS/ en Obsidian
```

## Quick start

1. [`docs/setup.md`](docs/setup.md) — guía paso a paso (30 min)
2. Importa los 2 workflows en n8n cloud: [`n8n/`](n8n/)
3. Construye los 2 iOS Shortcuts: [`shortcuts/README.md`](shortcuts/README.md)
4. Primer insight → abre Instagram, Share → **+ Insight**

## Componentes

| Archivo | Qué es |
|---|---|
| [`n8n/capture-workflow.json`](n8n/capture-workflow.json) | Webhook que clasifica con Claude Sonnet y devuelve markdown |
| [`n8n/synthesis-workflow.json`](n8n/synthesis-workflow.json) | Webhook que sintetiza el inbox del día con Claude Opus |
| [`prompts/classify-insight.md`](prompts/classify-insight.md) | Prompt del clasificador + criterios de scoring |
| [`prompts/daily-synthesis.md`](prompts/daily-synthesis.md) | Prompt del analista estratégico + heurísticas |
| [`shortcuts/README.md`](shortcuts/README.md) | Guía para construir Shortcuts en iPhone/iPad |
| [`docs/setup.md`](docs/setup.md) | Setup end-to-end |

## Stack

- **n8n cloud** (`zenti.app.n8n.cloud`) — orquestación webhooks
- **Anthropic API** — `claude-sonnet-4-6` (clasificación) + `claude-opus-4-7` (síntesis)
- **Obsidian iOS + iCloud** — vault `INTELECTUAL-BRAIN`
- **iOS Shortcuts** — captura desde Share Sheet + automatización diaria

## Costo estimado

~$7 USD/mes con 15 insights/día. Detalle en [`docs/setup.md`](docs/setup.md#costos-estimados).
