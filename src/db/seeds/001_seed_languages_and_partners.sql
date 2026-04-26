BEGIN;

-- Rerunnable reset for this stage.
TRUNCATE TABLE
	partner,
	language
RESTART IDENTITY CASCADE;

INSERT INTO language (
	language_tag,
	language_name_en,
	language_name_native
) VALUES
	('en', 'English', 'English'),
	('es', 'Spanish', 'Español'),
	('zh-Hans', 'Chinese (Simplified)', '简体中文');

INSERT INTO partner (id, is_active)
OVERRIDING SYSTEM VALUE
VALUES
	(1, TRUE),
	(2, TRUE),
	(3, TRUE),
	(4, TRUE),
	(5, TRUE),
	(6, TRUE),
	(7, TRUE),
	(8, TRUE),
	(9, TRUE),
	(10, TRUE),
	(11, FALSE);

INSERT INTO partner_details_translation (
	partner_id,
	language_tag,
	name,
	logo_url,
	description,
	web_address_url,
	web_address_text,
	motivation
) VALUES
	(1, 'en', 'Northstar Marketplace', '/sample-partner-logos/northstar-marketplace.svg', 'A nationwide general marketplace offering in-store and online shopping across home, electronics, and daily essentials.', 'https://northstar.example.test', 'Shop Northstar', 'Great for testing large omni-channel partner behavior.'),
	(1, 'es', 'Northstar Marketplace', '/sample-partner-logos/northstar-marketplace.svg', 'Un mercado general de alcance nacional con compras en tienda y en línea para hogar, electrónica y productos de uso diario.', 'https://northstar.example.test/es', 'Comprar en Northstar', 'Ideal para probar un socio grande con presencia omnicanal.'),
	(1, 'zh-Hans', 'Northstar 综合商城', '/sample-partner-logos/northstar-marketplace.svg', '全国性综合零售平台，提供门店与线上购物，覆盖家居、电子产品和日常用品。', 'https://northstar.example.test/zh-hans', '前往 Northstar', '适合测试大型全渠道合作伙伴场景。'),

	(2, 'en', 'Pine & Pixel Home', '/sample-partner-logos/pine-pixel-home.svg', 'An online-first home décor and furniture brand with no physical storefronts.', 'https://pinepixelhome.example.test', 'Visit Pine & Pixel', 'Useful for online-only partner scenarios.'),
	(2, 'es', 'Pine & Pixel Home', '/sample-partner-logos/pine-pixel-home.svg', 'Marca digital de decoración y muebles para el hogar sin tiendas físicas.', 'https://pinepixelhome.example.test/es', 'Visitar Pine & Pixel', 'Útil para escenarios de socios solo en línea.'),
	(2, 'zh-Hans', 'Pine & Pixel 家居', '/sample-partner-logos/pine-pixel-home.svg', '以线上为主的家居与家具品牌，没有线下门店。', 'https://pinepixelhome.example.test/zh-hans', '访问 Pine & Pixel', '可用于测试仅线上合作伙伴。'),

	(3, 'en', 'HarborLine Grocers', '/sample-partner-logos/harborline-grocers.svg', 'A regional grocery chain focused on fresh produce, pantry staples, and neighborhood stores in the Pacific Northwest.', 'https://harborline.example.test', 'Browse HarborLine', 'Designed for regional in-store heavy partner behavior.'),
	(3, 'es', 'HarborLine Grocers', '/sample-partner-logos/harborline-grocers.svg', 'Cadena regional de supermercados enfocada en productos frescos, básicos de despensa y tiendas de barrio en el noroeste del Pacífico.', 'https://harborline.example.test/es', 'Explorar HarborLine', 'Diseñado para escenarios regionales con fuerte presencia física.'),
	(3, 'zh-Hans', 'HarborLine 生鲜超市', '/sample-partner-logos/harborline-grocers.svg', '区域性连锁超市，主打生鲜、日用品与社区门店，覆盖美国西北地区。', 'https://harborline.example.test/zh-hans', '查看 HarborLine', '用于测试区域型线下门店伙伴。'),

	(4, 'en', 'TrailPeak Outdoors', '/sample-partner-logos/trailpeak-outdoors.svg', 'Outdoor gear and apparel retailer with flagship stores in major cities plus a strong e-commerce channel.', 'https://trailpeak.example.test', 'Shop TrailPeak', 'Balanced online + physical footprint for mixed fulfillment tests.'),
	(4, 'es', 'TrailPeak Outdoors', '/sample-partner-logos/trailpeak-outdoors.svg', 'Minorista de equipo y ropa para actividades al aire libre con tiendas insignia en grandes ciudades y un sólido canal de comercio electrónico.', 'https://trailpeak.example.test/es', 'Comprar en TrailPeak', 'Presencia equilibrada en línea y física para pruebas mixtas.'),
	(4, 'zh-Hans', 'TrailPeak 户外', '/sample-partner-logos/trailpeak-outdoors.svg', '户外装备与服饰零售商，在主要城市有旗舰店，同时具备强大的电商渠道。', 'https://trailpeak.example.test/zh-hans', '选购 TrailPeak', '适合测试线上线下混合履约场景。'),

	(5, 'en', 'SunGrid Mobility', '/sample-partner-logos/sungrid-mobility.svg', 'A mobility platform offering EV charging benefits through a mobile app and selected charging hubs.', 'https://sungrid.example.test', 'Open SunGrid', 'Good for geo + app-centric redemption patterns.'),
	(5, 'es', 'SunGrid Mobility', '/sample-partner-logos/sungrid-mobility.svg', 'Plataforma de movilidad que ofrece beneficios para carga de vehículos eléctricos mediante aplicación móvil y centros seleccionados.', 'https://sungrid.example.test/es', 'Abrir SunGrid', 'Útil para canjes centrados en app y ubicación.'),
	(5, 'zh-Hans', 'SunGrid 出行', '/sample-partner-logos/sungrid-mobility.svg', '通过移动应用和部分充电站提供电动车充电权益的出行平台。', 'https://sungrid.example.test/zh-hans', '打开 SunGrid', '适合测试地理位置与应用内核销场景。'),

	(6, 'en', 'Willow & Wheat Bakery Co.', '/sample-partner-logos/willow-wheat-bakery.svg', 'A craft bakery brand with a handful of neighborhood storefronts and pre-order pickup.', 'https://willowwheat.example.test', 'Order from Willow & Wheat', 'Represents a small partner with limited physical footprint.'),
	(6, 'es', 'Willow & Wheat Bakery Co.', '/sample-partner-logos/willow-wheat-bakery.svg', 'Marca de panadería artesanal con pocas tiendas de barrio y opción de pedidos para recoger.', 'https://willowwheat.example.test/es', 'Pedir en Willow & Wheat', 'Representa un socio pequeño con presencia física limitada.'),
	(6, 'zh-Hans', 'Willow & Wheat 烘焙坊', '/sample-partner-logos/willow-wheat-bakery.svg', '手工烘焙品牌，仅有少量社区门店，并支持预订自提。', 'https://willowwheat.example.test/zh-hans', '在 Willow & Wheat 下单', '用于测试少量门店的小型合作伙伴。'),

	(7, 'en', 'CloudCart Office Supply', '/sample-partner-logos/cloudcart-office.svg', 'An online B2B office supply partner serving distributed teams with direct shipping.', 'https://cloudcart.example.test', 'Visit CloudCart', 'Covers business-focused, online-only fulfillment paths.'),
	(7, 'es', 'CloudCart Office Supply', '/sample-partner-logos/cloudcart-office.svg', 'Socio B2B de suministros de oficina en línea para equipos distribuidos con envío directo.', 'https://cloudcart.example.test/es', 'Visitar CloudCart', 'Cubre rutas de canje empresarial y cumplimiento solo digital.'),
	(7, 'zh-Hans', 'CloudCart 办公用品', '/sample-partner-logos/cloudcart-office.svg', '面向分布式团队的线上 B2B 办公用品平台，支持直邮。', 'https://cloudcart.example.test/zh-hans', '访问 CloudCart', '可覆盖企业向、纯线上履约路径。'),

	(8, 'en', 'Blue Mesa Cinemas', '/sample-partner-logos/blue-mesa-cinemas.svg', 'A regional cinema operator with metropolitan theater locations and mobile ticketing.', 'https://bluemesa.example.test', 'Book at Blue Mesa', 'Good fit for regional, venue-based redemption scenarios.'),
	(8, 'es', 'Blue Mesa Cinemas', '/sample-partner-logos/blue-mesa-cinemas.svg', 'Operador regional de cines con complejos en áreas metropolitanas y boletería móvil.', 'https://bluemesa.example.test/es', 'Reservar en Blue Mesa', 'Adecuado para escenarios regionales basados en sedes físicas.'),
	(8, 'zh-Hans', 'Blue Mesa 影城', '/sample-partner-logos/blue-mesa-cinemas.svg', '区域性影院运营商，在都市圈设有影院并支持移动购票。', 'https://bluemesa.example.test/zh-hans', '在 Blue Mesa 订票', '适合测试基于场馆的区域核销场景。'),

	(9, 'en', 'Meridian Health Clubs', '/sample-partner-logos/meridian-health-clubs.svg', 'A fitness network combining physical club access with digital classes and wellness content.', 'https://meridianclubs.example.test', 'Join Meridian', 'Covers blended digital + physical member experiences.'),
	(9, 'es', 'Meridian Health Clubs', '/sample-partner-logos/meridian-health-clubs.svg', 'Red de gimnasios que combina acceso a clubes físicos con clases digitales y contenido de bienestar.', 'https://meridianclubs.example.test/es', 'Unirse a Meridian', 'Cubre experiencias combinadas físicas y digitales para miembros.'),
	(9, 'zh-Hans', 'Meridian 健身会所', '/sample-partner-logos/meridian-health-clubs.svg', '健身连锁网络，结合线下会所权益与线上课程及健康内容。', 'https://meridianclubs.example.test/zh-hans', '加入 Meridian', '可测试数字与线下融合的会员体验。'),

	(10, 'en', 'KettleForge Roastery', '/sample-partner-logos/kettleforge-roastery.svg', 'A specialty coffee roaster with a small number of cafés and nationwide bean subscriptions.', 'https://kettleforge.example.test', 'Explore KettleForge', 'Represents few physical locations plus a strong online subscription channel.'),
	(10, 'es', 'KettleForge Roastery', '/sample-partner-logos/kettleforge-roastery.svg', 'Tostador de café de especialidad con pocas cafeterías y suscripciones nacionales de granos.', 'https://kettleforge.example.test/es', 'Explorar KettleForge', 'Representa pocas ubicaciones físicas y un fuerte canal de suscripción en línea.'),
	(10, 'zh-Hans', 'KettleForge 咖啡烘焙', '/sample-partner-logos/kettleforge-roastery.svg', '精品咖啡烘焙品牌，拥有少量咖啡门店并提供全国咖啡豆订阅。', 'https://kettleforge.example.test/zh-hans', '探索 KettleForge', '用于测试少量门店 + 强线上订阅的场景。'),

	(11, 'en', 'Riverstone Department Stores', '/sample-partner-logos/riverstone-department.svg', 'A legacy department store brand currently inactive in this dataset.', 'https://riverstone.example.test', 'Riverstone', 'Intentionally inactive to verify filtering rules.'),
	(11, 'es', 'Riverstone Department Stores', '/sample-partner-logos/riverstone-department.svg', 'Marca tradicional de tiendas por departamentos, actualmente inactiva en este conjunto de datos.', 'https://riverstone.example.test/es', 'Riverstone', 'Intencionalmente inactiva para verificar reglas de filtrado.'),
	(11, 'zh-Hans', 'Riverstone 百货', '/sample-partner-logos/riverstone-department.svg', '传统百货品牌，在此数据集中设置为非激活状态。', 'https://riverstone.example.test/zh-hans', 'Riverstone', '故意设为非激活，用于验证过滤逻辑。');

COMMIT;
