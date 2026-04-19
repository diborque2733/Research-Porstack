# iOS Shortcuts — Research Power Stack

Los archivos `.shortcut` son binarios que no se pueden generar desde texto. Esta guía te dice **cómo crearlos en el iPhone/iPad** paso a paso. Toma ~10 minutos.

Son 2 Shortcuts:

1. **`+ Insight`** — captura desde Share Sheet (Reel/YouTube/Tweet → Obsidian)
2. **`Síntesis del día`** — genera síntesis leyendo Daily-Inbox

---

## Shortcut 1: `+ Insight`

### Para qué sirve
En cualquier app (Instagram, YouTube, Safari, Twitter) → Share → **+ Insight** →
en ≤3 seg el insight queda clasificado y guardado en Obsidian.

### Pasos

1. Abre la app **Shortcuts** (Atajos) en iPhone/iPad
2. Tab **Mis Atajos** → **+** (arriba derecha)
3. Nombre: `+ Insight`
4. Tap en el ícono (ajustes) → activa:
   - ✅ **Usar con Hoja de compartir**
   - Tipos aceptados: **URLs, Texto**
5. Agrega estas acciones **en orden**:

#### Acción 1 — Obtener URL
- Buscar: **"Obtener URLs a partir de entrada"**
- Entrada: **Contenido de la hoja de compartir**

#### Acción 2 — Pedir nota (opcional)
- Buscar: **"Pedir entrada"**
- Pregunta: `Nota (opcional, deja vacío si no)`
- Tipo de entrada: **Texto**
- Permitir vacío: **ON**

#### Acción 3 — Obtener título (opcional, si quieres más contexto)
- Buscar: **"Obtener contenidos de URL"**
- URL: **URL** (de Acción 1)
- Método: GET
- No es crítico — puedes saltarlo para velocidad

#### Acción 4 — POST a n8n
- Buscar: **"Obtener contenidos de URL"**
- URL: `https://zenti.app.n8n.cloud/webhook/insight-capture`
- Método: **POST**
- Cuerpo de la solicitud: **JSON**
- Campos JSON:
  - `url` → Variable mágica → URL (Acción 1)
  - `note` → Variable mágica → Entrada proporcionada (Acción 2)
  - `title` → Variable mágica → Nombre (de URL si lo obtuviste en Acción 3)

#### Acción 5 — Parsear respuesta
- Buscar: **"Obtener diccionario de entrada"**
- Entrada: **Contenidos de URL** (de Acción 4)

#### Acción 6 — Extraer `filepath`
- Buscar: **"Obtener valor del diccionario"**
- Obtener: **Valor**
- Clave: `filepath`
- Diccionario: Acción 5

#### Acción 7 — Extraer `insightMd`
- Buscar: **"Obtener valor del diccionario"** (otra)
- Clave: `insightMd`
- Guarda en variable: **MD_INSIGHT**

#### Acción 8 — Extraer `inboxEntry`
- Buscar: **"Obtener valor del diccionario"** (otra)
- Clave: `inboxEntry`
- Guarda en variable: **MD_INBOX**

#### Acción 9 — Escribir archivo insight en Obsidian
- Buscar: **"Abrir URLs"**
- URL: usa expresión con codificación URL:
```
obsidian://new?vault=INTELLECTUAL-OS&file=[URL_ENCODE_FILEPATH]&content=[URL_ENCODE_MD_INSIGHT]&append=false
```
- En Shortcuts usa el bloque **URL** + acciones "Codificación URL" sobre cada variable antes de construir.

#### Acción 10 — Append a Daily-Inbox
- Buscar: **"Abrir URLs"**
- URL:
```
obsidian://new?vault=INTELLECTUAL-OS&file=CAPTURE%2FDaily-Inbox&content=[URL_ENCODE_MD_INBOX]&append=true
```

#### Acción 11 — Feedback visual
- Buscar: **"Mostrar notificación"**
- Título: `✓ Insight capturado`
- Cuerpo: variable `title` del diccionario

6. Guardar. Ya aparece en Share Sheet.

