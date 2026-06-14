# Global Context — partnerships-api

This repo contains two services sharing one PostgreSQL database.

## Services at a glance

| Service | Directory | Port | Purpose |
|---------|-----------|------|---------|
| GraphQL read API | `src/` | 4000 | Query partners, rewards, locations |
| NestJS write API | `internal-api/` | 4001 | Create / update partners, rewards, and related resources |

---

## GraphQL read API (`src/`)

### Commands

```bash
npm install
npm run pg-dev:start          # start dev Postgres container (Docker)
npm run migrations up         # run dbmate migrations
npm run gen-types:db          # regenerate src/model/db/generated-types.ts after migrations
npm run gen-types:gql         # regenerate src/model/graphql/generated-types.ts after schema changes
npm start                     # run server on port 4000
npm run test:db               # run pgTAP SQL tests (requires test container)
```

### Layer structure

```
src/
  index.ts                    — Express + Apollo wiring
  graphql/
    schema/                   — GraphQL SDL files (auto-merged at startup)
    resolvers/
      functions/              — resolver implementations (partner, location, reward, language)
      sql/                    — Kysely SELECT builders, one subdir per entity
        common/               — reusable filter expression builders
      voucher/                — voucher retrieval mutation
  db/
    migrations/               — dbmate SQL migration files
    __tests__/                — pgTAP SQL test files
  model/
    db/                       — Kysely DB interface (generated-types.ts) + Point type
    graphql/                  — Apollo resolver types (generated-types.ts) + AppContext
```

### Key views (read API queries these, not base tables)

- `public.v_active_partner` — partners that are active and fully translated
- `public.v_active_partner_location` — locations whose partner is in `v_active_partner`
- `public.v_valid_reward` — rewards whose partner is active and all categories fully translated
- `public.get_available_rewards_in_timezone(timezone)` — rewards available in a given timezone

---

## NestJS write API (`internal-api/`)

### Commands

```bash
cd internal-api
npm install
npm run start:dev             # watch mode, port 4001
npm run build
npm run start:prod
```

### Layer structure

```
internal-api/
  src/
    main.ts                   — NestFactory bootstrap, global ValidationPipe
    app.module.ts             — root module
    database/
      database.module.ts      — @Global() Kysely provider (DB_TOKEN)
      db.types.ts             — DB interface subset; keep in sync with ../src/model/db/generated-types.ts
    partner/
      partner.module.ts       — imports RewardModule so controller can call RewardService
      partner.controller.ts   — all /partners routes including nested /locations and /rewards
      partner.service.ts      — Kysely write queries
      dto/                    — class-validator DTOs (one per operation)
    reward/
      reward.module.ts        — exports RewardService
      reward.controller.ts    — /rewards routes including translations, categories
      reward.service.ts       — Kysely write queries
      dto/
  sketch.md                   — architecture sketch for the write API
  global-context/             — this directory
```

### Validation

Global `ValidationPipe` with `{ whitelist: true, transform: true }` — unknown fields are stripped, primitives are coerced. DTOs use `class-validator` decorators. Update DTOs extend `PartialType` from `@nestjs/mapped-types`.

### Database

Kysely instance injected via `DB_TOKEN` symbol. Uses the same env vars as the GraphQL service (`DB_USER`, `DB_PASSWORD`, `DB_HOST`, `DB_PORT`, `DB_NAME`).

### Conventions

- Controllers are thin — parse params, call service, return result.
- Services own all Kysely query logic.
- `+id` coerces string route params to number for integer PKs.
- All unimplemented service methods throw `HttpException('Not implemented', 501)`.
