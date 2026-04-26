BEGIN;

-- Rerunnable reset for this stage.
TRUNCATE TABLE
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

-- ------------------------------------------------------------
-- MULTIPLE-USE VOUCHERS (1 row per MULTIPLE_USE reward)
-- ------------------------------------------------------------
INSERT INTO multiple_use_voucher (
  id,
  reward_id,
  has_usage_cap,
  redeemable_until
)
OVERRIDING SYSTEM VALUE
VALUES
  (1001, '10000000-0000-4000-8000-000000000001', FALSE, NULL),
  (1002, '10000000-0000-4000-8000-000000000006', TRUE, '2099-12-31T23:59:59Z'),
  (1003, '10000000-0000-4000-8000-000000000009', TRUE, '2099-12-31T23:59:59Z'),
  (1004, '10000000-0000-4000-8000-000000000012', TRUE, '2100-01-01T00:00:00Z'),
  (1005, '10000000-0000-4000-8000-000000000017', FALSE, NULL),
  (1006, '10000000-0000-4000-8000-000000000021', TRUE, '2099-12-31T23:59:59Z');

INSERT INTO code_based_voucher_value (
  id,
  single_use_voucher_id,
  multiple_use_voucher_id,
  redemption_code
)
OVERRIDING SYSTEM VALUE
VALUES
  (3001, NULL, 1001, 'NORTHSTAR-STOREWIDE-REPEAT'),
  (3002, NULL, 1004, 'WILLOW-MORNING-COMBO'),
  (3003, NULL, 1006, 'RIVERSTONE-LEGACY-INSTORE');

INSERT INTO code_based_voucher_value_details_translation (
  code_based_voucher_value_id,
  language_tag,
  instructions
)
VALUES
  (3001, 'en', 'Apply this reusable code at checkout or show it in-store.'),
  (3001, 'es', 'Aplica este código reutilizable en el pago o muéstralo en tienda.'),
  (3001, 'zh-Hans', '结账时输入该可重复使用代码，或在线下门店出示。'),

  (3002, 'en', 'Present this reusable bakery combo code at the register.'),
  (3002, 'es', 'Presenta este código reutilizable del combo de panadería en caja.'),
  (3002, 'zh-Hans', '在收银台出示该可重复使用的烘焙套餐代码。'),

  (3003, 'en', 'Legacy reusable store code for inactive partner visibility tests.'),
  (3003, 'es', 'Código reutilizable heredado para pruebas de visibilidad de socio inactivo.'),
  (3003, 'zh-Hans', '用于非激活合作伙伴可见性测试的历史可重复门店代码。');

INSERT INTO qr_code_based_voucher_value (
  id,
  single_use_voucher_id,
  multiple_use_voucher_id,
  redemption_qr_code
)
OVERRIDING SYSTEM VALUE
VALUES
  (3101, NULL, 1002, 'QR-HARBORLINE-PRODUCE'),
  (3102, NULL, 1005, 'QR-MERIDIAN-CLUB-ACCESS');

INSERT INTO qr_code_based_voucher_value_details_translation (
  qr_code_based_voucher_value_id,
  language_tag,
  instructions
)
VALUES
  (3101, 'en', 'Scan this reusable QR at participating checkout lanes.'),
  (3101, 'es', 'Escanea este QR reutilizable en cajas participantes.'),
  (3101, 'zh-Hans', '在参与门店收银台扫描此可重复使用二维码。'),

  (3102, 'en', 'Scan this QR at the front desk each time you visit.'),
  (3102, 'es', 'Escanea este QR en recepción cada vez que visites el club.'),
  (3102, 'zh-Hans', '每次到店时在前台扫描此二维码。');

INSERT INTO link_based_voucher_value (
  id,
  single_use_voucher_id,
  multiple_use_voucher_id
)
OVERRIDING SYSTEM VALUE
VALUES
  (3201, NULL, 1003);

