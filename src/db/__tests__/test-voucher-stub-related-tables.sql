CREATE FUNCTION public.test_on_demand_voucher_stub_can_reference_on_demand_voucher_reward()
RETURNS SETOF TEXT AS $$
DECLARE
  test_partner_id INT;
  test_reward_id UUID;
BEGIN
  INSERT INTO partner DEFAULT VALUES RETURNING id INTO test_partner_id;

  INSERT INTO reward (
    partner_id,
    redemption_forums,
    voucher_type
  ) VALUES (
    test_partner_id,
    '{"ONLINE"}',
    'ON_DEMAND'
  ) RETURNING id INTO test_reward_id;

  RETURN QUERY (
    SELECT lives_ok(
      FORMAT(
        'INSERT INTO on_demand_voucher_stub (reward_id) VALUES (%L);',
        test_reward_id
      )
    )
  );
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION public.test_on_demand_voucher_stub_cannot_reference_multiple_use_voucher_reward()
RETURNS SETOF TEXT AS $$
DECLARE
  test_partner_id INT;
  test_reward_id UUID;
BEGIN
  INSERT INTO partner DEFAULT VALUES RETURNING id INTO test_partner_id;

  INSERT INTO reward (
    partner_id,
    redemption_forums,
    voucher_type
  ) VALUES (
    test_partner_id,
    '{"ONLINE"}',
    'MULTIPLE_USE'
  ) RETURNING id INTO test_reward_id;

  RETURN QUERY (
    SELECT throws_ok(
      FORMAT(
        'INSERT INTO on_demand_voucher_stub (reward_id) VALUES (%L);',
        test_reward_id
      )
    )
  );
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION public.test_on_demand_voucher_stub_cannot_reference_single_use_voucher_reward()
RETURNS SETOF TEXT AS $$
DECLARE
  test_partner_id INT;
  test_reward_id UUID;
BEGIN
  INSERT INTO partner DEFAULT VALUES RETURNING id INTO test_partner_id;

  INSERT INTO reward (
    partner_id,
    redemption_forums,
    voucher_type
  ) VALUES (
    test_partner_id,
    '{"ONLINE"}',
    'SINGLE_USE'
  ) RETURNING id INTO test_reward_id;

  RETURN QUERY (
    SELECT throws_ok(
      FORMAT(
        'INSERT INTO on_demand_voucher_stub (reward_id) VALUES (%L);',
        test_reward_id
      )
    )
  );
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION public.test_on_demand_voucher_stub_cannot_reference_manual_voucher_reward()
RETURNS SETOF TEXT AS $$
DECLARE
  test_partner_id INT;
  test_reward_id UUID;
BEGIN
  INSERT INTO partner DEFAULT VALUES RETURNING id INTO test_partner_id;

  INSERT INTO reward (
    partner_id,
    redemption_forums,
    voucher_type
  ) VALUES (
    test_partner_id,
    '{"ONLINE"}',
    'MANUAL'
  ) RETURNING id INTO test_reward_id;

  RETURN QUERY (
    SELECT throws_ok(
      FORMAT(
        'INSERT INTO on_demand_voucher_stub (reward_id) VALUES (%L);',
        test_reward_id
      )
    )
  );
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION public.test_manual_voucher_stub_can_reference_manual_voucher_reward()
RETURNS SETOF TEXT AS $$
DECLARE
  test_partner_id INT;
  test_reward_id UUID;
BEGIN
  INSERT INTO partner DEFAULT VALUES RETURNING id INTO test_partner_id;

  INSERT INTO reward (
    partner_id,
    redemption_forums,
    voucher_type
  ) VALUES (
    test_partner_id,
    '{"IN_STORE"}',
    'MANUAL'
  ) RETURNING id INTO test_reward_id;

  RETURN QUERY (
    SELECT lives_ok(
      FORMAT(
        'INSERT INTO manual_voucher_stub (reward_id) VALUES (%L);',
        test_reward_id
      )
    )
  );
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION public.test_manual_voucher_stub_cannot_reference_multiple_use_voucher_reward()
RETURNS SETOF TEXT AS $$
DECLARE
  test_partner_id INT;
  test_reward_id UUID;
