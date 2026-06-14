# API Design Context

## Two-service split

- **GraphQL API** (`src/`, port 4000) — all reads. Clients query partners, rewards, locations.
- **NestJS REST API** (`internal-api/`, port 4001) — all writes. Internal service for creating and updating data.

---

## Write API — resource hierarchy

```
/partners
  ├── POST   /partners
  ├── GET    /partners/{id}
  ├── PATCH  /partners/{id}
  ├── DELETE /partners/{id}
  ├── PUT    /partners/{id}/translations/{languageTag}
  ├── DELETE /partners/{id}/translations/{languageTag}
  ├── GET    /partners/{id}/locations
  └── GET    /partners/{id}/rewards
        POST /partners/{id}/rewards           ← reward created here, owned by partner

/rewards/{id}
  ├── GET    /rewards/{id}
  ├── PATCH  /rewards/{id}
  ├── DELETE /rewards/{id}
  ├── PUT    /rewards/{id}/translations/{languageTag}
  ├── DELETE /rewards/{id}/translations/{languageTag}
  ├── POST   /rewards/{id}/categories
  ├── DELETE /rewards/{id}/categories/{catId}
  ├── (TODO) /rewards/{id}/vouchers           (SINGLE_USE — collection)
  ├── (TODO) /rewards/{id}/voucher            (MULTIPLE_USE — singleton)
  └── (TODO) /rewards/{id}/voucher-stub       (ON_DEMAND / MANUAL)
               └── /rewards/{id}/voucher-stub/translations/{languageTag}  (MANUAL only)

(TODO) /languages
(TODO) /categories
         └── /categories/{id}/translations/{languageTag}
```

---

## Voucher type determines route shape

```
voucherType = SINGLE_USE   →  /rewards/{id}/vouchers      (collection, many per reward)
voucherType = MULTIPLE_USE →  /rewards/{id}/voucher       (singleton, one per reward)
voucherType = ON_DEMAND    →  /rewards/{id}/voucher-stub  (no translations needed)
voucherType = MANUAL       →  /rewards/{id}/voucher-stub  (+ translations)
```

---

## i18n rule

An entity is only "complete" when it has translations in ALL supported languages. The GraphQL read API enforces this via database views (`v_active_partner`, `v_valid_reward`) — incomplete entities are invisible to readers. The write API is responsible for seeding all translations.

```
partner
  ├── translation (en)  ✓
  ├── translation (fr)  ✓
  └── translation (es)  ✗  ← partner will not appear in GraphQL until this exists
```

---

## HTTP conventions

| Operation            | Method | Success status |
|----------------------|--------|----------------|
| Create resource      | POST   | 201            |
| Get / list resource  | GET    | 200            |
| Partial update       | PATCH  | 200            |
| Upsert (translation) | PUT    | 200            |
| Delete resource      | DELETE | 204            |
