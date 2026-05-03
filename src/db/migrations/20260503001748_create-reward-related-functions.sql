-- migrate:up
CREATE FUNCTION get_available_rewards_in_timezone(tz TEXT) 
RETURNS SETOF reward AS $$
BEGIN 
  RETURN QUERY
  WITH eligible_reward_ids AS (
    SELECT DISTINCT v.reward_id
    FROM valid_single_use_voucher v
    WHERE v.redeemable_until IS NULL
      OR NOW() < v.redeemable_until

    UNION ALL

    SELECT v.reward_id
    FROM valid_multiple_use_voucher v
    WHERE v.redeemable_until IS NULL
      OR NOW() < v.redeemable_until

    UNION ALL

    SELECT s.reward_id
    FROM valid_manual_voucher_stub s
    WHERE 
      (s.vouchers_remaining IS NULL OR s.vouchers_remaining > 0)
      AND (
        (s.redeemable_until_exact IS NULL AND s.redeemable_until_local IS NULL) 
        OR
        NOW() < LEAST(s.redeemable_until_exact, (s.redeemable_until_local AT TIME ZONE tz))
      )

    UNION ALL

    SELECT s.reward_id
    FROM valid_on_demand_voucher_stub s
    WHERE 
      (s.vouchers_remaining IS NULL OR s.vouchers_remaining > 0)
      AND (
        (s.redeemable_until_exact IS NULL AND s.redeemable_until_local IS NULL) 
        OR
        NOW() < LEAST(s.redeemable_until_exact, (s.redeemable_until_local AT TIME ZONE tz))
      )
  )
  SELECT r.*
  FROM valid_reward r
  INNER JOIN eligible_reward_ids eri ON eri.reward_id = r.id
  WHERE (r.available_from_exact IS NULL OR NOW() >= r.available_from_exact)
    AND (r.available_until_exact IS NULL OR NOW() < r.available_until_exact)
    AND (
      r.available_from_local IS NULL
      OR NOW() >= (r.available_from_local AT TIME ZONE tz)
    )
    AND (
      r.available_until_local IS NULL
      OR NOW() < (r.available_until_local AT TIME ZONE tz)
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
  RETURN COALESCE((
    SELECT CASE
      WHEN r.voucher_type = 'SINGLE_USE' THEN TRUE
      WHEN r.voucher_type = 'MULTIPLE_USE' THEN EXISTS (
        SELECT 1
        FROM multiple_use_voucher v
        WHERE v.reward_id = r.id
          AND v.has_usage_cap
      )
      WHEN r.voucher_type = 'MANUAL' THEN EXISTS (
        SELECT 1
        FROM manual_voucher_stub s
        WHERE s.reward_id = r.id
          AND s.vouchers_remaining IS NOT NULL
      )
      WHEN r.voucher_type = 'ON_DEMAND' THEN EXISTS (
        SELECT 1
        FROM valid_on_demand_voucher_stub s
        WHERE s.reward_id = r.id
          AND s.vouchers_remaining IS NOT NULL
      )
      ELSE FALSE
    END
    FROM reward r
    WHERE r.id = has_usage_or_quantity_limit.reward_id
  ), FALSE);
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
  current_now TIMESTAMPTZ := NOW();
BEGIN
  SELECT r.voucher_type
  INTO reward_voucher_type
  FROM valid_reward r
  WHERE r.id = calc_earliest_future_expiration_date.reward_id;
  
  IF reward_voucher_type = 'SINGLE_USE' THEN 
    RETURN (
	    SELECT v.redeemable_until
	    FROM valid_single_use_voucher v
	    WHERE v.reward_id = calc_earliest_future_expiration_date.reward_id
        AND (
          current_now < v.redeemable_until
          OR v.redeemable_until IS NULL
        )
	    ORDER BY v.redeemable_until ASC NULLS LAST
	    LIMIT 1
    );
  END IF;
  
  IF reward_voucher_type = 'MULTIPLE_USE' THEN
    RETURN (
      SELECT v.redeemable_until
      FROM valid_multiple_use_voucher v
	    WHERE v.reward_id = calc_earliest_future_expiration_date.reward_id
        AND (
          v.redeemable_until IS NULL
          OR current_now < v.redeemable_until
        )
	  );
  END IF;
  
  IF reward_voucher_type = 'MANUAL' THEN
    RETURN (
    SELECT MIN(expiration_at)
    FROM valid_manual_voucher_stub s
    CROSS JOIN LATERAL (
      VALUES
        (s.redeemable_until_exact),
        (s.redeemable_until_local AT TIME ZONE tz),
        (CASE
          WHEN s.redeemable_for IS NULL THEN NULL
          ELSE current_now + s.redeemable_for
        END)
    ) AS expirations(expiration_at)
    WHERE s.reward_id = calc_earliest_future_expiration_date.reward_id
      AND (s.vouchers_remaining IS NULL OR s.vouchers_remaining > 0)
      AND expiration_at IS NOT NULL
      AND current_now < expiration_at
	);
  END IF;
  
  RETURN (
    SELECT MIN(expiration_at)
    FROM valid_on_demand_voucher_stub s
    CROSS JOIN LATERAL (
      VALUES
        (s.redeemable_until_exact),
        (s.redeemable_until_local AT TIME ZONE tz),
        (CASE
          WHEN s.redeemable_for IS NULL THEN NULL
          ELSE current_now + s.redeemable_for
        END)
    ) AS expirations(expiration_at)
    WHERE s.reward_id = calc_earliest_future_expiration_date.reward_id
      AND (s.vouchers_remaining IS NULL OR s.vouchers_remaining > 0)
      AND expiration_at IS NOT NULL
      AND current_now < expiration_at
  );
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION calc_earliest_future_expiration_date IS '@introspeql-include';

-- migrate:down
DROP FUNCTION calc_earliest_future_expiration_date(UUID, TEXT);
DROP FUNCTION has_usage_or_quantity_limit(UUID);
DROP FUNCTION get_translated_reward_categories(UUID, TEXT);
DROP FUNCTION get_available_rewards_in_timezone(TEXT);
