# Prompt — Clasificar Insight Capturado

Usado en: `n8n/capture-workflow.json` → nodo **Claude Classify**
Modelo: `claude-sonnet-4-6` (costo/velocidad óptimos para clasificación)
Temperature: `0.3` (baja para consistencia)

---

## Input esperado

```json
{
  "url": "https://youtu.be/...",
  "platform": "youtube | instagram | tiktok | twitter | linkedin | web",
  "sharedTitle": "título del Share Sheet",
  "userNote": "nota opcional del usuario al compartir"
}
```

## Prompt

```
Clasifica este insight capturado desde móvil para el Research Power Stack
de Diego (ZENTI + Charly.io).

**URL:** {{url}}
**Plataforma:** {{platform}}
**Título compartido:** {{sharedTitle}}
**Nota del usuario:** {{userNote}}

Devuelve SOLO JSON válido (sin markdown, sin ```json):
{
  "title": "título conciso 5-8 palabras",
  "category": "ai-tech | fundraising | product | growth | sales | ops | leadership | otro",
  "relevance": {
    "zenti": 0-10,
    "charly": 0-10
  },
  "summary": "2-3 frases sobre la idea central",
  "keyPoints": ["punto 1", "punto 2", "punto 3"],
  "actionable": "acción concreta en 1 frase, o 'solo-referencia' si no aplica",
  "tags": ["#tag1", "#tag2", "#tag3"],
  "priority": "alta | media | baja"
}

Contexto de proyectos:
- **ZENTI**: sistema multi-agente AI para evaluar propuestas CORFO/ANID/BID.
  Stack: n8n + Claude + RAG pgvector.
- **Charly.io**: SaaS B2B para gestión de programas de aceleración en LATAM.
```

## Criterios de clasificación

### `category`
- **ai-tech**: modelos, frameworks, agentes, RAG, MCP, prompt engineering
- **fundraising**: VC, rondas, term sheets, métricas de seed/series A
- **product**: UX, feature design, product-led growth, discovery
- **growth**: acquisition, activation, retention, virality
- **sales**: pipeline, cold outreach, demo, enterprise sales
- **ops**: hiring, remote work, management, tooling interno
- **leadership**: founder psych, burnout, decision making, visión
- **otro**: no calza en ninguna

### `relevance.zenti` (0-10)
- **9-10**: aplicable directo (agentes multi-step, eval de propuestas, RAG, CORFO/ANID)
- **6-8**: patrón útil (prompt engineering, arquitectura AI)
- **3-5**: contexto general tech
- **0-2**: irrelevante

### `relevance.charly` (0-10)
- **9-10**: SaaS B2B LATAM, aceleradoras, program management
- **6-8**: growth SaaS, métricas founder-led sales
- **3-5**: startup genérico
- **0-2**: irrelevante

### `priority`
- **alta**: relevancia ≥7 en cualquier proyecto Y acción concreta
- **media**: relevancia 4-6 O solo referencia útil
- **baja**: relevancia <4 O solo-referencia genérica

### `actionable`
- Si no hay acción clara → `"solo-referencia"`
- Si sí hay → imperativo, ≤15 palabras
  - ✅ "Probar prompt chain con self-reflection en evaluador CORFO"
  - ❌ "Podríamos considerar eventualmente evaluar..."

---

## Iteración

Si la clasificación es pobre, ajustar:
1. Primero: mejorar **contexto de proyectos** (agregar detalles específicos)
2. Segundo: agregar **ejemplos few-shot** (1-2 inputs + outputs ideales)
3. Último: subir a `claude-opus-4-7` (sube costo ~5x)

Bitácora de cambios al prompt: commit history de este archivo.
