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
	(11, FALSE),
	(12, TRUE),
	(13, TRUE),
	(14, TRUE),
	(15, TRUE),
	(16, TRUE),
	(17, TRUE),
	(18, TRUE),
	(19, TRUE),
	(20, TRUE),
	(21, TRUE);

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
	(11, 'zh-Hans', 'Riverstone 百货', '/sample-partner-logos/riverstone-department.svg', '传统百货品牌，在此数据集中设置为非激活状态。', 'https://riverstone.example.test/zh-hans', 'Riverstone', NULL),

	(12, 'en', 'FreshField Markets', '/sample-partner-logos/northstar-marketplace.svg', 'A national grocery network focused on neighborhood stores, produce, and pantry essentials.', 'https://freshfield.example.test', 'Shop FreshField', 'We support 8by8 because healthy neighborhoods depend on civic voice, safety, and belonging for AAPI communities.'),
	(12, 'es', 'FreshField Markets', '/sample-partner-logos/northstar-marketplace.svg', 'Red nacional de supermercados enfocada en tiendas de barrio, productos frescos y básicos de despensa.', 'https://freshfield.example.test/es', 'Comprar en FreshField', 'Apoyamos a 8by8 porque comunidades saludables dependen de voz cívica, seguridad y pertenencia para la comunidad AAPI.'),
	(12, 'zh-Hans', 'FreshField 生鲜市场', '/sample-partner-logos/northstar-marketplace.svg', '全国性生鲜超市网络，专注社区门店、新鲜食材与日常杂货。', 'https://freshfield.example.test/zh-hans', '前往 FreshField', '我们支持 8by8，因为健康社区离不开公民发声、安全感与 AAPI 群体的归属。'),

	(13, 'en', 'AtlasFuel Charging', '/sample-partner-logos/sungrid-mobility.svg', 'An EV charging partner operating urban and highway charging locations across major US corridors.', 'https://atlasfuel.example.test', 'Open AtlasFuel', 'We support 8by8 because mobility access and language inclusion are essential to equal civic participation.'),
	(13, 'es', 'AtlasFuel Charging', '/sample-partner-logos/sungrid-mobility.svg', 'Socio de carga para vehículos eléctricos con operación urbana y en corredores interestatales de EE. UU.', 'https://atlasfuel.example.test/es', 'Abrir AtlasFuel', 'Apoyamos a 8by8 porque el acceso a la movilidad y la inclusión lingüística son esenciales para una participación cívica equitativa.'),
	(13, 'zh-Hans', 'AtlasFuel 充电网络', '/sample-partner-logos/sungrid-mobility.svg', '覆盖美国主要城市与高速走廊的电动车充电合作网络。', 'https://atlasfuel.example.test/zh-hans', '打开 AtlasFuel', '我们支持 8by8，因为出行可及性与语言包容是实现平等公民参与的关键。'),

	(14, 'en', 'PeakMotion Fitness', '/sample-partner-logos/meridian-health-clubs.svg', 'A multi-city fitness brand with full-service clubs and app-based classes.', 'https://peakmotion.example.test', 'Join PeakMotion', 'We support 8by8 because community wellness includes dignity, representation, and standing against hate.'),
	(14, 'es', 'PeakMotion Fitness', '/sample-partner-logos/meridian-health-clubs.svg', 'Marca de fitness en múltiples ciudades con clubes completos y clases en app.', 'https://peakmotion.example.test/es', 'Unirse a PeakMotion', 'Apoyamos a 8by8 porque el bienestar comunitario incluye dignidad, representación y oposición al odio.'),
	(14, 'zh-Hans', 'PeakMotion 健身', '/sample-partner-logos/meridian-health-clubs.svg', '覆盖多城市的健身品牌，提供综合会所与应用课程。', 'https://peakmotion.example.test/zh-hans', '加入 PeakMotion', '我们支持 8by8，因为社区健康也包含尊严、代表性与反对仇恨。'),

	(15, 'en', 'SilverScreen Theaters', '/sample-partner-logos/blue-mesa-cinemas.svg', 'A modern cinema chain with suburban and metro theater complexes.', 'https://silverscreen.example.test', 'Book SilverScreen', 'We support 8by8 because storytelling can build empathy and strengthen civic culture.'),
	(15, 'es', 'SilverScreen Theaters', '/sample-partner-logos/blue-mesa-cinemas.svg', 'Cadena moderna de cines con complejos en suburbios y áreas metropolitanas.', 'https://silverscreen.example.test/es', 'Reservar SilverScreen', 'Apoyamos a 8by8 porque las historias pueden construir empatía y fortalecer la cultura cívica.'),
	(15, 'zh-Hans', 'SilverScreen 影院', '/sample-partner-logos/blue-mesa-cinemas.svg', '现代影院连锁，覆盖郊区与都市综合影城。', 'https://silverscreen.example.test/zh-hans', '订票 SilverScreen', '我们支持 8by8，因为叙事能够培养同理心并强化公民文化。'),

	(16, 'en', 'HomeHarbor Living', '/sample-partner-logos/pine-pixel-home.svg', 'A hybrid home-goods retailer with strong e-commerce and select showroom locations.', 'https://homeharbor.example.test', 'Visit HomeHarbor', 'We support 8by8 because everyone deserves safe homes and equal voice in shaping their communities.'),
	(16, 'es', 'HomeHarbor Living', '/sample-partner-logos/pine-pixel-home.svg', 'Minorista híbrido de artículos para el hogar con fuerte e-commerce y algunas salas de exhibición.', 'https://homeharbor.example.test/es', 'Visitar HomeHarbor', 'Apoyamos a 8by8 porque todas las personas merecen hogares seguros y voz igual para dar forma a sus comunidades.'),
	(16, 'zh-Hans', 'HomeHarbor 家居', '/sample-partner-logos/pine-pixel-home.svg', '家居零售混合品牌，线上业务强并设有少量展示门店。', 'https://homeharbor.example.test/zh-hans', '访问 HomeHarbor', '我们支持 8by8，因为每个人都应拥有安全家园，并平等参与社区建设。'),

	(17, 'en', 'QuickMed Pharmacies', '/sample-partner-logos/harborline-grocers.svg', 'A pharmacy and wellness chain with broad suburban coverage and same-day pickup.', 'https://quickmed.example.test', 'Find QuickMed', 'We support 8by8 because trusted neighborhood services should help every resident feel safe and seen.'),
	(17, 'es', 'QuickMed Pharmacies', '/sample-partner-logos/harborline-grocers.svg', 'Cadena de farmacias y bienestar con amplia cobertura suburbana y retiro el mismo día.', 'https://quickmed.example.test/es', 'Buscar QuickMed', 'Apoyamos a 8by8 porque los servicios de confianza del vecindario deben ayudar a que todas las personas se sientan seguras y reconocidas.'),
	(17, 'zh-Hans', 'QuickMed 药房', '/sample-partner-logos/harborline-grocers.svg', '覆盖广泛郊区网络的药房与健康连锁，支持当日取货。', 'https://quickmed.example.test/zh-hans', '查找 QuickMed', '我们支持 8by8，因为值得信赖的社区服务应让每位居民都感到安全与被看见。'),

	(18, 'en', 'MetroBite Kitchens', '/sample-partner-logos/willow-wheat-bakery.svg', 'A fast-casual restaurant network with dense city footprints and app ordering.', 'https://metrobite.example.test', 'Order MetroBite', 'We support 8by8 because inclusive communities are built through everyday participation and shared public spaces.'),
	(18, 'es', 'MetroBite Kitchens', '/sample-partner-logos/willow-wheat-bakery.svg', 'Red de restaurantes fast-casual con presencia densa en ciudades y pedidos por app.', 'https://metrobite.example.test/es', 'Pedir MetroBite', 'Apoyamos a 8by8 porque las comunidades inclusivas se construyen con participación cotidiana y espacios públicos compartidos.'),
	(18, 'zh-Hans', 'MetroBite 餐厨', '/sample-partner-logos/willow-wheat-bakery.svg', '快休闲餐饮网络，在城市有密集门店并支持应用点餐。', 'https://metrobite.example.test/zh-hans', '点餐 MetroBite', '我们支持 8by8，因为包容性社区来自日常参与与共享公共空间。'),

	(19, 'en', 'UrbanCycle Share', '/sample-partner-logos/sungrid-mobility.svg', 'A micromobility and charging provider with stations across downtown corridors.', 'https://urbancycle.example.test', 'Open UrbanCycle', 'We support 8by8 because transportation equity directly impacts who can participate in civic life.'),
	(19, 'es', 'UrbanCycle Share', '/sample-partner-logos/sungrid-mobility.svg', 'Proveedor de micromovilidad y carga con estaciones en corredores céntricos.', 'https://urbancycle.example.test/es', 'Abrir UrbanCycle', 'Apoyamos a 8by8 porque la equidad en transporte impacta directamente quién puede participar en la vida cívica.'),
	(19, 'zh-Hans', 'UrbanCycle 微出行', '/sample-partner-logos/sungrid-mobility.svg', '微出行与充电服务商，在核心城区走廊部署站点。', 'https://urbancycle.example.test/zh-hans', '打开 UrbanCycle', '我们支持 8by8，因为交通公平直接影响谁能参与公民生活。'),

	(20, 'en', 'Oakline Department Stores', '/sample-partner-logos/riverstone-department.svg', 'A full-line department store chain with broad regional mall presence.', 'https://oakline.example.test', 'Shop Oakline', 'We support 8by8 because civic engagement and anti-hate action strengthen communities where families shop and gather.'),
	(20, 'es', 'Oakline Department Stores', '/sample-partner-logos/riverstone-department.svg', 'Cadena de tiendas por departamentos con amplia presencia en centros comerciales regionales.', 'https://oakline.example.test/es', 'Comprar en Oakline', 'Apoyamos a 8by8 porque la participación cívica y la acción contra el odio fortalecen las comunidades donde las familias compran y conviven.'),
	(20, 'zh-Hans', 'Oakline 百货', '/sample-partner-logos/riverstone-department.svg', '全品类百货连锁，在区域购物中心拥有广泛布局。', 'https://oakline.example.test/zh-hans', '选购 Oakline', '我们支持 8by8，因为公民参与与反仇恨行动会强化家庭日常消费与相聚的社区。'),

	(21, 'en', 'BrightBasket Grocers', '/sample-partner-logos/harborline-grocers.svg', 'A value-focused grocery chain with strong suburban and small-city coverage.', 'https://brightbasket.example.test', 'Shop BrightBasket', 'We support 8by8 because neighborhood dignity, safety, and participation should be accessible to everyone.'),
	(21, 'es', 'BrightBasket Grocers', '/sample-partner-logos/harborline-grocers.svg', 'Cadena de supermercados enfocada en valor con fuerte cobertura suburbana y de ciudades pequeñas.', 'https://brightbasket.example.test/es', 'Comprar en BrightBasket', 'Apoyamos a 8by8 porque la dignidad vecinal, la seguridad y la participación deben ser accesibles para todas las personas.'),
	(21, 'zh-Hans', 'BrightBasket 平价超市', '/sample-partner-logos/harborline-grocers.svg', '主打高性价比的连锁超市，覆盖郊区与中小城市。', 'https://brightbasket.example.test/zh-hans', '前往 BrightBasket', '我们支持 8by8，因为社区尊严、安全与参与机会应当人人可及。');

COMMIT;
