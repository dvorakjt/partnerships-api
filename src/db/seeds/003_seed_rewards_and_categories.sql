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

INSERT INTO reward (
  id,
  partner_id,
  redemption_forums,
  voucher_type,
  available_from_exact,
  available_until_exact,
  available_from_local,
  available_until_local
) VALUES
  ('10000000-0000-4000-8000-000000000001', 1, ARRAY['ONLINE', 'IN_STORE']::redemption_forum[], 'MULTIPLE_USE', NULL, NULL, NULL, NULL),
  ('10000000-0000-4000-8000-000000000002', 1, ARRAY['ONLINE']::redemption_forum[], 'SINGLE_USE', '2000-01-01T00:00:00Z', '2100-01-01T00:00:00Z', NULL, NULL),
  ('10000000-0000-4000-8000-000000000003', 1, ARRAY['IN_STORE']::redemption_forum[], 'ON_DEMAND', '2200-01-01T00:00:00Z', '2300-01-01T00:00:00Z', NULL, NULL),

  ('10000000-0000-4000-8000-000000000004', 2, ARRAY['ONLINE']::redemption_forum[], 'SINGLE_USE', NULL, NULL, NULL, NULL),
  ('10000000-0000-4000-8000-000000000005', 2, ARRAY['ONLINE']::redemption_forum[], 'MANUAL', '2001-01-01T00:00:00Z', '2099-12-31T23:59:59Z', NULL, NULL),

  ('10000000-0000-4000-8000-000000000006', 3, ARRAY['IN_STORE']::redemption_forum[], 'MULTIPLE_USE', NULL, NULL, NULL, NULL),
  ('10000000-0000-4000-8000-000000000007', 3, ARRAY['IN_STORE']::redemption_forum[], 'ON_DEMAND', NULL, NULL, NULL, NULL),

  ('10000000-0000-4000-8000-000000000008', 4, ARRAY['ONLINE', 'IN_STORE']::redemption_forum[], 'SINGLE_USE', NULL, NULL, NULL, NULL),
  ('10000000-0000-4000-8000-000000000009', 4, ARRAY['IN_STORE']::redemption_forum[], 'MULTIPLE_USE', NULL, NULL, NULL, NULL),

  ('10000000-0000-4000-8000-000000000010', 5, ARRAY['ONLINE', 'IN_STORE']::redemption_forum[], 'ON_DEMAND', NULL, NULL, NULL, NULL),
  ('10000000-0000-4000-8000-000000000011', 5, ARRAY['ONLINE']::redemption_forum[], 'MANUAL', '1990-01-01T00:00:00Z', '1991-01-01T00:00:00Z', NULL, NULL),

  ('10000000-0000-4000-8000-000000000012', 6, ARRAY['IN_STORE']::redemption_forum[], 'MULTIPLE_USE', NULL, NULL, NULL, NULL),

  ('10000000-0000-4000-8000-000000000013', 7, ARRAY['ONLINE']::redemption_forum[], 'SINGLE_USE', NULL, NULL, NULL, NULL),
  ('10000000-0000-4000-8000-000000000014', 7, ARRAY['ONLINE']::redemption_forum[], 'ON_DEMAND', NULL, NULL, NULL, NULL),

  ('10000000-0000-4000-8000-000000000015', 8, ARRAY['IN_STORE']::redemption_forum[], 'MANUAL', NULL, NULL, NULL, NULL),
  ('10000000-0000-4000-8000-000000000016', 8, ARRAY['ONLINE', 'IN_STORE']::redemption_forum[], 'SINGLE_USE', '2001-01-01T00:00:00Z', '2099-12-31T23:59:59Z', NULL, NULL),

  ('10000000-0000-4000-8000-000000000017', 9, ARRAY['ONLINE', 'IN_STORE']::redemption_forum[], 'MULTIPLE_USE', NULL, NULL, NULL, NULL),
  ('10000000-0000-4000-8000-000000000018', 9, ARRAY['ONLINE']::redemption_forum[], 'ON_DEMAND', NULL, NULL, NULL, NULL),

  ('10000000-0000-4000-8000-000000000019', 10, ARRAY['ONLINE']::redemption_forum[], 'SINGLE_USE', NULL, NULL, NULL, NULL),
  ('10000000-0000-4000-8000-000000000020', 10, ARRAY['IN_STORE']::redemption_forum[], 'MANUAL', NULL, NULL, NULL, NULL),

  ('10000000-0000-4000-8000-000000000021', 11, ARRAY['IN_STORE']::redemption_forum[], 'MULTIPLE_USE', NULL, NULL, NULL, NULL),
  ('10000000-0000-4000-8000-000000000022', 11, ARRAY['ONLINE']::redemption_forum[], 'ON_DEMAND', NULL, NULL, NULL, NULL);