INSERT INTO link_based_voucher_value_details_translation (
  link_based_voucher_value_id,
  language_tag,
  instructions,
  redemption_link_url,
  redemption_link_text
)
VALUES
  (3201, 'en', 'Open this reusable service link before in-store boot fitting.', 'https://trailpeak.example.test/redeem/boot-fitting', 'Open TrailPeak redemption'),
  (3201, 'es', 'Abre este enlace reutilizable antes del ajuste de botas en tienda.', 'https://trailpeak.example.test/es/redeem/boot-fitting', 'Abrir canje de TrailPeak'),
  (3201, 'zh-Hans', '到店进行鞋靴适配服务前，打开此可重复使用链接。', 'https://trailpeak.example.test/zh-hans/redeem/boot-fitting', '打开 TrailPeak 核销页');

-- ------------------------------------------------------------
-- SINGLE-USE VOUCHERS (mix of code/qr/link values)
-- For each reward, voucher value is effectively identical except expiration.
-- ------------------------------------------------------------
INSERT INTO single_use_voucher (
  id,
  reward_id,
  redeemable_until
)
OVERRIDING SYSTEM VALUE
VALUES
  -- Reward 2 (Northstar online essentials): code-based
  (2001, '10000000-0000-4000-8000-000000000002', '2099-12-31T23:59:59Z'),
  (2002, '10000000-0000-4000-8000-000000000002', '2035-01-01T00:00:00Z'),
  (2003, '10000000-0000-4000-8000-000000000002', '2001-01-01T00:00:00Z'),

  -- Reward 4 (Pine & Pixel): qr-based (all expired on purpose)
  (2004, '10000000-0000-4000-8000-000000000004', '2005-01-01T00:00:00Z'),
  (2005, '10000000-0000-4000-8000-000000000004', '2009-01-01T00:00:00Z'),
  (2006, '10000000-0000-4000-8000-000000000004', '2010-01-01T00:00:00Z'),

  -- Reward 8 (TrailPeak gear): link-based
  (2007, '10000000-0000-4000-8000-000000000008', '2099-12-31T23:59:59Z'),
  (2008, '10000000-0000-4000-8000-000000000008', NULL),
  (2009, '10000000-0000-4000-8000-000000000008', '2030-01-01T00:00:00Z'),

  -- Reward 13 (CloudCart bulk paper): code-based
  (2010, '10000000-0000-4000-8000-000000000013', '2099-12-31T23:59:59Z'),
  (2011, '10000000-0000-4000-8000-000000000013', '2004-01-01T00:00:00Z'),
  (2012, '10000000-0000-4000-8000-000000000013', '2045-01-01T00:00:00Z'),

  -- Reward 16 (Blue Mesa upgrade): qr-based
  (2013, '10000000-0000-4000-8000-000000000016', '2099-12-31T23:59:59Z'),
  (2014, '10000000-0000-4000-8000-000000000016', NULL),
  (2015, '10000000-0000-4000-8000-000000000016', '2040-01-01T00:00:00Z'),

  -- Reward 19 (KettleForge subscription): link-based
  (2016, '10000000-0000-4000-8000-000000000019', '2099-12-31T23:59:59Z'),
  (2017, '10000000-0000-4000-8000-000000000019', '2032-01-01T00:00:00Z'),
  (2018, '10000000-0000-4000-8000-000000000019', '2038-01-01T00:00:00Z');

INSERT INTO code_based_voucher_value (
  id,
  single_use_voucher_id,
  multiple_use_voucher_id,
  redemption_code
)
OVERRIDING SYSTEM VALUE
VALUES
  (3301, 2001, NULL, 'NORTHSTAR-ESSENTIALS-15'),
  (3302, 2002, NULL, 'NORTHSTAR-ESSENTIALS-15'),
  (3303, 2003, NULL, 'NORTHSTAR-ESSENTIALS-15'),

  (3304, 2010, NULL, 'CLOUDCART-PAPER-BULK-10'),
  (3305, 2011, NULL, 'CLOUDCART-PAPER-BULK-10'),
  (3306, 2012, NULL, 'CLOUDCART-PAPER-BULK-10');

