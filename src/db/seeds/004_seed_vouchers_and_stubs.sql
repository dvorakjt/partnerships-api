BEGIN;

-- Rerunnable reset for this stage.
TRUNCATE TABLE
  on_demand_voucher_stub_redemption_method_translation,
  on_demand_voucher_stub_redemption_method,
  code_based_voucher_value_details_translation,
  qr_code_based_voucher_value_details_translation,
  link_based_voucher_value_details_translation,
  code_based_voucher_value,
  qr_code_based_voucher_value,
  link_based_voucher_value,
  single_use_voucher,
  multiple_use_voucher,
  manual_voucher_stub_details_translation,
  manual_voucher_stub,
  on_demand_voucher_stub
RESTART IDENTITY CASCADE;

-- Seed all voucher types while keeping rewards valid/available.

-- ON_DEMAND stubs
WITH rewards_by_type AS (
  SELECT
    r.id,
    ROW_NUMBER() OVER (ORDER BY r.id) AS rn
  FROM reward r
  WHERE r.voucher_type = 'ON_DEMAND'
)
INSERT INTO on_demand_voucher_stub (
  id,
  reward_id,
  redeemable_until_exact,
  redeemable_until_local,
  redeemable_for,
  vouchers_remaining
)
OVERRIDING SYSTEM VALUE
SELECT
  5000 + rbt.rn,
  rbt.id,
  NULL,
  NULL,
  '30 days'::INTERVAL,
  400 + (rbt.rn * 10)
FROM rewards_by_type rbt;

WITH on_demand_stub_seed AS (
  SELECT
    s.id,
    ROW_NUMBER() OVER (ORDER BY s.id) AS rn
  FROM on_demand_voucher_stub s
)
INSERT INTO on_demand_voucher_stub_redemption_method (
  on_demand_voucher_stub_id,
  redemption_method
)
SELECT
  odss.id,
  CASE odss.rn % 4
    WHEN 1 THEN 'CODE'::redemption_method
    WHEN 2 THEN 'QR_CODE'::redemption_method
    WHEN 3 THEN 'LINK'::redemption_method
    ELSE 'MANUAL'::redemption_method
  END
FROM on_demand_stub_seed odss;

WITH on_demand_method_seed AS (
  SELECT
    rm.on_demand_voucher_stub_id,
    rm.redemption_method,
    ROW_NUMBER() OVER (ORDER BY rm.on_demand_voucher_stub_id, rm.redemption_method) AS rn
  FROM on_demand_voucher_stub_redemption_method rm
)
INSERT INTO on_demand_voucher_stub_redemption_method_translation (
  on_demand_voucher_stub_id,
  redemption_method,
  language_tag,
  instructions,
  redemption_link_text
)
SELECT
  odms.on_demand_voucher_stub_id,
  odms.redemption_method,
  lang.language_tag,
  CASE odms.redemption_method
    WHEN 'CODE' THEN
      CASE lang.language_tag
        WHEN 'en' THEN FORMAT('Your code will be generated when you redeem this offer (seed %s).', odms.rn)
        WHEN 'es' THEN FORMAT('Tu código se generará cuando canjees esta oferta (semilla %s).', odms.rn)
        ELSE FORMAT('兑换此优惠时将生成兑换代码（种子 %s）。', odms.rn)
      END
    WHEN 'QR_CODE' THEN
      CASE lang.language_tag
        WHEN 'en' THEN FORMAT('A QR code will be generated for this offer at redemption time (seed %s).', odms.rn)
        WHEN 'es' THEN FORMAT('Se generará un código QR para esta oferta al momento del canje (semilla %s).', odms.rn)
        ELSE FORMAT('核销此优惠时将生成二维码（种子 %s）。', odms.rn)
      END
    WHEN 'LINK' THEN
      CASE lang.language_tag
        WHEN 'en' THEN FORMAT('A redemption link will be generated when you claim this offer (seed %s).', odms.rn)
        WHEN 'es' THEN FORMAT('Se generará un enlace de canje cuando reclames esta oferta (semilla %s).', odms.rn)
        ELSE FORMAT('领取此优惠时将生成兑换链接（种子 %s）。', odms.rn)
      END
    ELSE
      CASE lang.language_tag
        WHEN 'en' THEN FORMAT('Follow the manual redemption steps provided after claiming this offer (seed %s).', odms.rn)
        WHEN 'es' THEN FORMAT('Sigue los pasos de canje manual que se proporcionan después de reclamar esta oferta (semilla %s).', odms.rn)
        ELSE FORMAT('领取此优惠后，请按提供的人工兑换步骤操作（种子 %s）。', odms.rn)
      END
  END,
  CASE odms.redemption_method
    WHEN 'LINK' THEN
      CASE lang.language_tag
        WHEN 'en' THEN FORMAT('Open offer link %s', odms.rn)
        WHEN 'es' THEN FORMAT('Abrir enlace de la oferta %s', odms.rn)
        ELSE FORMAT('打开优惠链接 %s', odms.rn)
      END
    ELSE NULL
  END
FROM on_demand_method_seed odms
CROSS JOIN (VALUES ('en'), ('es'), ('zh-Hans')) AS lang(language_tag);

-- MANUAL stubs
WITH rewards_by_type AS (
  SELECT
    r.id,
    ROW_NUMBER() OVER (ORDER BY r.id) AS rn
  FROM reward r
  WHERE r.voucher_type = 'MANUAL'
)
INSERT INTO manual_voucher_stub (
  id,
  reward_id,
  redeemable_until_exact,
  redeemable_until_local,
  redeemable_for,
  vouchers_remaining
)
OVERRIDING SYSTEM VALUE
SELECT
  4000 + rbt.rn,
  rbt.id,
  NULL,
  NULL,
  '14 days'::INTERVAL,
  200 + (rbt.rn * 5)
