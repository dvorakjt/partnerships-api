-- migrate:up
CREATE TABLE reward (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_id INT NOT NULL REFERENCES partner(id) ON DELETE RESTRICT,
  redemption_forums redemption_forum[] NOT NULL,
  voucher_type voucher_type NOT NULL,
  available_from_exact TIMESTAMPTZ,
  available_until_exact TIMESTAMPTZ,
  available_from_local TIMESTAMP,
  available_until_local TIMESTAMP,
  CONSTRAINT redemption_forums_is_not_empty CHECK (CARDINALITY(redemption_forums) > 0),
  CONSTRAINT redemption_forums_contains_no_duplicates CHECK (NOT contains_duplicates (redemption_forums))
) INHERITS (base_entity);

COMMENT ON TABLE reward IS '@introspeql-include';

CREATE TRIGGER reward_update_trigger
BEFORE UPDATE ON reward
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE INDEX reward_partner_id_idx
ON reward(partner_id);

CREATE TABLE valid_reward (
  LIKE reward INCLUDING ALL
);

COMMENT ON TABLE valid_reward IS '@introspeql-include';

CREATE TABLE reward_category (
  reward_id UUID REFERENCES reward(id) ON DELETE CASCADE,
  category_id INT REFERENCES category(id) ON DELETE RESTRICT,
  PRIMARY KEY(reward_id, category_id)
) INHERITS (base_entity);

COMMENT ON TABLE reward_category IS '@introspeql-include';

CREATE TRIGGER reward_category_update_trigger
BEFORE UPDATE ON reward_category
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE INDEX reward_category_category_id_reward_id_idx
ON reward_category(category_id, reward_id);

CREATE TABLE reward_details_translation (
  reward_id UUID NOT NULL REFERENCES reward(id) ON DELETE CASCADE,
  language_tag TEXT NOT NULL REFERENCES language(language_tag) ON DELETE RESTRICT,
  short_description TEXT NOT NULL,
  long_description TEXT,
  PRIMARY KEY(reward_id, language_tag)
) INHERITS (base_entity);

COMMENT ON TABLE reward_details_translation IS '@introspeql-include';

CREATE TRIGGER reward_details_translation_update_trigger
BEFORE UPDATE ON reward_details_translation
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE FUNCTION is_valid_reward(reward_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM reward r
    INNER JOIN active_partner ap ON ap.id = r.partner_id
    WHERE r.id = is_valid_reward.reward_id
      AND NOT EXISTS (
        (
          SELECT l.language_tag
          FROM language l
        )
        EXCEPT
        (
          SELECT rd.language_tag
          FROM reward_details_translation rd
          WHERE rd.reward_id = r.id
        )
      )
      AND NOT EXISTS (
        SELECT 1
        FROM reward_category rc
        WHERE rc.reward_id = r.id
          AND EXISTS (
            (
              SELECT l.language_tag
              FROM language l
            )
            EXCEPT
            (
              SELECT ct.language_tag
              FROM category_translation ct
              WHERE ct.category_id = rc.category_id
            )
          )
      )
  );
END;
$$ LANGUAGE plpgsql STABLE;