INSERT INTO code_based_voucher_value_details_translation (
  code_based_voucher_value_id,
  language_tag,
  instructions
)
VALUES
  (3301, 'en', 'Use this code on eligible items in your cart.'),
  (3301, 'es', 'Usa este código en artículos elegibles de tu carrito.'),
  (3301, 'zh-Hans', '在购物车内符合条件的商品上使用此代码。'),
  (3302, 'en', 'Use this code on eligible items in your cart.'),
  (3302, 'es', 'Usa este código en artículos elegibles de tu carrito.'),
  (3302, 'zh-Hans', '在购物车内符合条件的商品上使用此代码。'),
  (3303, 'en', 'Use this code on eligible items in your cart.'),
  (3303, 'es', 'Usa este código en artículos elegibles de tu carrito.'),
  (3303, 'zh-Hans', '在购物车内符合条件的商品上使用此代码。'),

  (3304, 'en', 'Apply this code at checkout for bulk paper bundles.'),
  (3304, 'es', 'Aplica este código en el pago para paquetes de papel al por mayor.'),
  (3304, 'zh-Hans', '结账时使用此代码可享受大宗纸张优惠。'),
  (3305, 'en', 'Apply this code at checkout for bulk paper bundles.'),
  (3305, 'es', 'Aplica este código en el pago para paquetes de papel al por mayor.'),
  (3305, 'zh-Hans', '结账时使用此代码可享受大宗纸张优惠。'),
  (3306, 'en', 'Apply this code at checkout for bulk paper bundles.'),
  (3306, 'es', 'Aplica este código en el pago para paquetes de papel al por mayor.'),
  (3306, 'zh-Hans', '结账时使用此代码可享受大宗纸张优惠。');

INSERT INTO qr_code_based_voucher_value (
  id,
  single_use_voucher_id,
  multiple_use_voucher_id,
  redemption_qr_code
)
OVERRIDING SYSTEM VALUE
VALUES
  (3401, 2004, NULL, 'QR-PINEPIXEL-LIVINGROOM'),
  (3402, 2005, NULL, 'QR-PINEPIXEL-LIVINGROOM'),
  (3403, 2006, NULL, 'QR-PINEPIXEL-LIVINGROOM'),

  (3404, 2013, NULL, 'QR-BLUEMESA-PREMIUM-SEAT'),
  (3405, 2014, NULL, 'QR-BLUEMESA-PREMIUM-SEAT'),
  (3406, 2015, NULL, 'QR-BLUEMESA-PREMIUM-SEAT');

INSERT INTO qr_code_based_voucher_value_details_translation (
  qr_code_based_voucher_value_id,
  language_tag,
  instructions
)
VALUES
  (3401, 'en', 'Present this QR at checkout to redeem your furniture offer.'),
  (3401, 'es', 'Presenta este QR en caja para canjear tu oferta de muebles.'),
  (3401, 'zh-Hans', '在结账时出示此二维码以兑换家具优惠。'),
  (3402, 'en', 'Present this QR at checkout to redeem your furniture offer.'),
  (3402, 'es', 'Presenta este QR en caja para canjear tu oferta de muebles.'),
  (3402, 'zh-Hans', '在结账时出示此二维码以兑换家具优惠。'),
  (3403, 'en', 'Present this QR at checkout to redeem your furniture offer.'),
  (3403, 'es', 'Presenta este QR en caja para canjear tu oferta de muebles.'),
  (3403, 'zh-Hans', '在结账时出示此二维码以兑换家具优惠。'),

  (3404, 'en', 'Scan this QR to upgrade your ticket to premium seating.'),
  (3404, 'es', 'Escanea este QR para mejorar tu entrada a asiento premium.'),
  (3404, 'zh-Hans', '扫描此二维码可将门票升级为高端座位。'),
  (3405, 'en', 'Scan this QR to upgrade your ticket to premium seating.'),
  (3405, 'es', 'Escanea este QR para mejorar tu entrada a asiento premium.'),
  (3405, 'zh-Hans', '扫描此二维码可将门票升级为高端座位。'),
  (3406, 'en', 'Scan this QR to upgrade your ticket to premium seating.'),
  (3406, 'es', 'Escanea este QR para mejorar tu entrada a asiento premium.'),
  (3406, 'zh-Hans', '扫描此二维码可将门票升级为高端座位。');