FROM rewards_by_type rbt;

WITH manual_stub_seed AS (
  SELECT
    s.id,
    ROW_NUMBER() OVER (ORDER BY s.id) AS rn
  FROM manual_voucher_stub s
)
INSERT INTO manual_voucher_stub_details_translation (
  manual_voucher_stub_id,
  language_tag,
  instructions
)
SELECT
  mss.id,
  lang.language_tag,
  CASE lang.language_tag
    WHEN 'en' THEN FORMAT('Show this manual voucher at point of service (seed %s).', mss.rn)
    WHEN 'es' THEN FORMAT('Muestra este cupón manual en el punto de servicio (semilla %s).', mss.rn)
    ELSE FORMAT('请在服务点出示此人工代金凭证（种子 %s）。', mss.rn)
  END
FROM manual_stub_seed mss
CROSS JOIN (VALUES ('en'), ('es'), ('zh-Hans')) AS lang(language_tag);

-- SINGLE_USE vouchers + code-based value + translations
WITH rewards_by_type AS (
  SELECT
    r.id,
    ROW_NUMBER() OVER (ORDER BY r.id) AS rn
  FROM reward r
  WHERE r.voucher_type = 'SINGLE_USE'
)
INSERT INTO single_use_voucher (
  id,
  reward_id,
  redeemable_until
)
OVERRIDING SYSTEM VALUE
SELECT
  2000 + rbt.rn,
  rbt.id,
  '2099-12-31T23:59:59Z'::TIMESTAMPTZ
FROM rewards_by_type rbt;

WITH single_voucher_seed AS (
  SELECT
    sv.id AS single_use_voucher_id,
    ROW_NUMBER() OVER (ORDER BY sv.id) AS rn
  FROM single_use_voucher sv
)
INSERT INTO code_based_voucher_value (
  id,
  single_use_voucher_id,
  multiple_use_voucher_id,
  redemption_code
)
OVERRIDING SYSTEM VALUE
SELECT
  3300 + svs.rn,
  svs.single_use_voucher_id,
  NULL,
  FORMAT('SINGLE-SEED-%s', LPAD(svs.rn::TEXT, 4, '0'))
FROM single_voucher_seed svs;

WITH single_code_seed AS (
  SELECT
    cv.id,
    ROW_NUMBER() OVER (ORDER BY cv.id) AS rn
  FROM code_based_voucher_value cv
  WHERE cv.single_use_voucher_id IS NOT NULL
)
INSERT INTO code_based_voucher_value_details_translation (
  code_based_voucher_value_id,
  language_tag,
  instructions
)
SELECT
  scs.id,
  lang.language_tag,
  CASE lang.language_tag
    WHEN 'en' THEN FORMAT('Enter this single-use code during checkout (seed %s).', scs.rn)
    WHEN 'es' THEN FORMAT('Ingresa este código de un solo uso al pagar (semilla %s).', scs.rn)
    ELSE FORMAT('结账时输入此一次性代码（种子 %s）。', scs.rn)
  END
FROM single_code_seed scs
CROSS JOIN (VALUES ('en'), ('es'), ('zh-Hans')) AS lang(language_tag);

-- MULTIPLE_USE vouchers + QR value + translations
WITH rewards_by_type AS (
  SELECT
    r.id,
    ROW_NUMBER() OVER (ORDER BY r.id) AS rn
  FROM reward r
  WHERE r.voucher_type = 'MULTIPLE_USE'
)
INSERT INTO multiple_use_voucher (
  id,
  reward_id,
  has_usage_cap,
  redeemable_until
)
OVERRIDING SYSTEM VALUE
SELECT
  1000 + rbt.rn,
  rbt.id,
  (rbt.rn % 2 = 0),
  CASE
    WHEN rbt.rn % 3 = 0 THEN NULL
    ELSE '2099-12-31T23:59:59Z'::TIMESTAMPTZ
  END
FROM rewards_by_type rbt;

WITH multi_voucher_seed AS (
  SELECT
    mv.id AS multiple_use_voucher_id,
    ROW_NUMBER() OVER (ORDER BY mv.id) AS rn
  FROM multiple_use_voucher mv
)
INSERT INTO qr_code_based_voucher_value (
  id,
  single_use_voucher_id,
  multiple_use_voucher_id,
  redemption_qr_code
)
OVERRIDING SYSTEM VALUE
SELECT
  3100 + mvs.rn,
  NULL,
  mvs.multiple_use_voucher_id,
  FORMAT('QR-MULTI-SEED-%s', LPAD(mvs.rn::TEXT, 4, '0'))
FROM multi_voucher_seed mvs;

WITH multi_qr_seed AS (
  SELECT
    qv.id,
    ROW_NUMBER() OVER (ORDER BY qv.id) AS rn
  FROM qr_code_based_voucher_value qv
  WHERE qv.multiple_use_voucher_id IS NOT NULL
)
INSERT INTO qr_code_based_voucher_value_details_translation (
  qr_code_based_voucher_value_id,
  language_tag,
  instructions
)
SELECT
  mqs.id,
  lang.language_tag,
  CASE lang.language_tag
    WHEN 'en' THEN FORMAT('Scan this reusable QR code at redemption (seed %s).', mqs.rn)
    WHEN 'es' THEN FORMAT('Escanea este código QR reutilizable al canjear (semilla %s).', mqs.rn)
    ELSE FORMAT('核销时扫描此可重复使用二维码（种子 %s）。', mqs.rn)
  END
FROM multi_qr_seed mqs
CROSS JOIN (VALUES ('en'), ('es'), ('zh-Hans')) AS lang(language_tag);

COMMIT;
