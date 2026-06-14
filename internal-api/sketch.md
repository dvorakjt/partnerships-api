# REST API Microservice — Architecture Sketch

## How the service fits together

```
  Frontend UI / Admin Dashboard
            |
   openapi.json (contract)       ← platform-agnostic interface describing
            |                       all endpoints, request/response schemas,
            |                       and enum types. Frontend generates a
            |                       typed client from this spec.
            |
     HTTP Request (REST)
            |
  ┌─────────────────────┐
  │   NestJS Controller  │  ← handles routing, Guards for auth
  └─────────────────────┘
            |
  ┌──────────────────────┐
  │   DTO + ValidationPipe│  ← class-validator decorators on DTO
  │   (per route)        │     rejects bad input with 400
  └──────────────────────┘
            |
  ┌──────────────────────┐
  │   Service            │  ← business logic lives here
  └──────────────────────┘
            |
  ┌──────────────────────┐
  │   Kysely             │  ← builds type-safe SQL queries
  └──────────────────────┘
            |
  ┌──────────────────────┐
  │   PostgreSQL         │  ← partners, rewards, vouchers etc.
  └──────────────────────┘
```

## NestJS module structure

```
AppModule
  ├── DatabaseModule (@Global)   ← Kysely instance provided via DB_TOKEN
  ├── PartnerModule              ← imports RewardModule
  │     ├── PartnerController
  │     └── PartnerService
  └── RewardModule               ← exports RewardService
        ├── RewardController
        └── RewardService
```

## Request lifecycle

```
POST /partners

1. NestJS Controller receives request
2. ValidationPipe runs class-validator on DTO  →  invalid? return 400
3. Controller calls PartnerService
4. Service uses injected Kysely db to build INSERT query
5. PostgreSQL executes
6. Service returns created resource, Controller returns 201
```

## Resource hierarchy

```
/languages
/categories
  └── /categories/{id}/translations/{languageTag}

/partners
  ├── /partners/{id}/translations/{languageTag}
  ├── /partners/{id}/locations
  └── /partners/{id}/rewards
        └── /rewards/{id}/translations/{languageTag}
        └── /rewards/{id}/categories
        └── /rewards/{id}/voucher(s)
              └── /voucher(s)/{id}/values
                    └── /values/{id}/translations/{languageTag}
        └── /rewards/{id}/voucher-stub
              └── /voucher-stub/translations/{languageTag}
```

## Voucher type determines shape

```
voucherType = SINGLE_USE   →  /rewards/{id}/vouchers      (collection, many per reward)
voucherType = MULTIPLE_USE →  /rewards/{id}/voucher       (singleton, one per reward)
voucherType = ON_DEMAND    →  /rewards/{id}/voucher-stub  (no translations needed)
voucherType = MANUAL       →  /rewards/{id}/voucher-stub  (+ translations)
```

## i18n rule

```
An entity is only "complete" when it has translations in ALL supported languages.

  partner
    ├── translation (en)  ✓
    ├── translation (fr)  ✓
    └── translation (es)  ✗  ← incomplete until this exists
```