### Test
1. Abre YouTube, encuentra un video
2. Share → **+ Insight**
3. Escribe nota (o vacía) → OK
4. Deberías ver notificación en ≤5s
5. Abre Obsidian → verifica:
   - `CAPTURE/Daily-Inbox.md` tiene nueva entrada
   - `INSIGHTS/{categoría}/{fecha}-{slug}.md` existe

---

## Shortcut 2: `Síntesis del día`

### Para qué sirve
Ejecutas 1 vez al día (noche) → lee Daily-Inbox → genera síntesis estratégica →
guarda en `SYNTHESIS/{fecha}-sintesis.md`.

### Pasos

1. Shortcuts → + → Nombre: `Síntesis del día`

#### Acción 1 — Fecha de hoy
- Buscar: **"Fecha"**
- Formato: `yyyy-MM-dd`
- Guarda en variable: **HOY**

#### Acción 2 — Leer Daily-Inbox
- Buscar: **"Obtener archivo"** o **"Abrir URL"**:
  - Opción A (mejor): app "Obsidian" → ver si tiene action Shortcuts para leer archivos (desde v1.4+)
  - Opción B: usa URL scheme:
```
obsidian://adv-uri?vault=INTELLECTUAL-OS&filepath=CAPTURE%2FDaily-Inbox.md&commandid=open-another-file
```
  (Requiere plugin **Advanced URI** en Obsidian)

**Alternativa sin plugin**: iOS Files app → Obsidian vault en iCloud → "Obtener archivo" directo:
- Buscar: **"Obtener archivo"**
- Ruta: `iCloud Drive/Obsidian/INTELLECTUAL-OS/CAPTURE/Daily-Inbox.md`
- Guarda en variable: **INBOX_CONTENT**

#### Acción 3 — POST a n8n synthesis
- **URL:** `https://zenti.app.n8n.cloud/webhook/insight-synthesis`
- Método: **POST**
- JSON body:
  - `inbox` → variable **INBOX_CONTENT**
  - `date` → variable **HOY**

#### Acción 4 — Parsear respuesta
- **"Obtener diccionario"** sobre respuesta
- Extraer clave `synthesisMd` → variable **SYNTHESIS_MD**
- Extraer clave `filepath` → variable **SYNTHESIS_PATH**

#### Acción 5 — Escribir síntesis en Obsidian
- **"Abrir URL"**:
```
obsidian://new?vault=INTELLECTUAL-OS&file=[URL_ENCODE_SYNTHESIS_PATH]&content=[URL_ENCODE_SYNTHESIS_MD]
```

#### Acción 6 — Abrir la síntesis
- **"Abrir URL"**:
```
obsidian://open?vault=INTELLECTUAL-OS&file=[URL_ENCODE_SYNTHESIS_PATH]
```

2. Guardar.

### Uso diario
- Opción manual: abrir Shortcut → tap
- Opción automática: **Automatización personal** → Hora: `22:00` cada día → ejecutar Shortcut.

---

## Vault de Obsidian esperado

El Shortcut asume esta estructura en iCloud:

```
INTELLECTUAL-OS/
├── CAPTURE/
│   └── Daily-Inbox.md
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
│   └── 2026-04-19-sintesis.md
└── PROJECTS/
    ├── ZENTI.md
    └── Charly.io.md
```

**Crea las carpetas vacías primero** desde Obsidian (iPhone o Mac) antes del primer uso.

---

## Plugins Obsidian recomendados

- **Advanced URI** (obligatorio si quieres que el Shortcut 2 funcione sin pasar por Files)
- **Dataview** (para queries sobre los insights: `priority = alta`, etc.)
- **Templater** (opcional, para PROJECTS/*.md dinámicos)

---

## Troubleshooting

| Problema | Solución |
|---|---|
| Shortcut no aparece en Share Sheet | Ajustes → "Usar con Hoja de compartir" ON |
| "No se pudo conectar a n8n" | Verifica workflow activo en n8n cloud, URL correcta |
| Obsidian no abre el URL | Instala Obsidian iOS; verifica nombre exacto del vault |
| Archivo no se crea | Nombre del vault es **case-sensitive**; `append=true` solo funciona con file existente |
| JSON mal parseado en n8n | Revisa que JSON body tenga `Content-Type: application/json` |
