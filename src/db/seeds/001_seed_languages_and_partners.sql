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
	(1, 'en', 'Northstar Marketplace', '/sample-partner-logos/northstar-marketplace.svg', 'A nationwide general marketplace offering in-store and online shopping across home, electronics, and daily essentials.', 'https://northstar.example.test', 'Shop Northstar', 'As a company built by immigrant and first-generation team members, we stand with 8by8 to expand voter registration and push back against anti-AAPI hate.'),
	(1, 'es', 'Northstar Marketplace', '/sample-partner-logos/northstar-marketplace.svg', 'Un mercado general de alcance nacional con compras en tienda y en línea para hogar, electrónica y productos de uso diario.', 'https://northstar.example.test/es', 'Comprar en Northstar', 'Como empresa construida por personas inmigrantes y de primera generación, apoyamos a 8by8 para ampliar el registro de votantes y rechazar el odio contra la comunidad AAPI.'),
	(1, 'zh-Hans', 'Northstar 综合商城', '/sample-partner-logos/northstar-marketplace.svg', '全国性综合零售平台，提供门店与线上购物，覆盖家居、电子产品和日常用品。', 'https://northstar.example.test/zh-hans', '前往 Northstar', '作为由移民和第一代成员共同建立的团队，我们支持 8by8，推动选民登记并反对针对 AAPI 社区的仇恨。'),

	(2, 'en', 'Pine & Pixel Home', '/sample-partner-logos/pine-pixel-home.svg', 'An online-first home décor and furniture brand with no physical storefronts.', 'https://pinepixelhome.example.test', 'Visit Pine & Pixel', 'We support 8by8 because everyone deserves to feel safe at home and in their community, and voter participation helps protect that.'),
	(2, 'es', 'Pine & Pixel Home', '/sample-partner-logos/pine-pixel-home.svg', 'Marca digital de decoración y muebles para el hogar sin tiendas físicas.', 'https://pinepixelhome.example.test/es', 'Visitar Pine & Pixel', 'Apoyamos a 8by8 porque todas las personas merecen sentirse seguras en su hogar y su comunidad, y la participación electoral ayuda a proteger eso.'),
	(2, 'zh-Hans', 'Pine & Pixel 家居', '/sample-partner-logos/pine-pixel-home.svg', '以线上为主的家居与家具品牌，没有线下门店。', 'https://pinepixelhome.example.test/zh-hans', '访问 Pine & Pixel', '我们支持 8by8，因为每个人都应在家中和社区里感到安全，而选民参与有助于守护这一点。'),

	(3, 'en', 'HarborLine Grocers', '/sample-partner-logos/harborline-grocers.svg', 'A regional grocery chain focused on fresh produce, pantry staples, and neighborhood stores in the Pacific Northwest.', 'https://harborline.example.test', 'Browse HarborLine', 'As a neighborhood grocer serving many AAPI families, we back 8by8 to help neighbors register to vote and reject hate.'),
	(3, 'es', 'HarborLine Grocers', '/sample-partner-logos/harborline-grocers.svg', 'Cadena regional de supermercados enfocada en productos frescos, básicos de despensa y tiendas de barrio en el noroeste del Pacífico.', 'https://harborline.example.test/es', 'Explorar HarborLine', 'Como supermercado de barrio que atiende a muchas familias AAPI, apoyamos a 8by8 para ayudar a nuestras vecinas y vecinos a registrarse para votar y rechazar el odio.'),
	(3, 'zh-Hans', 'HarborLine 生鲜超市', '/sample-partner-logos/harborline-grocers.svg', '区域性连锁超市，主打生鲜、日用品与社区门店，覆盖美国西北地区。', 'https://harborline.example.test/zh-hans', '查看 HarborLine', '作为服务众多 AAPI 家庭的社区超市，我们支持 8by8，帮助居民登记投票并共同抵制仇恨。'),

	(4, 'en', 'TrailPeak Outdoors', '/sample-partner-logos/trailpeak-outdoors.svg', 'Outdoor gear and apparel retailer with flagship stores in major cities plus a strong e-commerce channel.', 'https://trailpeak.example.test', 'Shop TrailPeak', 'We support 8by8 because public spaces should be welcoming to everyone, and anti-hate civic action helps make that real.'),
	(4, 'es', 'TrailPeak Outdoors', '/sample-partner-logos/trailpeak-outdoors.svg', 'Minorista de equipo y ropa para actividades al aire libre con tiendas insignia en grandes ciudades y un sólido canal de comercio electrónico.', 'https://trailpeak.example.test/es', 'Comprar en TrailPeak', 'Apoyamos a 8by8 porque los espacios públicos deben ser acogedores para todas las personas, y la acción cívica contra el odio ayuda a lograrlo.'),
	(4, 'zh-Hans', 'TrailPeak 户外', '/sample-partner-logos/trailpeak-outdoors.svg', '户外装备与服饰零售商，在主要城市有旗舰店，同时具备强大的电商渠道。', 'https://trailpeak.example.test/zh-hans', '选购 TrailPeak', '我们支持 8by8，因为公共空间应对所有人友好，而反仇恨的公民行动能让这一点成为现实。'),

	(5, 'en', 'SunGrid Mobility', '/sample-partner-logos/sungrid-mobility.svg', 'A mobility platform offering EV charging benefits through a mobile app and selected charging hubs.', 'https://sungrid.example.test', 'Open SunGrid', 'We support 8by8 because transportation and language access are key barriers to civic participation, and we can help reduce both.'),
	(5, 'es', 'SunGrid Mobility', '/sample-partner-logos/sungrid-mobility.svg', 'Plataforma de movilidad que ofrece beneficios para carga de vehículos eléctricos mediante aplicación móvil y centros seleccionados.', 'https://sungrid.example.test/es', 'Abrir SunGrid', 'Apoyamos a 8by8 porque el transporte y el acceso al idioma son barreras clave para la participación cívica, y podemos ayudar a reducir ambas.'),
	(5, 'zh-Hans', 'SunGrid 出行', '/sample-partner-logos/sungrid-mobility.svg', '通过移动应用和部分充电站提供电动车充电权益的出行平台。', 'https://sungrid.example.test/zh-hans', '打开 SunGrid', '我们支持 8by8，因为交通与语言可及性是公民参与的重要门槛，而我们可以帮助降低这两方面障碍。'),

	(6, 'en', 'Willow & Wheat Bakery Co.', '/sample-partner-logos/willow-wheat-bakery.svg', 'A craft bakery brand with a handful of neighborhood storefronts and pre-order pickup.', 'https://willowwheat.example.test', 'Order from Willow & Wheat', 'As a family bakery started by immigrant parents, we support 8by8 because every community deserves safety, dignity, and a voice at the ballot box.'),
	(6, 'es', 'Willow & Wheat Bakery Co.', '/sample-partner-logos/willow-wheat-bakery.svg', 'Marca de panadería artesanal con pocas tiendas de barrio y opción de pedidos para recoger.', 'https://willowwheat.example.test/es', 'Pedir en Willow & Wheat', 'Como panadería familiar iniciada por padres inmigrantes, apoyamos a 8by8 porque toda comunidad merece seguridad, dignidad y voz en las urnas.'),
	(6, 'zh-Hans', 'Willow & Wheat 烘焙坊', '/sample-partner-logos/willow-wheat-bakery.svg', '手工烘焙品牌，仅有少量社区门店，并支持预订自提。', 'https://willowwheat.example.test/zh-hans', '在 Willow & Wheat 下单', '作为由移民父母创立的家庭烘焙店，我们支持 8by8，因为每个社区都应拥有安全、尊严与投票发声的权利。'),

	(7, 'en', 'CloudCart Office Supply', '/sample-partner-logos/cloudcart-office.svg', 'An online B2B office supply partner serving distributed teams with direct shipping.', 'https://cloudcart.example.test', 'Visit CloudCart', NULL),
	(7, 'es', 'CloudCart Office Supply', '/sample-partner-logos/cloudcart-office.svg', 'Socio B2B de suministros de oficina en línea para equipos distribuidos con envío directo.', 'https://cloudcart.example.test/es', 'Visitar CloudCart', NULL),
	(7, 'zh-Hans', 'CloudCart 办公用品', '/sample-partner-logos/cloudcart-office.svg', '面向分布式团队的线上 B2B 办公用品平台，支持直邮。', 'https://cloudcart.example.test/zh-hans', '访问 CloudCart', NULL),

	(8, 'en', 'Blue Mesa Cinemas', '/sample-partner-logos/blue-mesa-cinemas.svg', 'A regional cinema operator with metropolitan theater locations and mobile ticketing.', 'https://bluemesa.example.test', 'Book at Blue Mesa', 'We support 8by8 because stories shape culture, and we want our venues to uplift empathy, civic voice, and zero tolerance for hate.'),
	(8, 'es', 'Blue Mesa Cinemas', '/sample-partner-logos/blue-mesa-cinemas.svg', 'Operador regional de cines con complejos en áreas metropolitanas y boletería móvil.', 'https://bluemesa.example.test/es', 'Reservar en Blue Mesa', 'Apoyamos a 8by8 porque las historias moldean la cultura, y queremos que nuestros cines promuevan empatía, voz cívica y tolerancia cero al odio.'),
	(8, 'zh-Hans', 'Blue Mesa 影城', '/sample-partner-logos/blue-mesa-cinemas.svg', '区域性影院运营商，在都市圈设有影院并支持移动购票。', 'https://bluemesa.example.test/zh-hans', '在 Blue Mesa 订票', '我们支持 8by8，因为故事会塑造文化，我们希望影院传递同理心、公民声音与对仇恨零容忍。'),

	(9, 'en', 'Meridian Health Clubs', '/sample-partner-logos/meridian-health-clubs.svg', 'A fitness network combining physical club access with digital classes and wellness content.', 'https://meridianclubs.example.test', 'Join Meridian', 'We support 8by8 because community wellbeing includes belonging, civic participation, and active resistance to hate.'),
	(9, 'es', 'Meridian Health Clubs', '/sample-partner-logos/meridian-health-clubs.svg', 'Red de gimnasios que combina acceso a clubes físicos con clases digitales y contenido de bienestar.', 'https://meridianclubs.example.test/es', 'Unirse a Meridian', 'Apoyamos a 8by8 porque el bienestar comunitario incluye pertenencia, participación cívica y resistencia activa al odio.'),
	(9, 'zh-Hans', 'Meridian 健身会所', '/sample-partner-logos/meridian-health-clubs.svg', '健身连锁网络，结合线下会所权益与线上课程及健康内容。', 'https://meridianclubs.example.test/zh-hans', '加入 Meridian', '我们支持 8by8，因为社区健康不仅是身体状态，也包括归属感、公民参与和对仇恨的积极抵制。'),

	(10, 'en', 'KettleForge Roastery', '/sample-partner-logos/kettleforge-roastery.svg', 'A specialty coffee roaster with a small number of cafés and nationwide bean subscriptions.', 'https://kettleforge.example.test', 'Explore KettleForge', 'As a café brand founded by an immigrant family, we support 8by8 to amplify AAPI voices through voter registration and community solidarity.'),
	(10, 'es', 'KettleForge Roastery', '/sample-partner-logos/kettleforge-roastery.svg', 'Tostador de café de especialidad con pocas cafeterías y suscripciones nacionales de granos.', 'https://kettleforge.example.test/es', 'Explorar KettleForge', 'Como marca de café fundada por una familia inmigrante, apoyamos a 8by8 para amplificar las voces AAPI mediante el registro de votantes y la solidaridad comunitaria.'),
	(10, 'zh-Hans', 'KettleForge 咖啡烘焙', '/sample-partner-logos/kettleforge-roastery.svg', '精品咖啡烘焙品牌，拥有少量咖啡门店并提供全国咖啡豆订阅。', 'https://kettleforge.example.test/zh-hans', '探索 KettleForge', '作为由移民家庭创立的咖啡品牌，我们支持 8by8，通过选民登记与社区团结放大 AAPI 群体的声音。'),

	(11, 'en', 'Riverstone Department Stores', '/sample-partner-logos/riverstone-department.svg', 'A legacy department store brand currently inactive in this dataset.', 'https://riverstone.example.test', 'Riverstone', NULL),
	(11, 'es', 'Riverstone Department Stores', '/sample-partner-logos/riverstone-department.svg', 'Marca tradicional de tiendas por departamentos, actualmente inactiva en este conjunto de datos.', 'https://riverstone.example.test/es', 'Riverstone', NULL),
	(11, 'zh-Hans', 'Riverstone 百货', '/sample-partner-logos/riverstone-department.svg', '传统百货品牌，在此数据集中设置为非激活状态。', 'https://riverstone.example.test/zh-hans', 'Riverstone', NULL);

COMMIT;
