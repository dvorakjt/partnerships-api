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
  (11),
  (12);

INSERT INTO category_translation (category_id, language_tag, category_name)
VALUES
  (1, 'en', 'Floral & Gifts'),
  (1, 'es', 'Floral y regalos'),
  (1, 'zh-Hans', '花艺与礼品'),

  (2, 'en', 'Furniture & Home'),
  (2, 'es', 'Muebles y hogar'),
  (2, 'zh-Hans', '家具与家居'),

  (3, 'en', 'Cafe & Drinks'),
  (3, 'es', 'Café y bebidas'),
  (3, 'zh-Hans', '咖啡与饮品'),

  (4, 'en', 'Spa & Wellness'),
  (4, 'es', 'Spa y bienestar'),
  (4, 'zh-Hans', '水疗与健康'),

  (5, 'en', 'Beauty & Cosmetics'),
  (5, 'es', 'Belleza y cosméticos'),
  (5, 'zh-Hans', '美妆与护肤'),

  (6, 'en', 'Real Estate Services'),
  (6, 'es', 'Servicios inmobiliarios'),
  (6, 'zh-Hans', '房地产服务'),

  (7, 'en', 'Pet Care'),
  (7, 'es', 'Cuidado de mascotas'),
  (7, 'zh-Hans', '宠物护理'),

  (8, 'en', 'Media & Creative'),
  (8, 'es', 'Medios y creativo'),
  (8, 'zh-Hans', '传媒与创意'),

  (9, 'en', 'Outdoor Gear'),
  (9, 'es', 'Equipo outdoor'),
  (9, 'zh-Hans', '户外装备'),

  (10, 'en', 'Catering & Events'),
  (10, 'es', 'Catering y eventos'),
  (10, 'zh-Hans', '餐饮与活动'),

  (11, 'en', 'Fitness'),
  (11, 'es', 'Fitness'),
  (11, 'zh-Hans', '健身'),

  (12, 'en', 'Technology'),
  (12, 'es', 'Tecnología'),
  (12, 'zh-Hans', '科技');

WITH seeded_reward AS (
  SELECT
    i,
    ('10000000-0000-4000-8000-' || LPAD(i::TEXT, 12, '0'))::UUID AS id,
    ((i - 1) % 12) + 1 AS partner_id,
    CASE ((i - 1) % 12) + 1
      WHEN 1 THEN ARRAY['ONLINE', 'IN_STORE']::redemption_forum[]
      WHEN 2 THEN ARRAY['ONLINE', 'IN_STORE']::redemption_forum[]
      WHEN 3 THEN ARRAY['ONLINE', 'IN_STORE']::redemption_forum[]
      WHEN 4 THEN ARRAY['IN_STORE']::redemption_forum[]
      WHEN 5 THEN ARRAY['ONLINE', 'IN_STORE']::redemption_forum[]
      WHEN 6 THEN ARRAY['ONLINE']::redemption_forum[]
      WHEN 7 THEN ARRAY['IN_STORE']::redemption_forum[]
      WHEN 8 THEN ARRAY['ONLINE']::redemption_forum[]
      WHEN 9 THEN ARRAY['ONLINE', 'IN_STORE']::redemption_forum[]
      WHEN 10 THEN ARRAY['ONLINE', 'IN_STORE']::redemption_forum[]
      WHEN 11 THEN ARRAY['ONLINE', 'IN_STORE']::redemption_forum[]
      ELSE ARRAY['ONLINE', 'IN_STORE']::redemption_forum[]
    END AS redemption_forums,
    ((i - 1) % 12) + 1 AS category_id
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
    ((i - 1) % 12) + 1 AS category_id
  FROM generate_series(1, 50) AS gs(i)
)
INSERT INTO reward_category (reward_id, category_id)
SELECT sr.id, sr.category_id
FROM seeded_reward sr;