INSERT INTO link_based_voucher_value (
  id,
  single_use_voucher_id,
  multiple_use_voucher_id
)
OVERRIDING SYSTEM VALUE
VALUES
  (3501, 2007, NULL),
  (3502, 2008, NULL),
  (3503, 2009, NULL),

  (3504, 2016, NULL),
  (3505, 2017, NULL),
  (3506, 2018, NULL);

INSERT INTO link_based_voucher_value_details_translation (
  link_based_voucher_value_id,
  language_tag,
  instructions,
  redemption_link_url,
  redemption_link_text
)
VALUES
  (3501, 'en', 'Open this link before checkout for the outdoor gear offer.', 'https://trailpeak.example.test/redeem/gear-up-save', 'Redeem TrailPeak offer'),
  (3501, 'es', 'Abre este enlace antes del pago para la oferta de equipo outdoor.', 'https://trailpeak.example.test/es/redeem/gear-up-save', 'Canjear oferta TrailPeak'),
  (3501, 'zh-Hans', '结账前打开此链接以使用户外装备优惠。', 'https://trailpeak.example.test/zh-hans/redeem/gear-up-save', '兑换 TrailPeak 优惠'),

  (3502, 'en', 'Open this link before checkout for the outdoor gear offer.', 'https://trailpeak.example.test/redeem/gear-up-save', 'Redeem TrailPeak offer'),
  (3502, 'es', 'Abre este enlace antes del pago para la oferta de equipo outdoor.', 'https://trailpeak.example.test/es/redeem/gear-up-save', 'Canjear oferta TrailPeak'),
  (3502, 'zh-Hans', '结账前打开此链接以使用户外装备优惠。', 'https://trailpeak.example.test/zh-hans/redeem/gear-up-save', '兑换 TrailPeak 优惠'),

  (3503, 'en', 'Open this link before checkout for the outdoor gear offer.', 'https://trailpeak.example.test/redeem/gear-up-save', 'Redeem TrailPeak offer'),
  (3503, 'es', 'Abre este enlace antes del pago para la oferta de equipo outdoor.', 'https://trailpeak.example.test/es/redeem/gear-up-save', 'Canjear oferta TrailPeak'),
  (3503, 'zh-Hans', '结账前打开此链接以使用户外装备优惠。', 'https://trailpeak.example.test/zh-hans/redeem/gear-up-save', '兑换 TrailPeak 优惠'),

  (3504, 'en', 'Open this link to apply the subscription discount.', 'https://kettleforge.example.test/redeem/subscription-beans', 'Redeem KettleForge subscription offer'),
  (3504, 'es', 'Abre este enlace para aplicar el descuento de suscripción.', 'https://kettleforge.example.test/es/redeem/subscription-beans', 'Canjear oferta de suscripción KettleForge'),
  (3504, 'zh-Hans', '打开此链接以应用订阅折扣。', 'https://kettleforge.example.test/zh-hans/redeem/subscription-beans', '兑换 KettleForge 订阅优惠'),

  (3505, 'en', 'Open this link to apply the subscription discount.', 'https://kettleforge.example.test/redeem/subscription-beans', 'Redeem KettleForge subscription offer'),
  (3505, 'es', 'Abre este enlace para aplicar el descuento de suscripción.', 'https://kettleforge.example.test/es/redeem/subscription-beans', 'Canjear oferta de suscripción KettleForge'),
  (3505, 'zh-Hans', '打开此链接以应用订阅折扣。', 'https://kettleforge.example.test/zh-hans/redeem/subscription-beans', '兑换 KettleForge 订阅优惠'),

  -- Intentionally missing zh-Hans translation for one value to test exclusion.
  (3506, 'en', 'Open this link to apply the subscription discount.', 'https://kettleforge.example.test/redeem/subscription-beans', 'Redeem KettleForge subscription offer'),
  (3506, 'es', 'Abre este enlace para aplicar el descuento de suscripción.', 'https://kettleforge.example.test/es/redeem/subscription-beans', 'Canjear oferta de suscripción KettleForge');

