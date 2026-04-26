-- migrate:up
CREATE TABLE partner (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  is_active BOOLEAN NOT NULL DEFAULT TRUE
) INHERITS (base_entity);

COMMENT ON TABLE partner IS '@introspeql-include';

CREATE TRIGGER partner_update_trigger 
BEFORE UPDATE ON partner
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE partner_details_translation (
  partner_id INT REFERENCES partner(id) ON DELETE CASCADE,
  language_tag TEXT REFERENCES language(language_tag) ON DELETE RESTRICT,
  name TEXT NOT NULL,
  logo_url TEXT NOT NULL,
  description TEXT NOT NULL,
  web_address_url TEXT,
  web_address_text TEXT,
  motivation TEXT,
  PRIMARY KEY(partner_id, language_tag)
) INHERITS (base_entity);

COMMENT ON TABLE partner_details_translation IS '@introspeql-include';

CREATE TRIGGER partners_details_translation_update_trigger 
BEFORE UPDATE ON partner_details_translation
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE active_partner (
  LIKE partner INCLUDING ALL
);

COMMENT ON TABLE active_partner IS '@introspeql-include';

CREATE FUNCTION is_active_partner(partner_id INT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM partner p
    WHERE p.id = is_active_partner.partner_id
      AND p.is_active
      AND NOT EXISTS (
        (
          SELECT l.language_tag
          FROM language l
        )
        EXCEPT
        (
          SELECT pd.language_tag
          FROM partner_details_translation pd
          WHERE pd.partner_id = is_active_partner.partner_id
        )
      )
  );
END;
$$ LANGUAGE plpgsql STABLE;

CREATE FUNCTION refresh_active_partner_table_for_partner(partner_id INT)
RETURNS VOID AS $$
BEGIN
  DELETE FROM active_partner ap
  WHERE ap.id = refresh_active_partner_table_for_partner.partner_id;

  INSERT INTO active_partner
  OVERRIDING SYSTEM VALUE
  SELECT p.*
  FROM partner p
  WHERE p.id = refresh_active_partner_table_for_partner.partner_id
    AND is_active_partner(
      refresh_active_partner_table_for_partner.partner_id
    );
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION refresh_active_partner_table()
RETURNS VOID AS $$
BEGIN
  DELETE FROM active_partner;

  INSERT INTO active_partner
  OVERRIDING SYSTEM VALUE
  SELECT p.*
  FROM partner p
  WHERE p.is_active
    AND NOT EXISTS (
      (
        SELECT l.language_tag
        FROM language l
      )
      EXCEPT
      (
        SELECT pd.language_tag
        FROM partner_details_translation pd
        WHERE pd.partner_id = p.id
      )
    );
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION sync_active_partner_table_from_partner_trigger()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    DELETE FROM active_partner ap WHERE ap.id = OLD.id;
    RETURN OLD;
  END IF;

  IF TG_OP = 'UPDATE' AND OLD.id <> NEW.id THEN
    DELETE FROM active_partner ap WHERE ap.id = OLD.id;
  END IF;

  PERFORM refresh_active_partner_table_for_partner(NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION sync_active_partner_table_from_partner_details_translation_trigger()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    PERFORM refresh_active_partner_table_for_partner(OLD.partner_id);
    RETURN OLD;
  END IF;

  PERFORM refresh_active_partner_table_for_partner(NEW.partner_id);

  IF TG_OP = 'UPDATE' AND OLD.partner_id <> NEW.partner_id THEN
    PERFORM refresh_active_partner_table_for_partner(OLD.partner_id);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION sync_active_partner_table_from_language_trigger()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM refresh_active_partner_table();
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER partner_active_partner_table_trigger
AFTER INSERT OR UPDATE OR DELETE ON partner
FOR EACH ROW EXECUTE FUNCTION sync_active_partner_table_from_partner_trigger();

CREATE TRIGGER partner_details_translation_active_partner_table_trigger
AFTER INSERT OR UPDATE OR DELETE ON partner_details_translation
FOR EACH ROW EXECUTE FUNCTION sync_active_partner_table_from_partner_details_translation_trigger();

CREATE TRIGGER language_active_partner_table_trigger
AFTER INSERT OR UPDATE OR DELETE ON language
FOR EACH STATEMENT EXECUTE FUNCTION sync_active_partner_table_from_language_trigger();

SELECT refresh_active_partner_table();

-- migrate:down
DROP TRIGGER language_active_partner_table_trigger ON language;
DROP TRIGGER partner_details_translation_active_partner_table_trigger ON partner_details_translation;
DROP TRIGGER partner_active_partner_table_trigger ON partner;

DROP FUNCTION sync_active_partner_table_from_language_trigger;
DROP FUNCTION sync_active_partner_table_from_partner_details_translation_trigger;
DROP FUNCTION sync_active_partner_table_from_partner_trigger;
DROP FUNCTION refresh_active_partner_table;
DROP FUNCTION refresh_active_partner_table_for_partner;
DROP FUNCTION is_active_partner;

DROP TABLE active_partner;
DROP TABLE partner_details_translation;
DROP TABLE partner;