INSERT INTO reward_category (reward_id, category_id)
VALUES
  ('10000000-0000-4000-8000-000000000001', 11),
  ('10000000-0000-4000-8000-000000000002', 11),
  ('10000000-0000-4000-8000-000000000003', 11),

  ('10000000-0000-4000-8000-000000000004', 2),
  ('10000000-0000-4000-8000-000000000005', 2),

  ('10000000-0000-4000-8000-000000000006', 1),
  ('10000000-0000-4000-8000-000000000007', 1),

  ('10000000-0000-4000-8000-000000000008', 3),
  ('10000000-0000-4000-8000-000000000009', 3),

  ('10000000-0000-4000-8000-000000000010', 4),
  ('10000000-0000-4000-8000-000000000011', 4),

  ('10000000-0000-4000-8000-000000000012', 5),

  ('10000000-0000-4000-8000-000000000013', 6),
  ('10000000-0000-4000-8000-000000000014', 6),

  ('10000000-0000-4000-8000-000000000015', 10),
  ('10000000-0000-4000-8000-000000000016', 10),

  ('10000000-0000-4000-8000-000000000017', 8),
  ('10000000-0000-4000-8000-000000000018', 8),

  ('10000000-0000-4000-8000-000000000019', 9),
  ('10000000-0000-4000-8000-000000000020', 5),

  ('10000000-0000-4000-8000-000000000021', 11),
  ('10000000-0000-4000-8000-000000000022', 11);

