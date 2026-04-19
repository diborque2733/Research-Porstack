# Plan de Desarrollo — Clon de GitHub (Local)

## Contexto

Construir una aplicación web que replique funcionalidades core de GitHub para trabajar con repos localmente. Base: carpeta `local-github-clone/` ya creada.

> ⚠️ Plan provisional — sin acceso al Google Doc original. Ajustar según requisitos finales.

## Stack propuesto

| Capa | Tecnología | Razón |
|---|---|---|
| Frontend | Next.js 15 + TypeScript + Tailwind | SSR, DX rápido, ecosistema maduro |
| Backend | Next.js API routes + Node.js | Unificado en un solo proceso |
| DB | SQLite (dev) → Postgres (prod) via Prisma | Portable local, migración fácil |
| Git ops | `isomorphic-git` o `simple-git` | Operar repos reales del filesystem |
| Auth | NextAuth (GitHub OAuth opcional) | Estándar en el stack |
| Tests | Vitest + Playwright | Unit + E2E |

## Alcance MVP (v0.1)

- [ ] **Repos:** listar, crear, clonar desde URL, eliminar
- [ ] **Explorador de archivos:** árbol de directorios + vista de archivo con syntax highlight
- [ ] **Commits:** log con autor/fecha/mensaje, ver diff
- [ ] **Branches:** listar, cambiar, crear
- [ ] **README rendering:** markdown con GFM
- [ ] **Búsqueda:** por nombre de archivo dentro de un repo

## Fuera de alcance v0.1

Issues, PRs, actions/CI, colaboradores, notificaciones, releases, wikis, packages, gists.
(Candidatos para v0.2+)

## Fases

### Fase 1 — Scaffold (0.5 día)
- `npx create-next-app@latest` dentro de `local-github-clone/`
- Configurar Tailwind, ESLint, Prettier, Prisma
- Setup de Vitest + Playwright
- **Entregable:** app arranca en `localhost:3000` con layout base

### Fase 2 — Modelo de datos + git ops (1 día)
- Prisma schema: `Repo`, `User`, `Commit` (cache)
- Wrapper sobre `simple-git` en `lib/git.ts` con ops básicas:
  - `cloneRepo(url, dest)`, `listBranches`, `getLog`, `readTree`, `readBlob`, `getDiff`
- Seed script
- **Entregable:** tests unitarios verdes para `lib/git.ts`

### Fase 3 — Páginas core (2 días)
- `/` → lista de repos
- `/new` → form para clonar
- `/[repo]` → overview + README
- `/[repo]/tree/[branch]/[...path]` → explorador
- `/[repo]/blob/[branch]/[...path]` → vista de archivo
- `/[repo]/commits/[branch]` → log
- `/[repo]/commit/[sha]` → diff
- **Entregable:** navegación E2E funcional

### Fase 4 — Pulido (1 día)
- Syntax highlighting (`shiki`)
- Markdown rendering (`react-markdown` + `remark-gfm`)
- Estados de carga, error boundaries
- Responsive básico
- **Entregable:** Playwright E2E en CI verde

### Fase 5 — Deploy opcional (0.5 día)
- Dockerfile
- `docker-compose.yml` con Postgres
- README con instrucciones

**Total estimado:** ~5 días de desarrollo.

## Estructura de carpetas propuesta

```
local-github-clone/
├── app/                  # Next.js app router
│   ├── (routes)/
│   └── api/
├── components/           # UI reutilizable
├── lib/
│   ├── git.ts           # Wrapper de simple-git
│   ├── db.ts            # Cliente Prisma
│   └── utils.ts
├── prisma/
│   └── schema.prisma
├── tests/
│   ├── unit/
│   └── e2e/
├── repos/               # Repos clonados (gitignored)
└── package.json
```

## Riesgos

1. **Performance en repos grandes** — mitigar con paginación de commits y lazy loading del árbol.
2. **Seguridad de paths** — validar que `[...path]` no escape del directorio del repo (path traversal).
3. **Binarios** — detectar y mostrar tamaño en lugar de contenido.
4. **Clonado bloqueante** — usar jobs async o streaming.

## Verificación

- `npm run test` — unit tests verdes
- `npm run test:e2e` — Playwright pasa flujo: clonar repo → navegar árbol → ver diff
- Smoke manual: clonar un repo público real y verificar renderizado

## Siguientes pasos para empezar

1. Confirmar stack y alcance
2. `cd local-github-clone && npx create-next-app@latest . --ts --tailwind --app --no-src-dir`
3. Instalar deps: `npm i simple-git prisma @prisma/client react-markdown remark-gfm shiki`
4. Ejecutar Fase 1
