-- migrate:up
CREATE FUNCTION get_available_rewards_in_timezone(tz TEXT) 
RETURNS SETOF reward AS $$
DECLARE validated_tz TEXT;
BEGIN 
  SELECT COALESCE(
    (SELECT name FROM pg_timezone_names WHERE name = tz),
	  'America/Chicago'
  ) INTO validated_tz;

  RETURN QUERY
  SELECT r.*
  FROM valid_reward r
  WHERE (
    NOW() >= GREATEST(
      r.available_from_exact,
      (r.available_from_local AT TIME ZONE validated_tz)
    ) OR (
      r.available_from_exact IS NULL 
      AND r.available_from_local IS NULL
    )
  ) AND (
    NOW() < LEAST(
      r.available_until_exact,
      (r.available_until_local AT TIME ZONE validated_tz)
    ) OR (
      r.available_until_exact IS NULL
      AND r.available_until_local IS NULL
    )
  ) AND (
    (
      r.voucher_type = 'SINGLE_USE' AND EXISTS (
        SELECT 1 
        FROM v_valid_single_use_voucher v
        WHERE v.reward_id = r.id
        AND (
          NOW() < v.redeemable_until 
          OR v.redeemable_until IS NULL
        )
      )
    ) OR (
      r.voucher_type = 'MULTIPLE_USE' AND EXISTS (
        SELECT 1 
        FROM v_valid_multiple_use_voucher v
        WHERE v.reward_id = r.id
        AND (
          NOW() < v.redeemable_until 
          OR v.redeemable_until IS NULL
        )
      )
    ) OR (
      r.voucher_type = 'MANUAL' AND EXISTS (
        SELECT 1 
        FROM v_valid_manual_voucher_stub s
        WHERE s.reward_id = r.id
        AND s.vouchers_remaining > 0
        AND (
          NOW() < LEAST(
	          s.redeemable_until_exact,
            (s.redeemable_until_local AT TIME ZONE validated_tz)
	        ) OR (
            s.redeemable_until_exact IS NULL
            AND s.redeemable_until_local IS NULL
          )
        )
      )
    ) OR (
      r.voucher_type = 'ON_DEMAND' AND EXISTS (
        SELECT 1 
        FROM on_demand_voucher_stub s
        WHERE s.reward_id = r.id
        AND s.vouchers_remaining > 0
        AND (
          NOW() < LEAST(
	          s.redeemable_until_exact,
            (s.redeemable_until_local AT TIME ZONE validated_tz)
	        ) OR (
            s.redeemable_until_exact IS NULL
            AND s.redeemable_until_local IS NULL
          )
        )
      )
    )
  );
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION get_available_rewards_in_timezone IS 
$$
@introspeql-include
@introspeql-disable-nullable-return-types
$$;

CREATE FUNCTION get_translated_reward_categories(reward_id UUID, language_tag TEXT)
RETURNS TEXT[] AS $$
  DECLARE category_translations TEXT[];
  BEGIN
    SELECT ARRAY_AGG(c.category_name ORDER BY c.category_name) 
    INTO category_translations
    FROM category_translation c
    INNER JOIN reward_category r ON c.category_id = r.category_id
    WHERE r.reward_id = get_translated_reward_categories.reward_id
      AND c.language_tag = get_translated_reward_categories.language_tag;

    RETURN array_sort(category_translations);
  END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION get_translated_reward_categories IS 
$$
@introspeql-include
@introspeql-disable-nullable-return-types
$$;

CREATE FUNCTION has_usage_or_quantity_limit(reward_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN (
    SELECT 
      r.voucher_type = 'SINGLE_USE' OR
      (
        r.voucher_type = 'MULTIPLE_USE' AND (
          SELECT v.has_usage_cap 
          FROM multiple_use_voucher v 
          WHERE v.reward_id = r.id
        )
      ) OR (
        r.voucher_type = 'MANUAL' AND (
          SELECT s.vouchers_remaining IS NOT NULL
          FROM manual_voucher_stub s
          WHERE s.reward_id = r.id
        )
      ) OR (
        r.voucher_type = 'ON_DEMAND' AND (
          SELECT s.vouchers_remaining IS NOT NULL
          FROM on_demand_voucher_stub s
          WHERE s.reward_id = r.id
        )
      )
    FROM reward r
    WHERE r.id = has_usage_or_quantity_limit.reward_id
  );
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION has_usage_or_quantity_limit IS 
$$
@introspeql-include
@introspeql-disable-nullable-return-types
$$;

CREATE FUNCTION calc_earliest_future_expiration_date(reward_id UUID, tz TEXT) 
RETURNS TIMESTAMPTZ AS $$
DECLARE 
  reward_voucher_type voucher_type;
  validated_tz TEXT;
BEGIN
  SELECT r.voucher_type
  INTO reward_voucher_type
  FROM valid_reward r
  WHERE r.id = calc_earliest_future_expiration_date.reward_id;
  
  IF reward_voucher_type = 'SINGLE_USE' THEN 
    RETURN (
	    SELECT v.redeemable_until
	    FROM single_use_voucher v
	    WHERE v.reward_id = calc_earliest_future_expiration_date.reward_id
        AND (
          NOW() < v.redeemable_until
          OR v.redeemable_until IS NULL
        )
	    ORDER BY v.redeemable_until ASC NULLS LAST
	    LIMIT 1
    );
  END IF;
  
  IF reward_voucher_type = 'MULTIPLE_USE' THEN
    RETURN (
      SELECT v.redeemable_until
	    FROM multiple_use_voucher v
	    WHERE v.reward_id = calc_earliest_future_expiration_date.reward_id
	  );
  END IF;

  SELECT COALESCE(
    (SELECT name FROM pg_timezone_names WHERE name = tz),
	'America/Chicago'
  ) INTO validated_tz;
  
  IF reward_voucher_type = 'MANUAL' THEN
    RETURN (
	  SELECT LEAST(
	    s.redeemable_until_exact,
      (s.redeemable_until_local AT TIME ZONE validated_tz),
      NOW() + s.redeemable_for
	  ) FROM manual_voucher_stub s
	  WHERE s.reward_id = calc_earliest_future_expiration_date.reward_id
	);
  END IF;
  
  RETURN (
	  SELECT LEAST(
	    s.redeemable_until_exact,
      (s.redeemable_until_local AT TIME ZONE validated_tz),
      NOW() + s.redeemable_for
	  ) FROM on_demand_voucher_stub s
	  WHERE s.reward_id = calc_earliest_future_expiration_date.reward_id
  );
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION calc_earliest_future_expiration_date IS '@introspeql-include';

-- migrate:down
DROP FUNCTION calc_earliest_future_expiration_date;
DROP FUNCTION has_usage_or_quantity_limit;
DROP FUNCTION get_translated_reward_categories;
DROP FUNCTION get_available_rewards_in_timezone;