CREATE FUNCTION refresh_valid_reward_table_for_reward(reward_id UUID)
RETURNS VOID AS $$
BEGIN
  DELETE FROM valid_reward vr
  WHERE vr.id = refresh_valid_reward_table_for_reward.reward_id;

  INSERT INTO valid_reward
  OVERRIDING SYSTEM VALUE
  SELECT r.*
  FROM reward r
  WHERE r.id = refresh_valid_reward_table_for_reward.reward_id
    AND is_valid_reward(
      refresh_valid_reward_table_for_reward.reward_id
    );
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION refresh_valid_reward_table_for_partner(partner_id INT)
RETURNS VOID AS $$
BEGIN
  DELETE FROM valid_reward vr
  WHERE vr.partner_id = refresh_valid_reward_table_for_partner.partner_id;

  INSERT INTO valid_reward
  OVERRIDING SYSTEM VALUE
  SELECT r.*
  FROM reward r
  WHERE r.partner_id = refresh_valid_reward_table_for_partner.partner_id
    AND is_valid_reward(r.id);
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION refresh_valid_reward_table_for_category(category_id INT)
RETURNS VOID AS $$
BEGIN
  WITH affected_reward AS (
    SELECT DISTINCT rc.reward_id
    FROM reward_category rc
    WHERE rc.category_id = refresh_valid_reward_table_for_category.category_id
  )
  DELETE FROM valid_reward vr
  USING affected_reward ar
  WHERE vr.id = ar.reward_id;

  INSERT INTO valid_reward
  OVERRIDING SYSTEM VALUE
  SELECT r.*
  FROM reward r
  WHERE r.id IN (
    SELECT rc.reward_id
    FROM reward_category rc
    WHERE rc.category_id = refresh_valid_reward_table_for_category.category_id
  )
    AND is_valid_reward(r.id);
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION refresh_valid_reward_table()
RETURNS VOID AS $$
BEGIN
  DELETE FROM valid_reward;

  INSERT INTO valid_reward
  OVERRIDING SYSTEM VALUE
  SELECT r.*
  FROM reward r
  WHERE is_valid_reward(r.id);
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION sync_valid_reward_table_from_reward_trigger()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    DELETE FROM valid_reward vr WHERE vr.id = OLD.id;
    RETURN OLD;
  END IF;

  IF TG_OP = 'UPDATE' AND OLD.id <> NEW.id THEN
    DELETE FROM valid_reward vr WHERE vr.id = OLD.id;
  END IF;

  PERFORM refresh_valid_reward_table_for_reward(NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION sync_valid_reward_table_from_reward_details_translation_trigger()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    PERFORM refresh_valid_reward_table_for_reward(OLD.reward_id);
    RETURN OLD;
  END IF;

  PERFORM refresh_valid_reward_table_for_reward(NEW.reward_id);

  IF TG_OP = 'UPDATE' AND OLD.reward_id <> NEW.reward_id THEN
    PERFORM refresh_valid_reward_table_for_reward(OLD.reward_id);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION sync_valid_reward_table_from_reward_category_trigger()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    PERFORM refresh_valid_reward_table_for_reward(OLD.reward_id);
    RETURN OLD;
  END IF;

  PERFORM refresh_valid_reward_table_for_reward(NEW.reward_id);

  IF TG_OP = 'UPDATE' AND OLD.reward_id <> NEW.reward_id THEN
    PERFORM refresh_valid_reward_table_for_reward(OLD.reward_id);
  END IF;

  IF TG_OP = 'UPDATE' AND OLD.category_id <> NEW.category_id THEN
    PERFORM refresh_valid_reward_table_for_category(OLD.category_id);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION sync_valid_reward_table_from_category_translation_trigger()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    PERFORM refresh_valid_reward_table_for_category(OLD.category_id);
    RETURN OLD;
  END IF;

  PERFORM refresh_valid_reward_table_for_category(NEW.category_id);

  IF TG_OP = 'UPDATE' AND OLD.category_id <> NEW.category_id THEN
    PERFORM refresh_valid_reward_table_for_category(OLD.category_id);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION sync_valid_reward_table_from_category_trigger()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    PERFORM refresh_valid_reward_table_for_category(OLD.id);
    RETURN OLD;
  END IF;

  PERFORM refresh_valid_reward_table_for_category(NEW.id);

  IF TG_OP = 'UPDATE' AND OLD.id <> NEW.id THEN
    PERFORM refresh_valid_reward_table_for_category(OLD.id);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION sync_valid_reward_table_from_active_partner_trigger()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    DELETE FROM valid_reward vr
    WHERE vr.partner_id = OLD.id;
    RETURN OLD;
  END IF;

  PERFORM refresh_valid_reward_table_for_partner(NEW.id);

  IF TG_OP = 'UPDATE' AND OLD.id <> NEW.id THEN
    PERFORM refresh_valid_reward_table_for_partner(OLD.id);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION sync_valid_reward_table_from_language_trigger()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM refresh_valid_reward_table();
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reward_valid_reward_table_trigger
AFTER INSERT OR UPDATE OR DELETE ON reward
FOR EACH ROW EXECUTE FUNCTION sync_valid_reward_table_from_reward_trigger();

CREATE TRIGGER reward_details_translation_valid_reward_table_trigger
AFTER INSERT OR UPDATE OR DELETE ON reward_details_translation
FOR EACH ROW EXECUTE FUNCTION sync_valid_reward_table_from_reward_details_translation_trigger();

CREATE TRIGGER reward_category_valid_reward_table_trigger
AFTER INSERT OR UPDATE OR DELETE ON reward_category
FOR EACH ROW EXECUTE FUNCTION sync_valid_reward_table_from_reward_category_trigger();

CREATE TRIGGER category_translation_valid_reward_table_trigger
AFTER INSERT OR UPDATE OR DELETE ON category_translation
FOR EACH ROW EXECUTE FUNCTION sync_valid_reward_table_from_category_translation_trigger();

CREATE TRIGGER category_valid_reward_table_trigger
AFTER INSERT OR UPDATE OR DELETE ON category
FOR EACH ROW EXECUTE FUNCTION sync_valid_reward_table_from_category_trigger();

CREATE TRIGGER active_partner_valid_reward_table_trigger
AFTER INSERT OR UPDATE OR DELETE ON active_partner
FOR EACH ROW EXECUTE FUNCTION sync_valid_reward_table_from_active_partner_trigger();

CREATE TRIGGER language_valid_reward_table_trigger
AFTER INSERT OR UPDATE OR DELETE ON language
FOR EACH STATEMENT EXECUTE FUNCTION sync_valid_reward_table_from_language_trigger();

SELECT refresh_valid_reward_table();

CREATE FUNCTION reward_voucher_type_matches(
  reward_id UUID, 
  expected_voucher_type voucher_type
) RETURNS BOOLEAN AS $$
BEGIN
  RETURN (
    SELECT voucher_type 
    FROM reward
    WHERE id = reward_voucher_type_matches.reward_id
  ) = reward_voucher_type_matches.expected_voucher_type;
END;
$$ LANGUAGE plpgsql;

-- migrate:down
DROP TRIGGER language_valid_reward_table_trigger ON language;
DROP TRIGGER active_partner_valid_reward_table_trigger ON active_partner;
DROP TRIGGER category_valid_reward_table_trigger ON category;
DROP TRIGGER category_translation_valid_reward_table_trigger ON category_translation;
DROP TRIGGER reward_category_valid_reward_table_trigger ON reward_category;
DROP TRIGGER reward_details_translation_valid_reward_table_trigger ON reward_details_translation;
DROP TRIGGER reward_valid_reward_table_trigger ON reward;

DROP FUNCTION sync_valid_reward_table_from_language_trigger;
DROP FUNCTION sync_valid_reward_table_from_active_partner_trigger;
DROP FUNCTION sync_valid_reward_table_from_category_trigger;
DROP FUNCTION sync_valid_reward_table_from_category_translation_trigger;
DROP FUNCTION sync_valid_reward_table_from_reward_category_trigger;
DROP FUNCTION sync_valid_reward_table_from_reward_details_translation_trigger;
DROP FUNCTION sync_valid_reward_table_from_reward_trigger;
DROP FUNCTION refresh_valid_reward_table;
DROP FUNCTION refresh_valid_reward_table_for_category;
DROP FUNCTION refresh_valid_reward_table_for_partner;
DROP FUNCTION refresh_valid_reward_table_for_reward;
DROP FUNCTION is_valid_reward;

DROP FUNCTION reward_voucher_type_matches;
DROP INDEX reward_category_category_id_reward_id_idx;
DROP TABLE valid_reward;

DROP INDEX reward_partner_id_idx;
DROP TABLE reward_details_translation;
DROP TABLE reward_category;
DROP TABLE reward;