BEGIN
  INSERT INTO partner DEFAULT VALUES RETURNING id INTO test_partner_id;

  INSERT INTO reward (
    partner_id,
    redemption_forums,
    voucher_type
  ) VALUES (
    test_partner_id,
    '{"ONLINE"}',
    'MULTIPLE_USE'
  ) RETURNING id INTO test_reward_id;

  RETURN QUERY (
    SELECT throws_ok(
      FORMAT(
        'INSERT INTO manual_voucher_stub (reward_id) VALUES (%L);',
        test_reward_id
      )
    )
  );
END;
$$ LANGUAGE plpgsql;


CREATE FUNCTION public.test_manual_voucher_stub_cannot_reference_single_use_voucher_reward()
RETURNS SETOF TEXT AS $$
DECLARE
  test_partner_id INT;
  test_reward_id UUID;
BEGIN
  INSERT INTO partner DEFAULT VALUES RETURNING id INTO test_partner_id;

  INSERT INTO reward (
    partner_id,
    redemption_forums,
    voucher_type
  ) VALUES (
    test_partner_id,
    '{"ONLINE"}',
    'SINGLE_USE'
  ) RETURNING id INTO test_reward_id;

  RETURN QUERY (
    SELECT throws_ok(
      FORMAT(
        'INSERT INTO manual_voucher_stub (reward_id) VALUES (%L);',
        test_reward_id
      )
    )
  );
END;
$$ LANGUAGE plpgsql;


CREATE FUNCTION public.test_manual_voucher_stub_cannot_reference_on_demand_voucher_reward()
RETURNS SETOF TEXT AS $$
DECLARE
  test_partner_id INT;
  test_reward_id UUID;
BEGIN
  INSERT INTO partner DEFAULT VALUES RETURNING id INTO test_partner_id;

  INSERT INTO reward (
    partner_id,
    redemption_forums,
    voucher_type
  ) VALUES (
    test_partner_id,
    '{"ONLINE"}',
    'ON_DEMAND'
  ) RETURNING id INTO test_reward_id;

  RETURN QUERY (
    SELECT throws_ok(
      FORMAT(
        'INSERT INTO manual_voucher_stub (reward_id) VALUES (%L);',
        test_reward_id
      )
    )
  );
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION public.test_on_demand_voucher_stub_redemption_method_can_reference_stub()
RETURNS SETOF TEXT AS $$
DECLARE
  test_partner_id INT;
  test_reward_id UUID;
  test_stub_id INT;
BEGIN
  INSERT INTO partner DEFAULT VALUES RETURNING id INTO test_partner_id;

  INSERT INTO reward (
    partner_id,
    redemption_forums,
    voucher_type
  ) VALUES (
    test_partner_id,
    '{"ONLINE"}',
    'ON_DEMAND'
  ) RETURNING id INTO test_reward_id;

  INSERT INTO on_demand_voucher_stub (reward_id)
  VALUES (test_reward_id)
  RETURNING id INTO test_stub_id;

  RETURN QUERY (
    SELECT lives_ok(
      FORMAT(
        'INSERT INTO on_demand_voucher_stub_redemption_method (on_demand_voucher_stub_id, redemption_method) VALUES (%L, ''CODE'');',
        test_stub_id
      )
    )
  );
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION public.test_on_demand_voucher_stub_link_translation_allows_redemption_link_text()
RETURNS SETOF TEXT AS $$
DECLARE
  test_partner_id INT;
  test_reward_id UUID;
  test_stub_id INT;
BEGIN
  INSERT INTO language (
    language_tag, 
    language_name_en, 
    language_name_native
  ) VALUES (
    'en',
    'English',
    'English'
  );

  INSERT INTO partner DEFAULT VALUES RETURNING id INTO test_partner_id;

  INSERT INTO reward (
    partner_id,
    redemption_forums,
    voucher_type
  ) VALUES (
    test_partner_id,
    '{"ONLINE"}',
    'ON_DEMAND'
  ) RETURNING id INTO test_reward_id;

  INSERT INTO on_demand_voucher_stub (reward_id)
  VALUES (test_reward_id)
  RETURNING id INTO test_stub_id;

  INSERT INTO on_demand_voucher_stub_redemption_method (
    on_demand_voucher_stub_id,
    redemption_method
  ) VALUES (
    test_stub_id,
    'LINK'
  );

  RETURN QUERY (
    SELECT lives_ok(
      FORMAT(
        'INSERT INTO on_demand_voucher_stub_redemption_method_translation (on_demand_voucher_stub_id, redemption_method, language_tag, instructions, redemption_link_text) VALUES (%L, ''LINK'', ''en'', %L, %L);',
        test_stub_id,
        anon.lorem_ipsum(words => 8),
        anon.lorem_ipsum(words => 3)
      )
    )
  );
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION public.test_on_demand_voucher_stub_non_link_translation_rejects_redemption_link_text()
RETURNS SETOF TEXT AS $$
DECLARE
  test_partner_id INT;
  test_reward_id UUID;
  test_stub_id INT;
