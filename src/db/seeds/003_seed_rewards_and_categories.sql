BEGIN;

-- Rerunnable reset for this stage.
TRUNCATE TABLE
  reward,
  category
RESTART IDENTITY CASCADE;

INSERT INTO category (id)
OVERRIDING SYSTEM VALUE
VALUES
  (1),
  (2),
  (3),
  (4),
  (5),
  (6),
  (7),
  (8),
  (9),
  (10),
  (11);

INSERT INTO category_translation (category_id, language_tag, category_name)
VALUES
  (1, 'en', 'Grocery'),
  (1, 'es', 'Supermercado'),
  (1, 'zh-Hans', '生鲜杂货'),

  (2, 'en', 'Home & Decor'),
  (2, 'es', 'Hogar y decoración'),
  (2, 'zh-Hans', '家居与装饰'),

  (3, 'en', 'Outdoor & Sporting Goods'),
  (3, 'es', 'Aire libre y artículos deportivos'),
  (3, 'zh-Hans', '户外与运动用品'),

  (4, 'en', 'Mobility & Charging'),
  (4, 'es', 'Movilidad y carga'),
  (4, 'zh-Hans', '出行与充电'),

  (5, 'en', 'Food & Beverage'),
  (5, 'es', 'Comida y bebida'),
  (5, 'zh-Hans', '餐饮'),

  (6, 'en', 'Office Supplies'),
  (6, 'es', 'Suministros de oficina'),
  (6, 'zh-Hans', '办公用品'),

  (7, 'en', 'Entertainment'),
  (7, 'es', 'Entretenimiento'),
  (7, 'zh-Hans', '娱乐'),

  (8, 'en', 'Fitness & Wellness'),
  (8, 'es', 'Fitness y bienestar'),
  (8, 'zh-Hans', '健身与健康'),

  (9, 'en', 'Coffee & Subscriptions'),
  (9, 'es', 'Café y suscripciones'),
  (9, 'zh-Hans', '咖啡与订阅'),

  (10, 'en', 'Cinema & Tickets'),
  (10, 'es', 'Cine y entradas'),
  (10, 'zh-Hans', '电影与票务'),

  (11, 'en', 'General Merchandise'),
  (11, 'es', 'Mercancía general'),
  (11, 'zh-Hans', '综合商品');

WITH seeded_reward AS (
  SELECT
    i,
    ('10000000-0000-4000-8000-' || LPAD(i::TEXT, 12, '0'))::UUID AS id,
    CASE
      WHEN ((i - 1) % 20) + 1 <= 10 THEN ((i - 1) % 20) + 1
      ELSE ((i - 1) % 20) + 2
    END AS partner_id,
    CASE
      WHEN i % 3 = 1 THEN ARRAY['ONLINE', 'IN_STORE']::redemption_forum[]
      WHEN i % 3 = 2 THEN ARRAY['ONLINE']::redemption_forum[]
      ELSE ARRAY['IN_STORE']::redemption_forum[]
    END AS redemption_forums,
    ((i - 1) % 11) + 1 AS category_id
  FROM generate_series(1, 50) AS gs(i)
)
INSERT INTO reward (
  id,
  partner_id,
  redemption_forums,
  voucher_type,
  available_from_exact,
  available_until_exact,
  available_from_local,
  available_until_local
)
SELECT
  sr.id,
  sr.partner_id,
  sr.redemption_forums,
  CASE
    WHEN sr.i % 4 = 1 THEN 'ON_DEMAND'::voucher_type
    WHEN sr.i % 4 = 2 THEN 'MANUAL'::voucher_type
    WHEN sr.i % 4 = 3 THEN 'SINGLE_USE'::voucher_type
    ELSE 'MULTIPLE_USE'::voucher_type
  END,
  NULL,
  NULL,
  NULL,
  NULL
FROM seeded_reward sr;

WITH seeded_reward AS (
  SELECT
    i,
    ('10000000-0000-4000-8000-' || LPAD(i::TEXT, 12, '0'))::UUID AS id,
    ((i - 1) % 11) + 1 AS category_id
  FROM generate_series(1, 50) AS gs(i)
)
INSERT INTO reward_category (reward_id, category_id)
SELECT sr.id, sr.category_id
FROM seeded_reward sr;

WITH seeded_reward AS (
  SELECT
    i,
    ('10000000-0000-4000-8000-' || LPAD(i::TEXT, 12, '0'))::UUID AS id,
    ((i - 1) % 11) + 1 AS category_id
  FROM generate_series(1, 50) AS gs(i)
),
seeded_language AS (
  SELECT *
  FROM (VALUES ('en'), ('es'), ('zh-Hans')) AS v(language_tag)
)
INSERT INTO reward_details_translation (
  reward_id,
  language_tag,
  short_description,
  long_description
)
SELECT
  sr.id,
  sl.language_tag,
  CASE sl.language_tag
    WHEN 'en' THEN FORMAT('Reward %s offer', sr.i)
    WHEN 'es' THEN FORMAT('Oferta de recompensa %s', sr.i)
    ELSE FORMAT('奖励 %s 优惠', sr.i)
  END AS short_description,
  CASE sl.language_tag
    WHEN 'en' THEN FORMAT('Seeded nationwide reward %s mapped to category %s with always-on availability.', sr.i, sr.category_id)
    WHEN 'es' THEN FORMAT('Recompensa nacional sembrada %s asociada a la categoría %s con disponibilidad continua.', sr.i, sr.category_id)
    ELSE FORMAT('全国种子奖励 %s，映射到分类 %s，且持续可用。', sr.i, sr.category_id)
  END AS long_description
FROM seeded_reward sr
CROSS JOIN seeded_language sl;

COMMIT;
