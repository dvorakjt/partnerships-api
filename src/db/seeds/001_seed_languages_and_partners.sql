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
	(11, TRUE),
	(12, TRUE);

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
	(1, 'en', 'Bloom & Vine Floral Design', 'http://localhost:4000/sample-partner-logos/bloom-vine-floral-design.svg', 'Boutique floral studio specializing in weddings, events, and same-day bouquet delivery.', 'https://bloomvine.example.test', 'Visit Bloom & Vine', 'We partner with 8by8 to celebrate community voices and create welcoming spaces for everyone.'),
	(1, 'es', 'Bloom & Vine Diseño Floral', 'http://localhost:4000/sample-partner-logos/bloom-vine-floral-design.svg', 'Estudio floral boutique especializado en bodas, eventos y entrega de ramos el mismo día.', 'https://bloomvine.example.test/es', 'Visitar Bloom & Vine', 'Nos unimos a 8by8 para celebrar las voces de la comunidad y crear espacios acogedores para todas las personas.'),
	(1, 'zh-Hans', 'Bloom & Vine 花艺设计', 'http://localhost:4000/sample-partner-logos/bloom-vine-floral-design.svg', '精品花艺工作室，专注婚礼、活动与当日花束配送。', 'https://bloomvine.example.test/zh-hans', '访问 Bloom & Vine', '我们与 8by8 合作，支持社区发声，营造对所有人都友好的空间。'),

	(2, 'en', 'Craft & Forge Furniture Co.', 'http://localhost:4000/sample-partner-logos/craft-forge-furniture-co.svg', 'Handcrafted furniture maker offering custom pieces, showroom appointments, and online ordering.', 'https://craftforge.example.test', 'Shop Craft & Forge', 'We support 8by8 because strong communities are built with care, representation, and civic participation.'),
	(2, 'es', 'Craft & Forge Muebles Co.', 'http://localhost:4000/sample-partner-logos/craft-forge-furniture-co.svg', 'Fabricante de muebles artesanales con piezas personalizadas, citas en showroom y pedidos en línea.', 'https://craftforge.example.test/es', 'Comprar en Craft & Forge', 'Apoyamos a 8by8 porque las comunidades fuertes se construyen con cuidado, representación y participación cívica.'),
	(2, 'zh-Hans', 'Craft & Forge 家具公司', 'http://localhost:4000/sample-partner-logos/craft-forge-furniture-co.svg', '手工家具品牌，提供定制家具、展厅预约与线上下单。', 'https://craftforge.example.test/zh-hans', '选购 Craft & Forge', '我们支持 8by8，因为有韧性的社区来自关怀、代表性与公民参与。'),

	(3, 'en', 'Harbor View Cafe', 'http://localhost:4000/sample-partner-logos/harbor-view-cafe.svg', 'Neighborhood cafe chain serving espresso, breakfast, and light lunch with pickup and delivery.', 'https://harborviewcafe.example.test', 'Order Harbor View', 'We back 8by8 to help neighbors feel safe, seen, and represented.'),
	(3, 'es', 'Harbor View Café', 'http://localhost:4000/sample-partner-logos/harbor-view-cafe.svg', 'Cadena de cafeterías de barrio con espresso, desayunos y almuerzos ligeros para recoger o entrega.', 'https://harborviewcafe.example.test/es', 'Pedir en Harbor View', 'Apoyamos a 8by8 para que nuestras vecinas y vecinos se sientan seguros, visibles y representados.'),
	(3, 'zh-Hans', 'Harbor View 咖啡馆', 'http://localhost:4000/sample-partner-logos/harbor-view-cafe.svg', '社区连锁咖啡馆，提供浓缩咖啡、早餐和简餐，支持自提与配送。', 'https://harborviewcafe.example.test/zh-hans', '在 Harbor View 下单', '我们支持 8by8，让邻里居民都能感到安全、被看见并被代表。'),

	(4, 'en', 'Luna Bliss Spa', 'http://localhost:4000/sample-partner-logos/luna-bliss-spa.svg', 'Day spa with massage therapy, facials, and wellness treatments at premium urban locations.', 'https://lunablissspa.example.test', 'Book Luna Bliss', 'We support 8by8 because wellness includes safety, dignity, and belonging.'),
	(4, 'es', 'Luna Bliss Spa', 'http://localhost:4000/sample-partner-logos/luna-bliss-spa.svg', 'Spa de día con masajes, faciales y tratamientos de bienestar en ubicaciones urbanas premium.', 'https://lunablissspa.example.test/es', 'Reservar Luna Bliss', 'Apoyamos a 8by8 porque el bienestar también significa seguridad, dignidad y pertenencia.'),
	(4, 'zh-Hans', 'Luna Bliss 水疗', 'http://localhost:4000/sample-partner-logos/luna-bliss-spa.svg', '都市精品日间水疗，提供按摩、面部护理与身心放松疗程。', 'https://lunablissspa.example.test/zh-hans', '预约 Luna Bliss', '我们支持 8by8，因为真正的健康也包括安全感、尊严与归属感。'),

	(5, 'en', 'Luxe Glow Cosmetics', 'http://localhost:4000/sample-partner-logos/luxe-glow-cosmetics.svg', 'Beauty brand offering skincare and makeup bundles online and in flagship stores.', 'https://luxeglow.example.test', 'Shop Luxe Glow', 'We support 8by8 because inclusive beauty means every voice is valued.'),
	(5, 'es', 'Luxe Glow Cosméticos', 'http://localhost:4000/sample-partner-logos/luxe-glow-cosmetics.svg', 'Marca de belleza con paquetes de cuidado de la piel y maquillaje en línea y en tiendas insignia.', 'https://luxeglow.example.test/es', 'Comprar en Luxe Glow', 'Apoyamos a 8by8 porque la belleza inclusiva significa valorar todas las voces.'),
	(5, 'zh-Hans', 'Luxe Glow 美妆', 'http://localhost:4000/sample-partner-logos/luxe-glow-cosmetics.svg', '美妆品牌，提供护肤与彩妆组合，支持线上购买与旗舰门店体验。', 'https://luxeglow.example.test/zh-hans', '选购 Luxe Glow', '我们支持 8by8，因为包容的美应当尊重每一种声音。'),

	(6, 'en', 'Nova Real Estate', 'http://localhost:4000/sample-partner-logos/nova-real-estate.svg', 'Real estate advisory network for rentals, home buying, and relocation support nationwide.', 'https://novarealestate.example.test', 'Start with Nova', 'We support 8by8 because stable housing and civic access are deeply connected.'),
	(6, 'es', 'Nova Bienes Raíces', 'http://localhost:4000/sample-partner-logos/nova-real-estate.svg', 'Red de asesoría inmobiliaria para alquiler, compra de vivienda y reubicación en todo el país.', 'https://novarealestate.example.test/es', 'Comenzar con Nova', 'Apoyamos a 8by8 porque la vivienda estable y el acceso cívico están profundamente conectados.'),
	(6, 'zh-Hans', 'Nova 房地产', 'http://localhost:4000/sample-partner-logos/nova-real-estate.svg', '全国房产顾问网络，提供租赁、购房与搬迁支持服务。', 'https://novarealestate.example.test/zh-hans', '从 Nova 开始', '我们支持 8by8，因为住房稳定与公民参与息息相关。'),

	(7, 'en', 'Paw Pals Pet Grooming', 'http://localhost:4000/sample-partner-logos/paw-pals-pet-grooming.svg', 'Pet grooming salons offering baths, haircuts, and wellness add-ons for cats and dogs.', 'https://pawpals.example.test', 'Book Paw Pals', 'We support 8by8 because compassionate neighborhoods are built by showing up for one another.'),
	(7, 'es', 'Paw Pals Peluquería de Mascotas', 'http://localhost:4000/sample-partner-logos/paw-pals-pet-grooming.svg', 'Salones de peluquería de mascotas con baño, corte y complementos de bienestar para perros y gatos.', 'https://pawpals.example.test/es', 'Reservar Paw Pals', 'Apoyamos a 8by8 porque los vecindarios compasivos se construyen apoyándonos mutuamente.'),
	(7, 'zh-Hans', 'Paw Pals 宠物美容', 'http://localhost:4000/sample-partner-logos/paw-pals-pet-grooming.svg', '宠物美容连锁店，为猫狗提供洗护、修剪与健康护理服务。', 'https://pawpals.example.test/zh-hans', '预约 Paw Pals', '我们支持 8by8，因为有温度的社区来自彼此支持。'),

	(8, 'en', 'Silverstream Media', 'http://localhost:4000/sample-partner-logos/silverstream-media.svg', 'Creative media studio providing social content, podcast production, and digital campaign support.', 'https://silverstreammedia.example.test', 'Work with Silverstream', 'We support 8by8 because storytelling can reduce hate and strengthen civic empathy.'),
	(8, 'es', 'Silverstream Medios', 'http://localhost:4000/sample-partner-logos/silverstream-media.svg', 'Estudio creativo de medios para contenido social, producción de pódcast y campañas digitales.', 'https://silverstreammedia.example.test/es', 'Trabajar con Silverstream', 'Apoyamos a 8by8 porque las historias pueden reducir el odio y fortalecer la empatía cívica.'),
	(8, 'zh-Hans', 'Silverstream 传媒', 'http://localhost:4000/sample-partner-logos/silverstream-media.svg', '创意传媒工作室，提供社交内容、播客制作与数字营销支持。', 'https://silverstreammedia.example.test/zh-hans', '与 Silverstream 合作', '我们支持 8by8，因为叙事能够减少仇恨并增强公民同理心。'),

	(9, 'en', 'Summit Peak Outdoors', 'http://localhost:4000/sample-partner-logos/summit-peak-outdoors.svg', 'Outdoor retailer for hiking, camping, and trail apparel with regional stores and e-commerce.', 'https://summitpeak.example.test', 'Explore Summit Peak', 'We support 8by8 because outdoor spaces should be welcoming and safe for everyone.'),
	(9, 'es', 'Summit Peak Aire Libre', 'http://localhost:4000/sample-partner-logos/summit-peak-outdoors.svg', 'Minorista de senderismo, campamento y ropa outdoor con tiendas regionales y comercio electrónico.', 'https://summitpeak.example.test/es', 'Explorar Summit Peak', 'Apoyamos a 8by8 porque los espacios al aire libre deben ser acogedores y seguros para todas las personas.'),
	(9, 'zh-Hans', 'Summit Peak 户外', 'http://localhost:4000/sample-partner-logos/summit-peak-outdoors.svg', '户外零售品牌，涵盖徒步、露营与户外服饰，支持门店与电商。', 'https://summitpeak.example.test/zh-hans', '探索 Summit Peak', '我们支持 8by8，因为户外空间应当对所有人都安全且友好。'),

	(10, 'en', 'Taste & Thyme Catering', 'http://localhost:4000/sample-partner-logos/taste-thyme-catering.svg', 'Full-service catering company for corporate lunches, weddings, and community events.', 'https://tastethyme.example.test', 'Plan with Taste & Thyme', 'We support 8by8 because gathering around food should bring communities together, not divide them.'),
	(10, 'es', 'Taste & Thyme Catering', 'http://localhost:4000/sample-partner-logos/taste-thyme-catering.svg', 'Empresa de catering integral para almuerzos corporativos, bodas y eventos comunitarios.', 'https://tastethyme.example.test/es', 'Planear con Taste & Thyme', 'Apoyamos a 8by8 porque compartir comida debe unir a las comunidades, no dividirlas.'),
	(10, 'zh-Hans', 'Taste & Thyme 餐饮服务', 'http://localhost:4000/sample-partner-logos/taste-thyme-catering.svg', '全案餐饮服务公司，覆盖企业午餐、婚礼与社区活动。', 'https://tastethyme.example.test/zh-hans', '与 Taste & Thyme 规划活动', '我们支持 8by8，因为围绕食物的相聚应当凝聚社区，而非制造分裂。'),

	(11, 'en', 'Velocity Fitness', 'http://localhost:4000/sample-partner-logos/velocity-fitness.svg', 'Fitness club network with strength floors, group classes, and digital coaching programs.', 'https://velocityfitness.example.test', 'Join Velocity', 'We support 8by8 because healthy communities depend on equal voice and civic belonging.'),
	(11, 'es', 'Velocity Fitness', 'http://localhost:4000/sample-partner-logos/velocity-fitness.svg', 'Red de gimnasios con pesas, clases grupales y programas de entrenamiento digital.', 'https://velocityfitness.example.test/es', 'Unirse a Velocity', 'Apoyamos a 8by8 porque las comunidades saludables dependen de una voz igualitaria y pertenencia cívica.'),
	(11, 'zh-Hans', 'Velocity 健身', 'http://localhost:4000/sample-partner-logos/velocity-fitness.svg', '健身俱乐部网络，提供力量训练区、团课与线上教练计划。', 'https://velocityfitness.example.test/zh-hans', '加入 Velocity', '我们支持 8by8，因为健康社区依赖平等发声与公民归属。'),

	(12, 'en', 'Voltix Tech', 'http://localhost:4000/sample-partner-logos/voltix-tech.svg', 'Technology services brand offering device repair, smart-home setup, and tech support plans.', 'https://voltixtech.example.test', 'Get support from Voltix', 'We support 8by8 because access to technology and civic participation should go hand in hand.'),
	(12, 'es', 'Voltix Tecnología', 'http://localhost:4000/sample-partner-logos/voltix-tech.svg', 'Marca de servicios tecnológicos con reparación de dispositivos, instalación de hogar inteligente y soporte técnico.', 'https://voltixtech.example.test/es', 'Obtener soporte de Voltix', 'Apoyamos a 8by8 porque el acceso a la tecnología y la participación cívica deben ir de la mano.'),
	(12, 'zh-Hans', 'Voltix 科技', 'http://localhost:4000/sample-partner-logos/voltix-tech.svg', '科技服务品牌，提供设备维修、智能家居安装与技术支持方案。', 'https://voltixtech.example.test/zh-hans', '获取 Voltix 支持', '我们支持 8by8，因为技术可及性与公民参与应当并行。');

COMMIT;