BEGIN
  INSERT INTO partner DEFAULT VALUES RETURNING id INTO test_partner_id;

  INSERT INTO reward (
    partner_id,
    redemption_forums,
    voucher_type
  ) VALUES (
    test_partner_id,
    '{"ONLINE"}',
    'ON_DEMAND'
  ) RETURNING id INTO test_reward_id;

  INSERT INTO on_demand_voucher_stub (reward_id)
  VALUES (test_reward_id)
  RETURNING id INTO test_stub_id;

  INSERT INTO on_demand_voucher_stub_redemption_method (
    on_demand_voucher_stub_id,
    redemption_method
  ) VALUES (
    test_stub_id,
    'CODE'
  );

  RETURN QUERY (
    SELECT throws_ok(
      FORMAT(
        'INSERT INTO on_demand_voucher_stub_redemption_method_translation (on_demand_voucher_stub_id, redemption_method, language_tag, instructions, redemption_link_text) VALUES (%L, ''CODE'', ''en'', %L, %L);',
        test_stub_id,
        anon.lorem_ipsum(words => 8),
        anon.lorem_ipsum(words => 3)
      )
    )
  );
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION public.test_on_demand_voucher_stub_validity_requires_redemption_method_and_complete_translations()
RETURNS SETOF TEXT AS $$
DECLARE
  test_partner_id INT;
  test_reward_id UUID;
  test_stub_id INT;
BEGIN
  INSERT INTO language (language_tag, language_name_en, language_name_native)
  VALUES ('en', 'English', 'English');

  INSERT INTO language (language_tag, language_name_en, language_name_native)
  VALUES ('es', 'Spanish', 'Español');

  INSERT INTO partner DEFAULT VALUES RETURNING id INTO test_partner_id;

  INSERT INTO reward (
    partner_id,
    redemption_forums,
    voucher_type
  ) VALUES (
    test_partner_id,
    '{"ONLINE"}',
    'ON_DEMAND'
  ) RETURNING id INTO test_reward_id;

  INSERT INTO on_demand_voucher_stub (reward_id)
  VALUES (test_reward_id)
  RETURNING id INTO test_stub_id;

  RETURN QUERY
  SELECT ok(
    NOT EXISTS (
      SELECT 1
      FROM valid_on_demand_voucher_stub vos
      WHERE vos.id = test_stub_id
    ),
    'on-demand voucher stubs without redemption methods are not valid.'
  );

  INSERT INTO on_demand_voucher_stub_redemption_method (
    on_demand_voucher_stub_id,
    redemption_method
  ) VALUES (
    test_stub_id,
    'CODE'
  );

  RETURN QUERY
  SELECT ok(
    NOT EXISTS (
      SELECT 1
      FROM valid_on_demand_voucher_stub vos
      WHERE vos.id = test_stub_id
    ),
    'on-demand voucher stubs without complete method translations are not valid.'
  );

  INSERT INTO on_demand_voucher_stub_redemption_method_translation (
    on_demand_voucher_stub_id,
    redemption_method,
    language_tag,
    instructions
  ) VALUES (
    test_stub_id,
    'CODE',
    'en',
    anon.lorem_ipsum(words => 8)
  );

  RETURN QUERY
  SELECT ok(
    NOT EXISTS (
      SELECT 1
      FROM valid_on_demand_voucher_stub vos
      WHERE vos.id = test_stub_id
    ),
    'on-demand voucher stubs stay invalid until every supported language has translated instructions.'
  );

  INSERT INTO on_demand_voucher_stub_redemption_method_translation (
    on_demand_voucher_stub_id,
    redemption_method,
    language_tag,
    instructions
  ) VALUES (
    test_stub_id,
    'CODE',
    'es',
    anon.lorem_ipsum(words => 8)
  );

  RETURN QUERY
  SELECT ok(
    EXISTS (
      SELECT 1
      FROM valid_on_demand_voucher_stub vos
      WHERE vos.id = test_stub_id
    ),
    'on-demand voucher stubs become valid once all redemption methods have translations in all supported languages.'
  );
END;
$$ LANGUAGE plpgsql;