WITH seeded_reward AS (
  SELECT
    i,
    ('10000000-0000-4000-8000-' || LPAD(i::TEXT, 12, '0'))::UUID AS id,
    ((i - 1) % 12) + 1 AS category_id,
    ((i - 1) % 12) + 1 AS partner_id,
    ROW_NUMBER() OVER (PARTITION BY ((i - 1) % 12) + 1 ORDER BY i) AS seq
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
    WHEN 'en' THEN
      CASE sr.partner_id
        WHEN 1 THEN FORMAT('$%s off custom bouquet design', 5 + (sr.seq * 5))
        WHEN 2 THEN FORMAT('$%s off handcrafted furniture order', 25 + (sr.seq * 25))
        WHEN 3 THEN FORMAT('$%s off coffee and pastry combo', 3 + sr.seq)
        WHEN 4 THEN FORMAT('%s%% off signature massage session', 10 + (sr.seq * 5))
        WHEN 5 THEN FORMAT('$%s off skincare bundle', 10 + (sr.seq * 5))
        WHEN 6 THEN FORMAT('$%s credit toward closing consultation', 100 + (sr.seq * 50))
        WHEN 7 THEN FORMAT('$%s off pet grooming package', 10 + (sr.seq * 5))
        WHEN 8 THEN FORMAT('$%s off monthly content production plan', 100 + (sr.seq * 50))
        WHEN 9 THEN FORMAT('$%s off hiking gear purchase', 15 + (sr.seq * 10))
        WHEN 10 THEN FORMAT('$%s off event catering order', 50 + (sr.seq * 25))
        WHEN 11 THEN FORMAT('$%s off monthly gym membership', 10 + (sr.seq * 10))
        ELSE FORMAT('$%s off device repair service', 15 + (sr.seq * 10))
      END
    WHEN 'es' THEN
      CASE sr.partner_id
        WHEN 1 THEN FORMAT('$%s de descuento en diseño de ramos personalizados', 5 + (sr.seq * 5))
        WHEN 2 THEN FORMAT('$%s de descuento en pedido de muebles artesanales', 25 + (sr.seq * 25))
        WHEN 3 THEN FORMAT('$%s de descuento en combo de café y pastel', 3 + sr.seq)
        WHEN 4 THEN FORMAT('%s%% de descuento en masaje signature', 10 + (sr.seq * 5))
        WHEN 5 THEN FORMAT('$%s de descuento en paquete de cuidado de la piel', 10 + (sr.seq * 5))
        WHEN 6 THEN FORMAT('Crédito de $%s para consulta de cierre inmobiliario', 100 + (sr.seq * 50))
        WHEN 7 THEN FORMAT('$%s de descuento en paquete de peluquería de mascotas', 10 + (sr.seq * 5))
        WHEN 8 THEN FORMAT('$%s de descuento en plan mensual de producción de contenido', 100 + (sr.seq * 50))
        WHEN 9 THEN FORMAT('$%s de descuento en compra de equipo de senderismo', 15 + (sr.seq * 10))
        WHEN 10 THEN FORMAT('$%s de descuento en pedido de catering para eventos', 50 + (sr.seq * 25))
        WHEN 11 THEN FORMAT('$%s de descuento en membresía mensual del gimnasio', 10 + (sr.seq * 10))
        ELSE FORMAT('$%s de descuento en servicio de reparación de dispositivos', 15 + (sr.seq * 10))
      END
    ELSE
      CASE sr.partner_id
        WHEN 1 THEN FORMAT('定制花束设计立减 $%s', 5 + (sr.seq * 5))
        WHEN 2 THEN FORMAT('手工家具订单立减 $%s', 25 + (sr.seq * 25))
        WHEN 3 THEN FORMAT('咖啡加糕点套餐立减 $%s', 3 + sr.seq)
        WHEN 4 THEN FORMAT('招牌按摩疗程 %s%% 折扣', 10 + (sr.seq * 5))
        WHEN 5 THEN FORMAT('护肤套装立减 $%s', 10 + (sr.seq * 5))
        WHEN 6 THEN FORMAT('房产成交咨询抵扣 $%s', 100 + (sr.seq * 50))
        WHEN 7 THEN FORMAT('宠物美容套餐立减 $%s', 10 + (sr.seq * 5))
        WHEN 8 THEN FORMAT('月度内容制作方案立减 $%s', 100 + (sr.seq * 50))
        WHEN 9 THEN FORMAT('徒步装备购买立减 $%s', 15 + (sr.seq * 10))
        WHEN 10 THEN FORMAT('活动餐饮订单立减 $%s', 50 + (sr.seq * 25))
        WHEN 11 THEN FORMAT('月度健身会员立减 $%s', 10 + (sr.seq * 10))
        ELSE FORMAT('设备维修服务立减 $%s', 15 + (sr.seq * 10))
      END
  END AS short_description,
  CASE sl.language_tag
    WHEN 'en' THEN
      CASE sr.partner_id
        WHEN 1 THEN 'Valid on bouquet and event florals. Online orders and studio pickup supported.'
        WHEN 2 THEN 'Applies to made-to-order home furniture. In-store consultation available.'
        WHEN 3 THEN 'Use for cafe drinks, pastries, and breakfast sets. Pickup and in-store redemption.'
        WHEN 4 THEN 'Redeem in spa locations for massage and selected wellness treatments.'
        WHEN 5 THEN 'Applicable to skincare and makeup bundles in-store or online.'
        WHEN 6 THEN 'Use during real estate advisory booking and qualified closing services.'
        WHEN 7 THEN 'Valid for dog and cat grooming appointments at participating salons.'
        WHEN 8 THEN 'Applies to digital media retainers and campaign production packages.'
        WHEN 9 THEN 'Use for outdoor apparel, camping gear, and trail accessories.'
        WHEN 10 THEN 'Redeem for catering trays, event staffing, and delivery packages.'
        WHEN 11 THEN 'Valid for memberships, class packs, and selected digital coaching plans.'
        ELSE 'Use for screen repairs, diagnostics, and smart-home setup packages.'
      END
    WHEN 'es' THEN
      CASE sr.partner_id
        WHEN 1 THEN 'Válido para ramos y arreglos florales para eventos. Compatible con pedidos en línea y recogida en estudio.'
        WHEN 2 THEN 'Aplica a muebles para el hogar hechos a pedido. Consulta presencial disponible.'
        WHEN 3 THEN 'Úsalo en bebidas, pastelería y combos de desayuno. Canje en tienda y para recoger.'
        WHEN 4 THEN 'Canjeable en sedes del spa para masajes y tratamientos seleccionados de bienestar.'
        WHEN 5 THEN 'Aplicable a paquetes de cuidado de la piel y maquillaje en tienda o en línea.'
        WHEN 6 THEN 'Úsalo al reservar asesoría inmobiliaria y servicios de cierre elegibles.'
        WHEN 7 THEN 'Válido para citas de peluquería de perros y gatos en salones participantes.'
        WHEN 8 THEN 'Aplica a planes de medios digitales y paquetes de producción de campañas.'
        WHEN 9 THEN 'Úsalo para ropa outdoor, equipo de campamento y accesorios de senderismo.'
        WHEN 10 THEN 'Canjeable en bandejas de catering, personal de evento y paquetes con entrega.'
        WHEN 11 THEN 'Válido para membresías, paquetes de clases y planes digitales de entrenamiento seleccionados.'
        ELSE 'Úsalo para reparación de pantallas, diagnósticos e instalación de hogar inteligente.'
      END
    ELSE
      CASE sr.partner_id
        WHEN 1 THEN '适用于花束和活动花艺。支持线上下单与工作室自提。'
        WHEN 2 THEN '适用于定制家居家具订单，支持到店咨询。'
        WHEN 3 THEN '可用于咖啡、糕点和早餐套餐，支持到店与自提核销。'
        WHEN 4 THEN '可在水疗门店用于按摩及指定健康护理项目。'
        WHEN 5 THEN '适用于护肤和彩妆套装，支持线上与门店使用。'
        WHEN 6 THEN '可用于房产咨询预约及符合条件的成交服务。'
        WHEN 7 THEN '适用于参与门店的猫狗美容预约服务。'
        WHEN 8 THEN '适用于数字媒体月度服务与活动内容制作方案。'
        WHEN 9 THEN '可用于户外服饰、露营装备与徒步配件。'
        WHEN 10 THEN '可用于活动餐饮托盘、现场服务人员和配送方案。'
        WHEN 11 THEN '适用于会员、课程包及指定线上教练计划。'
        ELSE '可用于屏幕维修、设备检测与智能家居安装服务。'
      END
  END AS long_description
FROM seeded_reward sr
CROSS JOIN seeded_language sl;

COMMIT;