-- ------------------------------------------------------------
-- ON-DEMAND VOUCHER STUBS
-- ------------------------------------------------------------
INSERT INTO on_demand_voucher_stub (
  id,
  reward_id,
  redeemable_until_exact,
  redeemable_until_local,
  redeemable_for,
  vouchers_remaining
)
OVERRIDING SYSTEM VALUE
VALUES
  (5001, '10000000-0000-4000-8000-000000000003', NULL, NULL, '2 days', 100),
  (5002, '10000000-0000-4000-8000-000000000007', NULL, NULL, '3 days', 1000),
  (5003, '10000000-0000-4000-8000-000000000010', NULL, NULL, '7 days', 500),
  (5004, '10000000-0000-4000-8000-000000000014', NULL, NULL, '14 days', 0),
  (5005, '10000000-0000-4000-8000-000000000018', '2099-12-31T23:59:59Z', NULL, '30 days', NULL),
  (5006, '10000000-0000-4000-8000-000000000022', NULL, NULL, '7 days', 250);

-- ------------------------------------------------------------
-- MANUAL VOUCHER STUBS (+ translations)
-- ------------------------------------------------------------
INSERT INTO manual_voucher_stub (
  id,
  reward_id,
  redeemable_until_exact,
  redeemable_until_local,
  redeemable_for,
  vouchers_remaining
)
OVERRIDING SYSTEM VALUE
VALUES
  (4001, '10000000-0000-4000-8000-000000000005', NULL, NULL, '30 days', 200),
  (4002, '10000000-0000-4000-8000-000000000011', '1991-01-01T00:00:00Z', NULL, '7 days', 0),
  (4003, '10000000-0000-4000-8000-000000000015', NULL, NULL, '1 day', 80),
  (4004, '10000000-0000-4000-8000-000000000020', '2099-12-31T23:59:59Z', NULL, '14 days', 300);

INSERT INTO manual_voucher_stub_details_translation (
  manual_voucher_stub_id,
  language_tag,
  instructions
)
VALUES
  (4001, 'en', 'Request this concierge benefit in-app, then present confirmation to support.'),
  (4001, 'es', 'Solicita este beneficio de asesoría en la app y presenta la confirmación al soporte.'),
  (4001, 'zh-Hans', '在应用内申请该顾问权益，然后向客服出示确认信息。'),

  (4002, 'en', 'Legacy manual process for archival fleet advisory redemptions.'),
  (4002, 'es', 'Proceso manual heredado para canjes archivados de asesoría de flota.'),
  (4002, 'zh-Hans', '用于历史车队咨询核销的旧版人工流程。'),

  -- Intentionally incomplete translations for validity filter testing.
  (4003, 'en', 'Redeem this weekday matinee offer at the ticket counter.'),
  (4003, 'es', 'Canjea esta oferta de matiné entre semana en la taquilla.'),

  (4004, 'en', 'Show this manual reward to barista staff before payment.'),
  (4004, 'es', 'Muestra esta recompensa manual al personal de barra antes del pago.'),
  (4004, 'zh-Hans', '付款前向吧台员工出示该人工核销奖励。');

COMMIT;