INSERT INTO reward_details_translation (
  reward_id,
  language_tag,
  short_description,
  long_description
) VALUES
  ('10000000-0000-4000-8000-000000000001', 'en', 'Storewide partner savings', 'General discount access across online checkout and in-store purchases.'),
  ('10000000-0000-4000-8000-000000000001', 'es', 'Ahorro general en tienda', 'Acceso a descuentos generales en compras en línea y en tienda física.'),
  ('10000000-0000-4000-8000-000000000001', 'zh-Hans', '全场优惠', '线上结账与线下门店购买均可使用的综合折扣权益。'),

  ('10000000-0000-4000-8000-000000000002', 'en', 'Online essentials bundle', 'Discounted offer for select everyday essentials purchased online.'),
  ('10000000-0000-4000-8000-000000000002', 'es', 'Paquete de esenciales en línea', 'Oferta con descuento para productos esenciales seleccionados comprados en línea.'),
  ('10000000-0000-4000-8000-000000000002', 'zh-Hans', '线上日用品组合优惠', '针对指定日用品的线上折扣活动。'),

  ('10000000-0000-4000-8000-000000000003', 'en', 'In-store seasonal bonus', 'Seasonal in-store promotion intentionally set outside current availability.'),
  ('10000000-0000-4000-8000-000000000003', 'es', 'Bono estacional en tienda', 'Promoción estacional en tienda configurada intencionalmente fuera de disponibilidad actual.'),
  ('10000000-0000-4000-8000-000000000003', 'zh-Hans', '门店季节性奖励', '故意设置为当前不可用时间段的门店季节活动。'),

  ('10000000-0000-4000-8000-000000000004', 'en', 'Living room refresh deal', 'Online discount for curated furniture and décor collections.'),
  ('10000000-0000-4000-8000-000000000004', 'es', 'Oferta para renovar la sala', 'Descuento en línea para colecciones seleccionadas de muebles y decoración.'),
  ('10000000-0000-4000-8000-000000000004', 'zh-Hans', '客厅焕新优惠', '精选家具与家居装饰系列的线上折扣。'),

  ('10000000-0000-4000-8000-000000000005', 'en', 'Design concierge credit', 'Manual fulfillment reward for premium design support sessions.'),
  ('10000000-0000-4000-8000-000000000005', 'es', 'Crédito de asesoría de diseño', 'Recompensa de entrega manual para sesiones premium de asesoría en diseño.'),
  ('10000000-0000-4000-8000-000000000005', 'zh-Hans', '设计顾问服务抵扣', '面向高级设计咨询服务的人工核销类奖励。'),

  ('10000000-0000-4000-8000-000000000006', 'en', 'Neighborhood produce saver', 'Recurring in-store discount on produce and pantry staples.'),
  ('10000000-0000-4000-8000-000000000006', 'es', 'Ahorro en frutas y verduras', 'Descuento recurrente en tienda para productos frescos y básicos de despensa.'),
  ('10000000-0000-4000-8000-000000000006', 'zh-Hans', '社区生鲜省钱权益', '门店可重复使用的生鲜与日用品优惠。'),

  ('10000000-0000-4000-8000-000000000007', 'en', 'Weekend fresh picks', 'On-demand reward for weekend produce selections at participating stores.'),
  ('10000000-0000-4000-8000-000000000007', 'es', 'Selección fresca de fin de semana', 'Recompensa bajo demanda para productos frescos de fin de semana en tiendas participantes.'),
  ('10000000-0000-4000-8000-000000000007', 'zh-Hans', '周末生鲜精选', '适用于指定门店周末生鲜商品的按需奖励。'),

  ('10000000-0000-4000-8000-000000000008', 'en', 'Gear up and save', 'Discount on outdoor gear purchases online and at flagship locations.'),
  ('10000000-0000-4000-8000-000000000008', 'es', 'Ahorra en equipo outdoor', 'Descuento en compras de equipo outdoor en línea y en tiendas insignia.'),
  ('10000000-0000-4000-8000-000000000008', 'zh-Hans', '户外装备省钱优惠', '线上与旗舰门店均可使用的户外装备折扣。'),

  ('10000000-0000-4000-8000-000000000009', 'en', 'Boot fitting service credit', 'In-store reusable credit toward professional boot fitting service.'),
  ('10000000-0000-4000-8000-000000000009', 'es', 'Crédito para ajuste de botas', 'Crédito reutilizable en tienda para servicio profesional de ajuste de botas.'),
  ('10000000-0000-4000-8000-000000000009', 'zh-Hans', '登山靴适配服务抵扣', '门店可重复使用的专业鞋靴适配服务抵扣。'),

  ('10000000-0000-4000-8000-000000000010', 'en', 'EV charging session perk', 'On-demand benefit applicable to selected charging hubs and app activation.'),
  ('10000000-0000-4000-8000-000000000010', 'es', 'Beneficio para sesión de carga EV', 'Beneficio bajo demanda para centros de carga seleccionados y activación en app.'),
  ('10000000-0000-4000-8000-000000000010', 'zh-Hans', '电动车充电会话权益', '可用于指定充电站并支持应用内激活的按需优惠。'),

  ('10000000-0000-4000-8000-000000000011', 'en', 'Fleet advisory benefit', 'Legacy manual reward intentionally configured as always unavailable.'),
  ('10000000-0000-4000-8000-000000000011', 'es', 'Beneficio de asesoría de flota', 'Recompensa manual heredada configurada intencionalmente como siempre no disponible.'),
  ('10000000-0000-4000-8000-000000000011', 'zh-Hans', '车队咨询权益', '故意配置为始终不可用的历史人工核销奖励。'),

  ('10000000-0000-4000-8000-000000000012', 'en', 'Morning bakery combo', 'Reusable in-store credit for breakfast pastry and beverage combos.'),
  ('10000000-0000-4000-8000-000000000012', 'es', 'Combo matutino de panadería', 'Crédito reutilizable en tienda para combos de pan y bebida en la mañana.'),
  ('10000000-0000-4000-8000-000000000012', 'zh-Hans', '早餐烘焙套餐优惠', '门店可重复使用的早餐面包与饮品组合抵扣。'),

  ('10000000-0000-4000-8000-000000000013', 'en', 'Bulk paper order discount', 'Online savings for large-volume office paper purchases.'),
  ('10000000-0000-4000-8000-000000000013', 'es', 'Descuento en compra de papel al por mayor', 'Ahorro en línea para compras de gran volumen de papel de oficina.'),
  ('10000000-0000-4000-8000-000000000013', 'zh-Hans', '大宗办公纸张优惠', '适用于大批量办公纸张采购的线上折扣。'),

  ('10000000-0000-4000-8000-000000000014', 'en', 'Remote team starter kit', 'On-demand reward for distributed team office starter bundles.'),
  ('10000000-0000-4000-8000-000000000014', 'es', 'Kit inicial para equipos remotos', 'Recompensa bajo demanda para paquetes iniciales de oficina para equipos distribuidos.'),
  ('10000000-0000-4000-8000-000000000014', 'zh-Hans', '远程团队办公套装', '面向分布式团队办公入门套装的按需奖励。'),

  ('10000000-0000-4000-8000-000000000015', 'en', 'Weekday matinee ticket offer', 'Manual in-theater redemption for weekday showtimes.'),
  ('10000000-0000-4000-8000-000000000015', 'es', 'Oferta de matiné entre semana', 'Canje manual en cine para funciones entre semana.'),
  ('10000000-0000-4000-8000-000000000015', 'zh-Hans', '工作日白场票优惠', '适用于工作日场次的影院人工核销优惠。'),

  ('10000000-0000-4000-8000-000000000016', 'en', 'Premium seat upgrade', 'Single-use upgrade for premium seating, available online and in person.'),
  ('10000000-0000-4000-8000-000000000016', 'es', 'Mejora a asiento premium', 'Mejora de un solo uso para asientos premium, disponible en línea y presencial.'),
  ('10000000-0000-4000-8000-000000000016', 'zh-Hans', '高端座位升级', '可线上或现场使用的一次性高端座位升级权益。'),

  ('10000000-0000-4000-8000-000000000017', 'en', 'Club access membership credit', 'Recurring fitness benefit for club entry and partner classes.'),
  ('10000000-0000-4000-8000-000000000017', 'es', 'Crédito para acceso a clubes', 'Beneficio recurrente de fitness para ingreso a clubes y clases asociadas.'),
  ('10000000-0000-4000-8000-000000000017', 'zh-Hans', '会所入场权益抵扣', '用于会所入场与合作课程的可重复健身权益。'),

  ('10000000-0000-4000-8000-000000000018', 'en', 'Virtual wellness coaching', 'On-demand digital coaching sessions delivered in the member app.'),
  ('10000000-0000-4000-8000-000000000018', 'es', 'Coaching virtual de bienestar', 'Sesiones de coaching digital bajo demanda en la aplicación de miembros.'),
  ('10000000-0000-4000-8000-000000000018', 'zh-Hans', '线上健康指导课程', '通过会员应用提供的按需数字健康指导服务。'),

  ('10000000-0000-4000-8000-000000000019', 'en', 'Subscription beans discount', 'Single-use online discount for specialty bean subscription orders.'),
  ('10000000-0000-4000-8000-000000000019', 'es', 'Descuento en suscripción de granos', 'Descuento de un solo uso para pedidos en línea de suscripción de granos especiales.'),
  ('10000000-0000-4000-8000-000000000019', 'zh-Hans', '咖啡豆订阅优惠', '精品咖啡豆订阅订单的一次性线上折扣。'),

  ('10000000-0000-4000-8000-000000000020', 'en', 'In-café drink credit', 'Manual in-store reward for handcrafted drink purchases.'),
  ('10000000-0000-4000-8000-000000000020', 'es', 'Crédito para bebida en cafetería', 'Recompensa manual en tienda para bebidas preparadas al momento.'),
  ('10000000-0000-4000-8000-000000000020', 'zh-Hans', '门店饮品抵扣', '用于门店手作饮品消费的人工核销奖励。'),

  ('10000000-0000-4000-8000-000000000021', 'en', 'Legacy in-store markdown', 'Inactive-partner test reward for validating partner visibility filtering.'),
  ('10000000-0000-4000-8000-000000000021', 'es', 'Rebaja heredada en tienda', 'Recompensa de prueba para socio inactivo y validación de filtros de visibilidad.'),
  ('10000000-0000-4000-8000-000000000021', 'zh-Hans', '历史门店折扣', '用于验证非激活合作伙伴可见性过滤的测试奖励。'),

  ('10000000-0000-4000-8000-000000000022', 'en', 'Legacy online clearance', 'Inactive-partner online reward to ensure downstream exclusion behavior.'),
  ('10000000-0000-4000-8000-000000000022', 'es', 'Liquidación heredada en línea', 'Recompensa en línea de socio inactivo para comprobar exclusión en consultas.'),
  ('10000000-0000-4000-8000-000000000022', 'zh-Hans', '历史线上清仓权益', '用于确保下游查询排除逻辑的非激活合作伙伴线上奖励。');

COMMIT;
